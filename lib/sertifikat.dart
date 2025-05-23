import 'package:flutter/material.dart';
import 'package:project_akhir_app/sertifikat-detail.dart';  // ganti nama import sesuai file yang benar
import 'package:project_akhir_app/services/api_service.dart';

class CertificateDashboardPage extends StatefulWidget {
  final String token; // token harus dikirim ke page ini

  const CertificateDashboardPage({super.key, required this.token});

  @override
  State<CertificateDashboardPage> createState() => _CertificateDashboardPageState();
}

class _CertificateDashboardPageState extends State<CertificateDashboardPage> {
  List<dynamic> certificates = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCertificates();
  }

  Future<void> fetchCertificates() async {
    try {
      final fetchedCertificates = await ApiService().fetchCertificates(widget.token);
      setState(() {
        certificates = fetchedCertificates;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat sertifikat: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sertifikat'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: certificates.isEmpty
                  ? const Center(child: Text("Tidak ada sertifikat"))
                  : ListView.builder(
                      itemCount: certificates.length,
                      itemBuilder: (context, index) {
                        final cert = certificates[index];
                        final course = cert['course'];
                        final issuedAt = cert['issued_at'] ?? '-';
                        final courseName = course?['name'] ?? 'Course tidak tersedia';
                        final certPath = cert['certificate_path'];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(courseName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Text("ID: ${cert['id']}"),
                                Text("Diterbitkan: $issuedAt"),
                                const SizedBox(height: 12),
                                certPath != null
                                    ? ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => CertificateDetailPage(
                                                certificate: cert,
                                              ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          minimumSize: const Size(double.infinity, 45),
                                        ),
                                        child: const Text("Lihat Sertifikat"),
                                      )
                                    : const Text("Belum tersedia", style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
