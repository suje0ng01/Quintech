import 'package:flutter/material.dart';

import '../constants/constants.dart';

class LearningPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appbarcolor,
      appBar: AppBar(
        backgroundColor: Color(0xFFF9D778),
        title: Text(
          '학습',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoBox(),
            SizedBox(height: 20),
            _buildChapterCard('지문자', ['모음', '자음'], 1.0),
            _buildChapterCard('생활', ['식생활', '주생활'], 1.0),
            _buildChapterCard('동식물', [], 0.0),
            _buildChapterCard('인간', [], 0.0),
            _buildChapterCard('사회생활', [], 0.0),
            _buildChapterCard('삶', [], 0.0),
            _buildChapterCard('문화', [], 0.0),
            _buildChapterCard('개념', [], 0.0),
            _buildChapterCard('기타', [], 0.0),
            _buildChapterCard('경제생활', [], 0.0),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('📌 이용 안내', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 6),
          Text('• 각 챕터별 80% 이상 정답 시 학습 완료로 인정됩니다.'),
          Text('• 주제 진행도 = 해당 주제의 완료된 챕터 수 비율 (%)'),
        ],
      ),
    );
  }

  Widget _buildChapterCard(String title, List<String> items, double progress) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Color(0xFFF9D778),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('${(progress * 100).toInt()}%', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        children: items.map((e) => _buildCheckItem(e)).toList(),
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    bool isChecked = text != '자기소개'; // 예시로 일부만 체크
    bool isEnabled = text != '자기소개';

    return CheckboxListTile(
      value: isChecked,
      onChanged: isEnabled ? (val) {} : null,
      title: Text(
        text,
        style: TextStyle(
          color: isEnabled ? Colors.black : Colors.black38,
        ),
      ),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
