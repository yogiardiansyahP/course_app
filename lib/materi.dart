import 'package:flutter/material.dart';

class VideoLessonPage extends StatelessWidget {
  const VideoLessonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Belajar java script dari nol",
                style: TextStyle(
                  color: Color(0xFF3366FF),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                "Variabel dan tipe data (vtd) Part 1-2",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),

              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF3366FF), width: 2),
                  ),
                  child: Image.asset(
                    'asset/image/vidio.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 500,
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 40),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),

              const Text(
                "File variabel dan tipe data (vtd) Part 1-2",
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 5),

              Row(
                children: const [
                  Text("Ada masalah dengan konten ini? "),
                  Text(
                    "Laporkan",
                    style: TextStyle(
                      color: Colors.red,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
              const Spacer(),

              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3366FF),
                  ),
                  onPressed: () {
                    // TODO: Implement "next" lesson navigation
                  },
                  icon: const Text("Selanjutnya", style: TextStyle(color: Colors.white)),
                  label: const Icon(Icons.arrow_forward, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
