import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';
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
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late String courseName;
  late int hargaAwal;
  late String courseMentor;
  late int courseId;

  bool _showMidtransWebView = false;
  String? _snapUrl;

  late final WebViewController _controller;

  bool _hasNavigatedToSuccess = false;

  @override
  void initState() {
    super.initState();

    courseName = widget.checkoutData['course_name'] ?? '';
    hargaAwal = widget.checkoutData['hargaAwal'] ?? 0;
    courseMentor = widget.checkoutData['mentor'] ?? '';
    courseId = widget.checkoutData['id'] ?? 0;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: _handleNavigation,
        ),
      );
  }

  Future<void> _handlePayment() async {
  try {
    final apiService = ApiService();
    final response = await apiService.getSnapToken(
      token: widget.token,
      hargaAwal: hargaAwal,
      courseName: courseName,
      voucher: '',
      courseId: courseId,
    );

    final snapToken = response['token'];
    final orderId = response['order_id'];
    _snapUrl = 'https://app.sandbox.midtrans.com/snap/v2/vtweb/$snapToken';

    final transactionData = {
      'order_id': orderId,
      'hargaAwal': hargaAwal,
      'hargaDiskon': 0,
      'voucher': '',
      'course_name': courseName,
      'status': 'pending',
    };

    await apiService.saveTransaction(widget.token, transactionData);

    if (kIsWeb) {
      final uri = Uri.parse(_snapUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        setState(() => _showMidtransWebView = false);
        Navigator.pushNamedAndRemoveUntil(context, '/kelas', (route) => false);
      }
    } else {
      if (Platform.isAndroid || Platform.isIOS) {
        _controller.loadRequest(Uri.parse(_snapUrl!));
        setState(() {
          _showMidtransWebView = true;
        });
      }
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal melakukan pembayaran: $e')),
    );
  }
}


  bool isSuccessNavigation(String url) {
    try {
      final uri = Uri.parse(url);
      final orderId = uri.queryParameters['order_id'] ?? '';
      return uri.path == '/payment/success' &&
          uri.queryParameters['transaction_status'] == 'settlement' &&
          orderId.startsWith('ORDER-');
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveTransactionToApi(String orderId, String status) async {
    final apiService = ApiService();

    final transactionData = {
      'order_id': orderId,
      'user_id': await apiService.getUserId(),
      'hargaAwal': hargaAwal,
      'hargaDiskon': 0,
      'voucher': '',
      'course_name': courseName,
      'status': status,
    };

    try {
      final result = await apiService.saveTransaction(widget.token, transactionData);
      if (result['message'] == 'Transaction saved successfully.') {
        // transaksi berhasil disimpan
      }
    } catch (e) {
      print('Error simpan transaksi: $e');
    }
  }

  NavigationDecision _handleNavigation(NavigationRequest request) {
    final url = request.url;

    if (isSuccessNavigation(url) && !_hasNavigatedToSuccess) {
      _hasNavigatedToSuccess = true;

      final uri = Uri.parse(url);
      final orderId = uri.queryParameters['order_id'] ?? '';

      _saveTransactionToApi(orderId, 'settlement');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pembayaran berhasil')),
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Pembayaran Berhasil'),
            content: const Text(
                'Anda telah berhasil melakukan pembayaran. Apakah Anda ingin menuju ke halaman Pelajaran?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Tidak'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Ya'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, '/list-kelas');
                },
              ),
            ],
          );
        },
      );

      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  Future<void> _reloadWebView() async {
    if (_snapUrl != null) {
      final currentUrl = await _controller.currentUrl();
      if (currentUrl != null && isSuccessNavigation(currentUrl)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pembayaran telah berhasil')),
        );
      } else {
        _controller.reload();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showMidtransWebView && _snapUrl != null) {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('CodeIn'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _showMidtransWebView = false;
                });
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _reloadWebView,
              ),
            ],
          ),
          body: WebViewWidget(controller: _controller),
        );
      }
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran - CodeIn'),
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _buildMainContent(),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/kelas', (route) => false);
            },
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
            Container(
              width: 100,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[300],
              ),
              child: const Icon(Icons.menu_book, size: 40),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(courseName, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Rp. ${_formatRupiah(hargaAwal)}'),
                Text('Course ID: $courseId', style: const TextStyle(fontSize: 12)),
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
        _detailRow('Harga', 'Rp. ${_formatRupiah(hargaAwal)}'),
        _detailRow('Total Bayarr', 'Rp. ${_formatRupiah(hargaAwal)}'),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _handlePayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Bayar Sekarang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _paymentMethodTile(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(title, style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatRupiah(int number) {
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0);
    return formatCurrency.format(number);
  }
}