import 'package:flutter/material.dart';
import 'package:project_akhir_app/tentang_kami.dart';
import 'package:project_akhir_app/course.dart';
import 'package:project_akhir_app/hubungi_kami.dart';
import 'package:project_akhir_app/sertifikat.dart';
import 'package:project_akhir_app/login.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle(color: Colors.grey[700]);
    Color backgroundColor = Colors.grey[300]!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Akun saya'),
        backgroundColor: backgroundColor,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info container
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("yogi ardiansyah pratama", style: TextStyle(fontSize: 16)),
                Text("yogi@gmail.com", style: textStyle),
              ],
            ),
          ),
          Divider(),
          
          // Tentang Kami
          ListTile(
            title: Text("Tentang Kami"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TentangScreen()),
              );
            },
          ),
          Divider(height: 1),
          
          // Hubungi Kami
          ListTile(
            title: Text("Hubungi Kami"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HubungiKamiPage()),
              );
            },
          ),
          Divider(height: 1),
          ListTile(
            title: Text("Course Saya"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CourseListPage()),
              );
            },
          ),
          Divider(height: 1),
          ListTile(
            title: Text("Sertifikat Saya"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CertificatePage()),
              );
            },
          ),
          Divider(height: 1),
          
          // App version
          ListTile(
            title: Text("Versi App"),
            trailing: Text("1.0.0"),
          ),
          Divider(height: 1),
          
          // Logout
          ListTile(
            title: Text("Keluar", style: TextStyle(color: Colors.red)),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text("Konfirmasi"),
                  content: Text("Apakah kamu yakin ingin keluar?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Batal"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                          (route) => false,
                        );
                      },
                      child: Text("Keluar", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
          Divider(height: 1),
        ],
      ),
    );
  }
}