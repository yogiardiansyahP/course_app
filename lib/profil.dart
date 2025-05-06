import 'package:flutter/material.dart';

class ProfilScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Akun saya'), backgroundColor: Colors.grey[300]),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.grey[300],
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("yogi ardiansyah pratama", style: TextStyle(fontSize: 16)),
                Text("yogi@gmail.com", style: TextStyle(color: Colors.grey[700])),
              ],
            ),
          ),
          Divider(),
          ListTile(
            title: Text("Tentang Kami"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.pushNamed(context, '/tentang'),
          ),
          Divider(height: 1),
          ListTile(
            title: Text("Hubungi Kami"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.pushNamed(context, '/hubungi'),
          ),
          Divider(height: 1),
          ListTile(
            title: Text("Versi App"),
            trailing: Text("1.0.0"),
          ),
          Divider(height: 1),
          ListTile(
            title: Text("Keluar", style: TextStyle(color: Colors.red)),
            onTap: () {
              // Simulasi logout
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text("Konfirmasi"),
                  content: Text("Apakah kamu yakin ingin keluar?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal")),
                    TextButton(
                      onPressed: () {
  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
