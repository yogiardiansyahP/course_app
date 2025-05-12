import 'package:flutter/material.dart';
import 'package:project_akhir_app/hubungi_kami.dart';
import 'package:project_akhir_app/user.dart';

class TentangScreen extends StatelessWidget {
  final String token;

  const TentangScreen({super.key, required this.token});

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
          ),
          const Divider(),
            title: const Text("Tentang Kami"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CodeinCourseApp(token: token)),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text("Hubungi Kami"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HubungiKamiPage()),
              );
            },
          ),
          const Divider(height: 1),
          const ListTile(
            title: Text("Versi App"),
            trailing: Text("1.0.0"),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text("Keluar", style: TextStyle(color: Colors.red)),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Konfirmasi"),
                  content: const Text("Apakah kamu yakin ingin keluar?"),
                  actions: [
            const Spacer(),
            // Card konten
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
