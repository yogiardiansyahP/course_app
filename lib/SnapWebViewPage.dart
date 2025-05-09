import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SnapWebViewPage extends StatelessWidget {
  final String snapUrl;
  const SnapWebViewPage({super.key, required this.snapUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Midtrans Payment")),
      body: WebViewWidget(
        controller: WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse(snapUrl)),
      ),
    );
  }
}
