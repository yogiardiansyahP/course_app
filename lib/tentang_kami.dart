import 'package:flutter/material.dart';
import 'package:project_akhir_app/hubungi_kami.dart';

import 'package:project_akhir_app/user.dart';

class TentangScreen extends StatelessWidget {
  const TentangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Akun saya'),
        backgroundColor: Colors.grey[300],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.grey[300],
            padding: const EdgeInsets.all(16),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("yogi ardiansyah pratama", style: TextStyle(fontSize: 16)),
                Text("yogi@gmail.com", style: TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text("Tentang Kami"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CodeinCourseApp()),
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
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Batal"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      },
                      child: const Text("Keluar", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
