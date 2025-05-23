import 'package:flutter/material.dart';
import 'package:project_akhir_app/tentang_kami.dart';
import 'package:project_akhir_app/course.dart';
import 'package:project_akhir_app/hubungi_kami.dart';
import 'package:project_akhir_app/sertifikat.dart';
import 'package:project_akhir_app/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  _ProfilScreenState createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  String? token;

  @override
  void initState() {
    super.initState();
    loadToken();
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('token'); // Ganti sesuai key token kamu
    setState(() {
      token = savedToken;
    });
  }

  void navigateTo(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.grey[300]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Akun saya'),
        backgroundColor: backgroundColor,
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Tentang Kami"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => navigateTo(const TentangScreen()),
          ),
          const Divider(height: 1),

          ListTile(
            title: const Text("Hubungi Kami"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => navigateTo(HubungiKamiPage()),
          ),
          const Divider(height: 1),

          ListTile(
            title: const Text("Course Saya"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => navigateTo(CourseList()),
          ),
          const Divider(height: 1),

          ListTile(
            title: const Text("Sertifikat Saya"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: token == null
                ? null
                : () => navigateTo(CertificateDashboardPage(token: token!)),
          ),
          const Divider(height: 1),

          const ListTile(
            title: Text("Versi App"),
            trailing: Text("1.0.0"),
          ),
          const Divider(height: 1),

          ListTile(
            title: const Text("Keluar", style: TextStyle(color: Colors.red)),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Konfirmasi"),
                  content: const Text("Apakah kamu yakin ingin keluar?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Batal"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Keluar", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }
            },
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
