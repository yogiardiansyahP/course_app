import 'package:flutter/material.dart';
import 'package:project_akhir_app/materi.dart';
import 'package:project_akhir_app/kelas.dart';

class CourseListPage extends StatelessWidget {
  const CourseListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Center(
                child: Image.asset(
                  'assets/logo.png', 
                  width: 60,
                  height: 60,
                ),
              ),
              const SizedBox(height: 20),

              // Chips
              // Chips dalam Row
Row(
  children: [
    InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>  KelasPage()),
        );
      },
      child: Chip(
        label: const Text(
          "Lihat Lebih Banyak Kelas",
          style: TextStyle(fontSize: 11.5),
        ),
        backgroundColor: Colors.grey.shade200,
      ),
    ),
    const SizedBox(width: 8),
    Chip(
      label: const Text(
        "Kursus yang sedang di pelajari",
        style: TextStyle(color: Colors.white, fontSize: 11.5),
      ),
      backgroundColor: const Color(0xFF3B82F6),
    ),
  ],
),


              const SizedBox(height: 20),

              // List of Courses
              _buildCourseCard(context),
              const SizedBox(height: 16),
              _buildCourseCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              'asset/image/vidio.png',
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Belajar Java Script Dari Nol",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VideoLessonPage()),
    );
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
),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
