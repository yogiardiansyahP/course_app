import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:project_akhir_app/login.dart';
import 'package:project_akhir_app/materi.dart';
import 'package:project_akhir_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CourseListPage extends StatefulWidget {
  const CourseListPage({super.key});

  @override
  State<CourseListPage> createState() => _CourseListPageState();
}

class _CourseListPageState extends State<CourseListPage> {
  bool _isLoggedIn = false;
  bool _loading = true;
  bool _isLoadingData = false;
  String? _token;

  List<dynamic> _courses = [];
  Map<String, bool> hasAccessMap = {};
  // Map<String, double> progressMap = {}; // dihapus
  bool _freezeInteractions = true;

  static const String baseUrl = 'https://codeinko.com/api';

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (!mounted) return;

    setState(() {
      _isLoggedIn = token != null && token.isNotEmpty;
      _token = token;
      _loading = false;
    });

    if (_isLoggedIn && _token != null) {
      await loadCoursesAndCheckAccess(_token!);
      setState(() {
        _freezeInteractions = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> getUserTransactions(String token) async {
    final url = Uri.parse('$baseUrl/transactions');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> transactions = jsonResponse['transactions'];

      return transactions
          .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
          .toList();
    } else {
      throw Exception('Failed to load transactions. Status: ${response.statusCode}');
    }
  }

  Future<void> loadCoursesAndCheckAccess(String token) async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      ApiService apiService = ApiService();

      final courses = await apiService.getCoursesFromApi(token);
      final transactions = await getUserTransactions(token);
      // final progress = await apiService.getChartProgress(token, courses); // dihapus

      Map<String, bool> accessMap = {};
      for (var course in courses) {
        final courseName = course['name'] ?? '';
        final hasAccess = transactions.any((t) =>
            (t['course_name']?.toString().toLowerCase() ?? '') ==
            courseName.toString().toLowerCase());
        accessMap[courseName] = hasAccess;
      }

      if (!mounted) return;

      setState(() {
        _courses = courses;
        hasAccessMap = accessMap;
        // progressMap = progress; // dihapus
        _isLoadingData = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingData = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat kelas dan transaksi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isLoggedIn) {
      Future.microtask(() {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('asset/image/logo.png', width: 32),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final token = prefs.getString('token');
                      if (token != null && token.isNotEmpty) {
                        try {
                          bool success = await ApiService().logout(token);
                          if (success) {
                            await prefs.clear();
                            if (!mounted) return;
                            setState(() {
                              _isLoggedIn = false;
                              _token = null;
                              _courses = [];
                              hasAccessMap = {};
                              // progressMap = {}; // dihapus
                            });
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()),
                            );
                          }
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Logout gagal: $e')),
                          );
                        }
                      }
                    },
                    tooltip: 'Logout',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                "Selamat datang di CodeIn Course!",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 23,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Gabung Kelas Unggulan Codein Course",
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              const Chip(label: Text("Course")),
              const SizedBox(height: 16),

              if (_isLoadingData)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_courses.isEmpty)
                const Expanded(
                  child: Center(child: Text("Tidak ada course tersedia")),
                )
              else
                Expanded(
                  child: AbsorbPointer(
                    absorbing: _freezeInteractions,
                    child: ListView.builder(
                      itemCount: _courses.length,
                      itemBuilder: (context, index) {
                        final course = _courses[index] as Map<String, dynamic>;
                        final courseTitle = course['name']?.toString() ?? 'Unknown Course';
                        final thumbnail = course['thumbnail']?.toString() ?? '';
                        final mentor = course['mentor']?.toString() ?? 'Unknown Mentor';
                        final bool isActive = hasAccessMap[courseTitle] ?? false;

                        return _courseCard(
                          context,
                          courseTitle,
                          thumbnail,
                          mentor,
                          _token!,
                          course,
                          isActive,
                          freeze: _freezeInteractions,
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _courseCard(
    BuildContext context,
    String courseTitle,
    String thumbnail,
    String mentor,
    String token,
    Map<String, dynamic> courseData,
    bool isActive, {
    bool freeze = false,
  }) {
    final String imageUrl = 'https://codeinko.com/storage/$thumbnail';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: thumbnail.isNotEmpty
                ? Image.network(
                    imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 150,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 40),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  courseTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Mentor: $mentor",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 12),
                // Hapus progress bar dan teksnya
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: freeze
                        ? null
                        : () {
                            if (isActive) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CourseMaterialPage(
                                    courseName: courseTitle,
                                    materials: (courseData['materials'] as List<dynamic>).map<Map<String, String>>((m) {
                                      return {
                                        'slug': (m['slug'] ?? '').toString(),
                                        'title': (m['title'] ?? '').toString(),
                                        'video_url': (m['video_url'] ?? '').toString(),
                                        'description': (m['description'] ?? '').toString(),
                                        'nama_materi': (m['title'] ?? '').toString(),
                                      };
                                    }).toList(),
                                    currentSlug: courseData['materials'][0]['slug'],
                                    status: 'active',
                                  ),
                                ),
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Akses Ditolak'),
                                  content: const Text('Anda belum membeli kelas ini.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                    child: Text(isActive ? 'Active' : 'Beli Sekarang'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
