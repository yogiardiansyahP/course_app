import 'package:flutter/material.dart';
import 'package:project_akhir_app/sertifikat-view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CertificatePage extends StatefulWidget {
  const CertificatePage({super.key});

  @override
  _CertificatePageState createState() => _CertificatePageState();
}

class _CertificatePageState extends State<CertificatePage> {
  List<dynamic> certificates = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCertificates();
  }

  Future<void> fetchCertificates() async {
    try {
      // Replace with your actual API endpoint
      final response = await http.get(Uri.parse('https://codeinko.com/api/certificates'));
      
      if (response.statusCode == 200) {
        setState(() {
          certificates = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load certificates');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sertifikat Saya'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : certificates.isEmpty
              ? const Center(child: Text('Belum ada sertifikat'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: certificates.length,
                  itemBuilder: (context, index) {
                    final cert = certificates[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cert['title'] ?? 'Sertifikat',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Kursus: ${cert['course']['name']}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Diterbitkan: ${cert['issued_at']}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CertificateViewerPage(
                                      certificateUrl: cert['certificate_path'],
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: const Text('Lihat Sertifikat'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}