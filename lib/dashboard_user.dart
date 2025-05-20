import 'package:flutter/material.dart';
import 'package:project_akhir_app/login.dart';
import 'package:project_akhir_app/materi.dart';
import 'package:project_akhir_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CourseListPage extends StatefulWidget {
  const CourseListPage({super.key});

  @override
  State<CourseListPage> createState() => _CourseListPageState();
}

class _CourseListPageState extends State<CourseListPage> {
  bool _isLoggedIn = false;
  bool _loading = true;
  String? _token;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    setState(() {
      _isLoggedIn = token != null;
      _token = token;
      _loading = false;
    });
  }

  Future<List<dynamic>> _fetchCourses() async {
    if (_token == null) return [];
    try {
      ApiService apiService = ApiService();
      final courses = await apiService.getCoursesFromApi(_token!);
      return courses;
    } catch (e) {
      throw Exception('Failed to load courses: $e');
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
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
                      if (token != null) {
                        try {
                          bool success = await ApiService().logout(token);
                          if (success) {
                            await prefs.clear();
                            setState(() {
                              _isLoggedIn = false;
                              _token = null;
                            });
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginPage()),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Logout gagal: $e')),
                          );
                        }
                      }
                    },
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
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: _fetchCourses(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("Tidak ada course tersedia"));
                    } else {
                      final courses = snapshot.data!;
                      return ListView.builder(
                        itemCount: courses.length,
                        itemBuilder: (context, index) {
                          final course = courses[index];
                          return _courseCard(
                            context,
                            course['name'] ?? 'Unknown Course',
                            course['thumbnail'] ?? '',
                            course['mentor'] ?? 'Unknown Mentor',
                            _token!,
                            course, // passing whole course data for VideoLessonPage
                          );
                        },
                      );
                    }
                  },
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
  ) {
    final String imageUrl = 'https://codeinko.com/storage/$thumbnail';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoLessonPage(
              courseName: courseTitle,
              title: courseData['current_lesson_title'] ?? 'Judul Video',
              description: courseData['current_lesson_description'] ?? '',
              videoUrl: courseData['current_lesson_video_url'] ?? '',
              hasAccess: courseData['has_access'] ?? false,
              hasPrev: false,  // sesuaikan kalau ada navigasi prev
              hasNext: false,  // sesuaikan kalau ada navigasi next
              onPrev: null,    // fungsi navigasi prev kalau ada
              onNext: null,    // fungsi navigasi next kalau ada
            ),
          ),
        );
      },
      child: Container(
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
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, size: 40),
                        );
                      },
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
                  Text(courseTitle,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(mentor,
                      style:
                          const TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}