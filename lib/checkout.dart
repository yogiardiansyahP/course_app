import 'package:flutter/material.dart';
import 'package:midtrans_snap/midtrans_snap.dart';
import 'package:midtrans_snap/models.dart';
import 'dart:convert';
import '../services/api_service.dart';

class CheckoutPage extends StatelessWidget {
  final String token;

  CheckoutPage({super.key, required this.token, required Map<String, dynamic> checkoutData});

  final int hargaAwal = 2500000;
  final String courseName = 'Belajar Java Script Dari Nol';
  final String voucher = 'CODEINCOURSEIDNBGR';
  final String clientKey = 'SB-Mid-client-OTstuStuahPgY8tT';

  Future<void> _handlePayment(BuildContext context) async {
    try {
      final apiService = ApiService();
      final response = await apiService.postData(
        '/get-snap-token',
        {
          'hargaAwal': hargaAwal,
          'course_name': courseName,
          'voucher': voucher,
        },
        token: token,
        useSnapTokenBaseUrl: true,
      );

      if (response.statusCode == 200) {
        final snapToken = jsonDecode(response.body)['token'];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MidtransSnap(
              mode: MidtransEnvironment.sandbox,
              token: snapToken,
              midtransClientKey: clientKey,
              onPageFinished: (url) => print('Page finished: $url'),
              onPageStarted: (url) => print('Page started: $url'),
              onResponse: (result) {
                print('Midtrans Result: ${result.toJson()}');
                Navigator.pop(context);
              },
            ),
          ),
        );
      } else {
        print('Gagal mendapatkan token: ${response.body}');
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Kelas', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/course-image-placeholder.png',
                    width: 100,
                    height: 70,
                    fit: BoxFit.cover,errorBuilder: (context, error, stackTrace) {
    return Container(
      width: 100,
      height: 70,
      color: Colors.grey[300],
      child: const Icon(Icons.broken_image, size: 40),
    );
  },
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Belajar Java Script Dari Nol', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Rp. 2.500.000', style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.red)),
                    Text('Rp. 250.000'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _paymentMethodTile(Icons.account_balance, 'Bank Transfer'),
            const SizedBox(height: 8),
            _paymentMethodTile(Icons.account_balance_wallet, 'OVO'),
            const SizedBox(height: 8),
            _paymentMethodTile(Icons.qr_code, 'QRIS'),
            const SizedBox(height: 24),
            const Text('Rincian Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            _detailRow('Course', 'Belajar Java Script Dari Nol'),
            _detailRow('Mentor', 'Ervan'),
            _detailRow('Harga', 'Rp 2.500.000'),
            _detailRow('Diskon', '-Rp 250.000'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => _handlePayment(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF60A5FA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Bayar Sekarang', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _paymentMethodTile(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 30),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  static Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
