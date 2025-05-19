import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import the url_launcher package

class HubungiKamiPage extends StatelessWidget {
  const HubungiKamiPage({super.key});

  // Function to launch WhatsApp chat
  Future<void> _launchWhatsApp() async {
    final url = Uri.parse('https://wa.me/6285779303395'); // WhatsApp link with phone number
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url); // Open WhatsApp chat
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error: $e');
      // Handle error or show a dialog if needed
    }
  }

  // Function to launch the App Store or Play Store for WhatsApp download
  Future<void> _launchDownload() async {
    const url = 'https://www.whatsapp.com/android?lang=id_ID'; // Google Play Store link for WhatsApp
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri); // Open the store page
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error: $e');
      // Handle error or show a dialog if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hubungi Kami')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              'Ngobrol di WhatsApp dengan\n(62) 857 7930 3395',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _launchWhatsApp, // Call function to launch WhatsApp chat
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Lanjut ke Chat'),
            ),
            const SizedBox(height: 30),
            const Text('Belum menggunakan WhatsApp?'),
            TextButton(
              onPressed: _launchDownload, // Call function to open WhatsApp download link
              child: const Text('Unduh'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _launchDownload, // Same function for the download button
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
              ),
              child: const Text('Unduh'),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
