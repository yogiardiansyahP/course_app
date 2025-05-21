import 'package:flutter/material.dart';
import 'package:project_akhir_app/sertifikat-view.dart';
 // Pastikan Anda mengganti ini sesuai dengan file yang sesuai

class CertificatePage extends StatelessWidget {
  final String courseName;
  final int courseId;
  final String issueDate;
  final String certificateUrl;

  const CertificatePage({
    required this.courseName,
    required this.courseId,
    required this.issueDate,
    required this.certificateUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sertifikat'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // kembali ke halaman sebelumnya
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Sertifikat',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kursus: $courseName',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'ID: $courseId',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Diterbitkan: $issueDate',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CertificateViewerPage(certificateUrl: certificateUrl),
                        ),
                      );
                    },
                    child: const Text('Lihat Sertifikat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
