import 'package:flutter/material.dart';
import 'package:project_akhir_app/login.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CourseListPage(),
  ));
}

class CourseListPage extends StatelessWidget {
  const CourseListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
             Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Image.asset('asset/image/logo.png', width: 32),
    IconButton(
      icon: const Icon(Icons.login),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      },
    ),
  ],
),

              const SizedBox(height: 12),
              const Text(
                "Selamat datang di code in app,\nSilahkan login terlebih dahulu",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 23
                  ,
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
                child: ListView.builder(
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return CourseCard();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  const CourseCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(
              'assets/course.jpg', // Ganti dengan asset kamu
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,errorBuilder: (context, error, stackTrace) {
    return Container(
      width: 400,
      height: 150,
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
              children: const [
                Text(
                  "Belajar Java Script Dari Nol",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  "Rp. 2.500.000",
                  style: TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Rp. 250.000",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
