import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:iamport_webview_flutter/iamport_webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';

class CheckoutPage extends StatefulWidget {
  final String token;
  final Map<String, dynamic> checkoutData;

  const CheckoutPage({
    super.key,
    required this.token,
    required this.checkoutData,
  });

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

  bool _showMidtransWebView = false;
  String? _snapUrl;

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
        final String thumbnail = course['thumbnail'] ?? '';
        final String imageUrl = 'https://codeinko.com/storage/$thumbnail';

        setState(() {
          courseName = course['name'];
          hargaAwal = int.parse(course['price'].toString());
          voucher = '';
          hargaDiskon = hargaAwal;
          courseThumbnail = imageUrl;
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

  Future<void> _handlePayment() async {
    try {
      final apiService = ApiService();
      final response = await apiService.getSnapToken(
        token: widget.token,
        hargaAwal: hargaDiskon,
        courseName: courseName,
        voucher: voucher,
        courseId: courseId,
      );

      final snapToken = response['token'];
      final orderId = response['order_id'];

      _snapUrl = 'https://app.sandbox.midtrans.com/snap/v2/vtweb/$snapToken';

      setState(() {
        _showMidtransWebView = true;
      });
    } catch (e) {
      print('Gagal melakukan pembayaran: $e');
    }
  }

  NavigationDecision _handleNavigation(NavigationRequest request) {
    final url = request.url;
    if (url.contains('finish') || url.contains('pending') || url.contains('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pembayaran selesai')),
      );

      setState(() {
        _showMidtransWebView = false;
      });

      Navigator.pushNamedAndRemoveUntil(context, '/kelas', (route) => false);

      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_showMidtransWebView && _snapUrl != null) {
      if (kIsWeb) {
        Future.microtask(() async {
          final uri = Uri.parse(_snapUrl!);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            setState(() {
              _showMidtransWebView = false;
            });
            Navigator.pushNamedAndRemoveUntil(context, '/kelas', (route) => false);
          }
        });
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      } else if (Platform.isAndroid || Platform.isIOS) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Pembayaran'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _showMidtransWebView = false;
                });
              },
            ),
          ),
          body: IamportWebView(
            initialUrl: _snapUrl!,
            javascriptMode: JavascriptMode.unrestricted,
            navigationDelegate: (request) => _handleNavigation(request),
          ),
        );
      }
    }

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
                onPressed: _handlePayment,
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
  
  IamportWebView({required String initialUrl, required JavascriptMode javascriptMode, required NavigationDecision Function(dynamic request) navigationDelegate}) {}
}
