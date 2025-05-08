import 'package:flutter/material.dart';
import 'package:project_akhir_app/checkout.dart';
import 'package:project_akhir_app/kelas.dart';

class KelasPage extends StatelessWidget {
  const KelasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kembali', style: TextStyle(color: Colors.black)),
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
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

            // List Course Cards
            ..._courseList.map((course) => _buildCourseItem(context, course)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseItem(BuildContext context, Map<String, String> course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
  course['image']!,
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
)

          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Belajar Java Script Dari Nol',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Rp. 2.500.000',
                  style: TextStyle(
                    color: Colors.red,
                    decoration: TextDecoration.lineThrough,
                    fontSize: 12,
                  ),
                ),
                const Text(
                  'Rp. 250.000',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 6),
                SizedBox(
  height: 32,
  child: ElevatedButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CheckoutPage()),
      );
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF2563EB),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    child: const Text(
      'Beli',
      style: TextStyle(fontSize: 12, color: Colors.white),
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

final List<Map<String, String>> _courseList = [
  {'image': 'assets/image/vidio.png'},
  {'image': 'assets/image/figma.png'},
  {'image': 'assets/image/laravel.png'},
  {'image': 'assets/image/python.png'},
  {'image': 'assets/image/sql.png'},
];
