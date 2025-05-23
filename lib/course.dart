import 'package:flutter/material.dart';
import 'package:project_akhir_app/materi.dart';
import 'package:project_akhir_app/kelas.dart';
import 'package:project_akhir_app/services/api_service.dart';
import 'package:project_akhir_app/profil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CourseList extends StatefulWidget {
  const CourseList({super.key});

  @override
  _CourseListPageState createState() => _CourseListPageState();
}

class _CourseListPageState extends State<CourseList> {
  Future<List<Map<String, dynamic>>>? futurePurchasedCourses;
  String? token;

  @override
  void initState() {
    super.initState();
    loadPurchasedCourses();
  }

  Future<void> loadPurchasedCourses() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token tidak ditemukan');
    }

    final apiService = ApiService();

    try {
      final coursesRaw = await apiService.getCoursesFromApi(token!);
      print('Raw courses from API: $coursesRaw');

      setState(() {
        futurePurchasedCourses = Future.value(
          coursesRaw.map<Map<String, dynamic>>((course) {
            print('Course item: $course');
            return {
              'id': course['id'],
              'courseId': course['id'],  // Pastikan ini ada dan benar
              'name': course['name'],
              'thumbnail': course['thumbnail'],
              'mentor': course['mentor'],
              'price': course['price'],
              'materials': course['materials'],
              'hasAccess': true,
            };
          }).toList(),
        );
      });
    } catch (e) {
      print('Error saat load courses: $e');
      setState(() {
        futurePurchasedCourses = Future.error(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ProfilScreen()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'asset/image/logo.png',
                  width: 60,
                  height: 60,
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
              const SizedBox(height: 20),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => KelasPage(token: token!)),
                      );
                    },
                    child: Chip(
                      label: const Text(
                        "Lihat Lebih Banyak Kelass",
                        style: TextStyle(fontSize: 9.5),
                      ),
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CourseList()),
                      );
                    },
                    child: Chip(
                      label: const Text(
                        "Kursus yang sedang di pelajari",
                        style: TextStyle(color: Colors.white, fontSize: 9.5),
                      ),
                      backgroundColor: const Color(0xFF3B82F6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: futurePurchasedCourses,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Belum ada kursus yang dibeli.'));
                  }

                  final courses = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      return _buildCourseCard(context, course);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, Map<String, dynamic> course) {
    final imageUrl = 'https://codeinko.com/storage/${course['thumbnail'] ?? ''}';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 400,
                  height: 180,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 40),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course['name'] ?? 'Nama Course',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${course['courseId'] ?? 'null'}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 8),
                // Tombol hanya tampil jika sudah bayar (hasAccess true)
                if (course['hasAccess'] == true)
                  ElevatedButton(
                    onPressed: () {
                    final rawMaterials = course['materials'];
                    if (rawMaterials is List && rawMaterials.isNotEmpty) {
                      final List<Map<String, String>> materials = rawMaterials.map<Map<String, String>>((m) {
                        return {
                          'slug': m['slug'] ?? '',
                          'title': m['title'] ?? '',
                          'video_url': m['video_url'] ?? '',
                          'description': m['description'] ?? '',
                          'nama_materi': m['title'] ?? '',
                        };
                      }).toList();

                      final String currentSlug = materials[0]['slug'] ?? '';

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseMaterialPage(
                            courseName: course['name'] ?? '',
                            materials: materials,
                            currentSlug: currentSlug,
                            status: 'settlement', // atau bisa disesuaikan dengan course['status'] jika ada
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Materi belum tersedia untuk kursus ini.")),
                      );
                    }
                  },

                      style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF60A5FA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: const Text(
                      "Lanjutkan Belajar",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                else
                  const Text(
                    "Anda belum membeli kursus ini.",
                    style: TextStyle(color: Colors.redAccent),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
