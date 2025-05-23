import 'package:flutter/material.dart';
import 'package:project_akhir_app/services/api_service.dart';
import 'package:project_akhir_app/profil.dart';
import 'package:project_akhir_app/checkout.dart';
import 'package:intl/intl.dart';

class CodeinCourseApp extends StatelessWidget {
  final String token;

  const CodeinCourseApp({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Codein Course',
      theme: ThemeData(fontFamily: 'Inter'),
      home: CourseHomePage(token: token),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CourseHomePage extends StatefulWidget {
  final String token;

  const CourseHomePage({super.key, required this.token});

  @override
  _CourseHomePageState createState() => _CourseHomePageState();
}

class _CourseHomePageState extends State<CourseHomePage> {
  late Future<List<dynamic>> _coursesFuture;

  @override
  void initState() {
    super.initState();
    _coursesFuture = _fetchCourses();
  }

  Future<List<dynamic>> _fetchCourses() async {
    try {
      ApiService apiService = ApiService();
      final courses = await apiService.getCoursesFromApi(widget.token);
      return courses;
    } catch (e) {
      throw Exception('Failed to load courses: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.person_outline),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfilScreen()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text("Gabung Kelas Unggulan Codein Course",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            FutureBuilder<List<dynamic>>(
              future: _coursesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text("Tidak ada course tersedia");
                } else {
                  final courses = snapshot.data!;
                  return Column(
                    children: courses.map<Widget>((course) {
                      final String courseTitle = course['name'] ?? 'Course Tanpa Nama';
                      final dynamic priceData = course['price'];
                      final int originalPrice = priceData is int
                          ? priceData
                          : int.tryParse(priceData.toString()) ?? 0;
                      final String thumbnail = course['thumbnail'] ?? '';
                      final String mentor = course['mentor'] ?? 'Mentor Tidak Diketahui';
                      final int id = course['id'] ?? 0;

                      return _courseCard(
                        context,
                        id,
                        courseTitle,
                        originalPrice,
                        thumbnail,
                        mentor,
                        widget.token,
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _courseCard(
    BuildContext context,
    int id,
    String courseTitle,
    int originalPrice,
    String thumbnail,
    String mentor,
    String token,
  ) {
    final Map<String, dynamic> checkoutData = {
      'id': id,
      'course_name': courseTitle,
      'hargaAwal': originalPrice,
      'mentor': mentor,
    };

    final String imageUrl = 'https://codeinko.com/storage/$thumbnail';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CheckoutPage(
              token: token,
              checkoutData: checkoutData,
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
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                          ),
                        );
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
                  Text(courseTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(
                    mentor,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Course ID: $id",
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Rp. ${_formatRupiah(originalPrice)}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatRupiah(int value) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(value);
  }
}
