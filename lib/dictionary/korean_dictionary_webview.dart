import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:quintech/constants/constants.dart'; 

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
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => print('📡 페이지 시작: $url'),
          onPageFinished: (url) => print('✅ 페이지 완료: $url'),
          onWebResourceError: (error) {
            print('❌ WebView 오류: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appbarcolor,
        title: const Text('한국수어사전',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 24),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}