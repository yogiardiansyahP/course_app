import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/midtrans_webview.dart';

class CheckoutPage extends StatefulWidget {
  final String token;
  const CheckoutPage({super.key, required this.token, required Map<String, dynamic> checkoutData});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late String courseName;
  late int hargaAwal;
  late int hargaDiskon;
  late String voucher;
  late String courseThumbnail;
  late String courseMentor;
  late int courseId;
  bool _loading = true;
  final TextEditingController _voucherController = TextEditingController();

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
        final course = courses[0];
        setState(() {
          courseName = course['name'];
          hargaAwal = course['price'];
          voucher = '';
          hargaDiskon = hargaAwal;
          courseThumbnail = course['thumbnail'];
          courseMentor = course['mentor'];
          courseId = course['id'];
          _loading = false;
        });
      }
    } catch (e) {
      print('Error loading course data: $e');
    }
  }

  Future<void> _applyVoucher() async {
    setState(() {
      voucher = _voucherController.text.trim();
      if (voucher == 'CODEINCOURSEIDNBGR') {
        hargaDiskon = 395000;
      } else {
        hargaDiskon = hargaAwal;
      }
    });
  }

  Future<void> _handlePayment(BuildContext context) async {
    try {
      final apiService = ApiService();
      final response = await apiService.getSnapToken(
        token: widget.token,
        hargaAwal: hargaAwal,
        courseName: courseName,
        voucher: voucher,
        courseId: courseId,
      );

      final snapToken = response['token'];
      final orderId = response['order_id'];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MidtransWebViewPage(
            snapToken: snapToken,
            token: widget.token,
            transactionData: {
              'order_id': orderId,
              'hargaAwal': hargaAwal,
              'hargaDiskon': hargaDiskon,
              'voucher': voucher,
              'course_name': courseName,
              'status': 'pending',
            },
            onPaymentFinish: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment Success'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pushNamedAndRemoveUntil(context, '/kelas', (route) => false);
            },
          ),
        ),
      );
    } catch (e) {
      print('Gagal melakukan pembayaran: $e');
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
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
                          if (hargaDiskon < hargaAwal)
                            Text('Rp. $hargaAwal',
                                style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.red)),
                          Text('Rp. $hargaDiskon'),
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
                  _detailRow('Course', courseName),
                  _detailRow('Mentor', courseMentor),
                  _detailRow('Harga', 'Rp. $hargaAwal'),
                  _detailRow('Diskon', '-Rp ${hargaAwal - hargaDiskon}'),
                  _detailRow('Total Bayar', 'Rp. $hargaDiskon'),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _voucherController,
                    decoration: InputDecoration(
                      labelText: 'Masukkan Voucher',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: _applyVoucher,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _handlePayment(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF60A5FA),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
