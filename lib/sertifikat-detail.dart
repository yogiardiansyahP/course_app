import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

class CertificateDetailPage extends StatelessWidget {
  final Map<String, dynamic> certificate;

  const CertificateDetailPage({super.key, required this.certificate});

  @override
  Widget build(BuildContext context) {
    final courseTitle = certificate['title'] ?? '-';
    final certId = certificate['id']?.toString() ?? '-';
    final generatedAt = certificate['issued_at'] ?? '-';

    final pdfUrl = 'https://codeinko.com/storage/${certificate['certificate_path']}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Sertifikat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text('Nama Course: $courseTitle', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Text('ID Sertifikat: $certId', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Text('Tanggal Pembuatan: $generatedAt', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 25),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PdfViewerPage(pdfUrl: pdfUrl),
                      ),
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Lihat Sertifikat PDF'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PdfViewerPage extends StatelessWidget {
  final String pdfUrl;

  const PdfViewerPage({super.key, required this.pdfUrl});

  Future<void> _downloadPdf() async {
    final Uri uri = Uri.parse(pdfUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $pdfUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lihat Sertifikat PDF'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Download PDF',
            onPressed: _downloadPdf,
          ),
        ],
      ),
      body: SfPdfViewer.network(
        pdfUrl,
        onDocumentLoadFailed: (details) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memuat PDF: ${details.description}')),
          );
        },
      ),
    );
  }
}
