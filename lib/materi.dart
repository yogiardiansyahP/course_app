import 'package:flutter/material.dart';


class VideoLessonPage extends StatelessWidget {
  const VideoLessonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tombol kembali
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(
                  children: const [
                    Icon(Icons.arrow_back, size: 20),
                    SizedBox(width: 5),
                    Text("Kembali", style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Judul
              const Text(
                "Belajar java script dari nol",
                style: TextStyle(
                  color: Color(0xFF3366FF),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Subjudul
              const Text(
                "Variabel dan tipe data (vtd) Part 1-2",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),

              // Gambar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF3366FF), width: 2),
                  ),
                  child: Image.asset(
                    'assets/images/video_thumbnail.jpg', // ganti sesuai path Anda
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Deskripsi file
              const Text(
                "File variabel dan tipe data (vtd) Part 1-2",
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 5),

              // Tautan laporkan
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

              // Tombol navigasi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3366FF),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_back,color: Colors.white),
                    label: const Text("Kembali",style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3366FF),
                    ),
                    onPressed: () {},
                    icon: const Text("Selanjutnya",style: TextStyle(color: Colors.white)),
                    label: const Icon(Icons.arrow_forward,color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
