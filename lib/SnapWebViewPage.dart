import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SnapWebViewPage extends StatefulWidget {
  final String snapToken;

  const SnapWebViewPage({super.key, required this.snapToken, required String initialUrl, required javascriptMode});

  @override
  State<SnapWebViewPage> createState() => _SnapWebViewPageState();
}

class _SnapWebViewPageState extends State<SnapWebViewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    final snapUrl = 'https://app.sandbox.midtrans.com/snap/v2/vtweb/${widget.snapToken}';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(snapUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran Midtrans')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
