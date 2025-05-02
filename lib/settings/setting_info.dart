import 'package:flutter/material.dart';
import 'package:quintech/constants/constants.dart';

//공지사항 페이지
class NoticePage extends StatelessWidget {
  const NoticePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 공지사항 리스트
    final List<Map<String, String>> noticeList = [
      {
        'title': '앱 정식 출시 예정 안내',
        'content': '현재 앱은 베타 버전이며, 정식 출시는 6월 중 예정입니다. 사용자의 피드백을 바탕으로 기능 개선 중입니다.',
      },
      {
        'title': '수어 인식 정확도 개선 업데이트 (v0.9.3)',
        'content': '인공지능 수어 인식 모델이 개선되었습니다. \n손 모양이 조금 달라도 인식이 가능해졌습니다.',
      },
      {
        'title': '서버 점검 안내',
        'content': '5월 5일 오전 2시부터 4시까지 서버 점검이 예정되어 있어, 해당 시간에는 학습 기능 이용이 제한됩니다.',
      },
    ];
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
        itemCount: noticeList.length,
        separatorBuilder: (context, index) => const Divider(), // 구분선 추가
        itemBuilder: (context, index) {
          final notice = noticeList[index];
          return ListTile(
            title: Text(notice['title']!), 
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoticeDetailPage(notice: notice),
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
  final Map<String, String> notice;

  const NoticeDetailPage({super.key, required this.notice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[600],
        title: Text(
          notice['title']!,
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          notice['content']!,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}