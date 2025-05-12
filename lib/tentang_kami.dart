import 'package:flutter/material.dart';
import 'package:project_akhir_app/hubungi_kami.dart';

class TentangScreen extends StatelessWidget {
  const TentangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4F85FF),
      body: SafeArea(
        child: Column(
          children: [
            // Tombol kembali
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.arrow_back, color: Colors.white),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Kembali',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Card konten
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // Header dengan logo CSS & HTML
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          'assets/css.png',
                          height: 32,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 32,
                              height: 32,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, size: 20),
                            );
                          },
                        ),
                        const Text(
                          'Tentang Kami',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Image.asset(
                          'assets/html.png',
                          height: 32,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 32,
                              height: 32,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, size: 20),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'CodeIn Course adalah platform pembelajaran digital yang dirancang '
                      'untuk memudahkan kamu belajar di bidang teknologi dan dunia digital. '
                      'Kami menawarkan berbagai macam kursus pilihan untuk membantu '
                      'mengembangkan kemampuan, meningkatkan keterampilan, dan siap '
                      'bersaing di dunia profesional.\n\n'
                      'Dengan materi yang up-to-date, instruktur berpengalaman, dan komunitas '
                      'yang suportif, kami berkomitmen jadi teman belajar terbaik kamu. '
                      'Yuk, mulai perjalanan belajar kamu bareng kami.',
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    // Tombol aksi
                    // Tombol aksi
SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HubungiKamiPage()),
      );
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF3366FF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
    ),
    child: const Text(
      'Hubungi Aku',
      style: TextStyle(fontSize: 16, color: Colors.white),
    ),
  ),
),

                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Lewati'),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}