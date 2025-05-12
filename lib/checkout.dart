import 'package:flutter/material.dart';
import 'package:midtrans_snap/midtrans_snap.dart';
import 'package:midtrans_snap/models.dart';
import '../services/api_service.dart';
import 'package:project_akhir_app/course.dart';

class CheckoutPage extends StatefulWidget {
  final String token;
  const CheckoutPage({super.key, required this.token, required Map<String, dynamic> checkoutData});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late String courseName;
  late int hargaAwal;
  late String voucher;
  late String clientKey;
  late String courseThumbnail;
  late String courseMentor;

  @override
  void initState() {
    super.initState();
    _loadCourseData();
  }

  Future<void> _loadCourseData() async {
    try {
      final apiService = ApiService();
      final courses = await apiService.getCoursesFromApi(widget.token);
      if (courses.isNotEmpty) {
        final course = courses[0]; // Assuming we are showing the first course
        setState(() {
          courseName = course['name'];
          hargaAwal = course['price'];
          voucher = 'CODEINCOURSEIDNBGR'; // Adjust if necessary
          clientKey = 'SB-Mid-client-OTstuStuahPgY8tT'; // Your Midtrans client key
          courseThumbnail = course['thumbnail'];
          courseMentor = course['mentor'];
        });
      }
    } catch (e) {
      print('Error loading course data: $e');
    }
  }

Future<void> _handlePayment(BuildContext context) async {
  try {
    final apiService = ApiService();

    // Mengambil Snap Token menggunakan metode getSnapToken
    final snapTokenResponse = await apiService.getSnapToken(
      token: widget.token,
      courseId: 1, // ID Kursus yang sesuai, ganti dengan ID kursus yang relevan
      hargaAwal: hargaAwal,
      voucher: voucher,
      courseName: courseName,
    );

    // Mendapatkan snap token
    final snapToken = snapTokenResponse['token'];

    // Print token Snap yang diterima
    print('Snap Token: $snapToken');

    // Menambahkan logika pembayaran Midtrans Snap
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
            // Print hasil dari transaksi Midtrans
            print('Midtrans Result: ${result.toJson()}');
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CourseListPage()),
            );
          },
        ),
      ),
    );
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
      body: hargaAwal == 0
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Kelas', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          courseThumbnail,
                          width: 100,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
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
                        children: [
                          Text(courseName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('Rp. ${hargaAwal.toString()}',
                              style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.red)),
                          Text('Rp. ${hargaAwal - 250000}'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Metode Pembayaran',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  _paymentMethodTile(Icons.account_balance, 'Bank Transfer'),
                  const SizedBox(height: 8),
                  _paymentMethodTile(Icons.account_balance_wallet, 'OVO'),
                  const SizedBox(height: 8),
                  _paymentMethodTile(Icons.qr_code, 'QRIS'),
                  const SizedBox(height: 24),
                  const Text(
                    'Rincian Pembayaran',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  _detailRow('Course', courseName),
                  _detailRow('Mentor', courseMentor),
                  _detailRow('Harga', 'Rp. ${hargaAwal}'),
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
