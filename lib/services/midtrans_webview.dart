import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/api_service.dart';

class MidtransWebViewPage extends StatefulWidget {
  final String snapToken;
  final String token;
  final Map<String, dynamic> transactionData;
  final VoidCallback onPaymentFinish;

  const MidtransWebViewPage({
    super.key,
    required this.snapToken,
    required this.token,
    required this.transactionData,
    required this.onPaymentFinish,
  });

  @override
  State<MidtransWebViewPage> createState() => _MidtransWebViewPageState();
}

class _MidtransWebViewPageState extends State<MidtransWebViewPage> {
  WebViewController? _controller;
  bool _transactionSaved = false;

  @override
  void initState() {
    super.initState();
    final snapUrl = 'https://app.sandbox.midtrans.com/snap/v2/vtweb/${widget.snapToken}';
    _saveTransaction('pending');

    if (kIsWeb) {
      _launchInBrowser(snapUrl);
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushNamedAndRemoveUntil(context, '/kelas', (route) => false);
      });
    } else if (Platform.isAndroid) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(snapUrl))
        ..setNavigationDelegate(
          NavigationDelegate(
            onNavigationRequest: (NavigationRequest request) {
              final url = request.url;
              if (url.contains('finish') || url.contains('pending') || url.contains('error')) {
                _updateTransactionStatus('completed');
                Navigator.pushNamedAndRemoveUntil(context, '/kelas', (route) => false);
              }
              return NavigationDecision.navigate;
            },
            onPageFinished: (String url) async {
              if (url.contains('finish') || url.contains('pending') || url.contains('error')) {
                _saveTransaction('completed');
                widget.onPaymentFinish();
                Navigator.pushNamedAndRemoveUntil(context, '/kelas', (route) => false);
              }
            },
          ),
        );
    } else {
      _launchInBrowser(snapUrl);
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushNamedAndRemoveUntil(context, '/kelas', (route) => false);
      });
    }
  }

  Future<void> _launchInBrowser(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<int> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id') ?? 0;
  }

  Future<void> _saveTransaction(String status) async {
    if (_transactionSaved) return;
    _transactionSaved = true;

    final userId = await _getUserId();
    final transactionData = {
      ...widget.transactionData,
      'status': status,
      'user_id': userId,
    };

    try {
      await ApiService().saveTransaction(widget.token, transactionData);
    } catch (e) {
      debugPrint('Gagal menyimpan transaksi: $e');
    }
  }

  Future<void> _updateTransactionStatus(String newStatus) async {
    final userId = await _getUserId();
    final updatedData = {
      ...widget.transactionData,
      'status': newStatus,
      'user_id': userId,
    };

    try {
      await ApiService().saveTransaction(widget.token, updatedData);
    } catch (e) {
      debugPrint('Gagal update status transaksi: $e');
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
      body: kIsWeb
          ? const Center(child: CircularProgressIndicator())
          : (_controller == null
              ? const Center(child: CircularProgressIndicator())
              : WebViewWidget(controller: _controller!)),
    );
  }
}
