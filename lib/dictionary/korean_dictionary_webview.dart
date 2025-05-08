import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:quintech/constants/constants.dart'; // ⚠️ 실제 경로에 맞게 수정

class DictionaryWebViewPage extends StatefulWidget {
  final String url;

  const DictionaryWebViewPage({super.key, required this.url});

  @override
  State<DictionaryWebViewPage> createState() => _DictionaryWebViewPageState();
}

class _DictionaryWebViewPageState extends State<DictionaryWebViewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appbarcolor,
        title: const Text('한국수어사전'),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}