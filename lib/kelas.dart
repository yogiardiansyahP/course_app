import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project_akhir_app/services/api_service.dart';
import 'package:project_akhir_app/checkout.dart';

class KelasPage extends StatefulWidget {
  final String token;

  const KelasPage({super.key, required this.token});

  @override
  State<KelasPage> createState() => _KelasPageState();
}

class _KelasPageState extends State<KelasPage> {
  List<dynamic> _courses = [];
  Map<String, bool> hasAccessMap = {}; // key: courseName, value: akses (paid or not)
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCoursesAndCheckAccess();
  }

  Future<void> loadCoursesAndCheckAccess() async {
    setState(() {
      isLoading = true;
    });

    try {
      ApiService apiService = ApiService();
      final courses = await apiService.getCoursesFromApi(widget.token);
      final transactions = await getUserTransactions(widget.token);

      // Buat map akses per nama course
      Map<String, bool> accessMap = {};
      for (var course in courses) {
        final courseName = course['name'] ?? '';
        final hasAccess = transactions.any((t) =>
            (t['course_name']?.toString().toLowerCase() ?? '') ==
            courseName.toString().toLowerCase());
        accessMap[courseName] = hasAccess;
      }

      setState(() {
        _courses = courses;
        hasAccessMap = accessMap;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat kelas dan transaksi')),
      );
    }
  }

  Future<List<Map<String, dynamic>>> getUserTransactions(String token) async {
    final baseUrl = 'https://codeinko.com/api';
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Kembali', style: TextStyle(color: Colors.black)),
          leading: const BackButton(color: Colors.black),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kembali', style: TextStyle(color: Colors.black)),
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _courses.isEmpty
            ? const Center(child: Text("Tidak ada course tersedia"))
            : ListView(
                children: [
                  const SizedBox(height: 12),
                  const Text(
                    'Kelas yang tersedia',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Jelajahi berbagai pilihan kelas dan tingkatkan keterampilan anda.',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _courses.length,
                    itemBuilder: (context, index) {
                      final course = _courses[index];
                      final String courseTitle = course['name'] ?? 'Tanpa Judul';
                      final int price = int.tryParse(course['price'].toString()) ?? 0;
                      final String thumbnail = course['thumbnail'] ?? '';
                      final String mentor = course['mentor'] ?? 'Mentor Tidak Diketahui';
                      final String imageUrl = 'https://codeinko.com/storage/$thumbnail';
                      final bool isActive = hasAccessMap[courseTitle] ?? false;

                      return _buildCourseItem(
                        context,
                        imageUrl,
                        courseTitle,
                        price,
                        mentor,
                        isActive,
                        course,
                        widget.token,
                        key: ValueKey('$courseTitle-$index'),
                      );
                    },
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCourseItem(
    BuildContext context,
    String imageUrl,
    String title,
    int price,
    String mentor,
    bool isActive,
    Map<String, dynamic> course,
    String token, {
    Key? key,
  }) {
    final Map<String, dynamic> checkoutData = {
      'course_name': title,
      'hargaAwal': price,
      'mentor': mentor,
    };

    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: 100,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100,
                  height: 80,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 40),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Rp. $price', style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 6),
                SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    onPressed: () {
                      if (isActive) {
                        Navigator.pushNamed(context, '/dashboard');
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutPage(
                              token: token,
                              checkoutData: checkoutData,
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isActive ? Colors.green : const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isActive ? 'Paid' : 'Beli',
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
