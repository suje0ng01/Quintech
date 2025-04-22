import 'package:flutter/material.dart';
import 'package:quintech/constants/constants.dart';

//공지사항 페이지
class NoticePage extends StatelessWidget {
  const NoticePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appbarcolor,
        title: const Text(
          '공지사항',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // 이전 페이지(설정 페이지)로 이동
          },
        ),
      ),
      body: ListView.separated(
        itemCount: 20, // 공지사항 20개 생성
        separatorBuilder: (context, index) => const Divider(), // 구분선 추가
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('공지사항 ${index + 1}'), // 공지사항 1, 공지사항 2, ...
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoticeDetailPage(noticeNumber: index + 1),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


// 공지사항 상세 페이지
class NoticeDetailPage extends StatelessWidget {
  final int noticeNumber;

  const NoticeDetailPage({super.key, required this.noticeNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[600],
        title: Text(
          '공지사항 $noticeNumber',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // 이전 페이지(공지사항 목록)로 이동
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            50, // 공지사항 내용을 50줄 생성해서 스크롤 테스트 가능하게 함
            (index) => Text(
              '공지사항 내용 테스트 ${index + 1}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}