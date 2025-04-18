import 'package:flutter/material.dart';

//FAQ 페이지
class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> faqList = List.generate(
      20,
      (index) => {
        'question': '자주 묻는 질문 ${index + 1}',
        'answer': '이것은 자주 묻는 질문 ${index + 1}에 대한 답변입니다.\n' * 3,
      },
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[600],
        title: const Text(
          'FAQ',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          ListView.separated(
            padding: const EdgeInsets.only(bottom: 70),
            itemCount: faqList.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(faqList[index]['question']!),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FAQDetailPage(faq: faqList[index]),
                    ),
                  );
                },
              );
            },
          ),
          Positioned(   //문의하기 버튼 하단에 고정정
            bottom: 10,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InquiryPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[600],
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('문의하기'),
            ),
          ),
        ],
      ),
    );
  }
}

//FAQ 상세 페이지
class FAQDetailPage extends StatelessWidget {
  final Map<String, String> faq;

  const FAQDetailPage({super.key, required this.faq});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[600],
        title: Text(
          faq['question']!,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            faq['answer']!,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}

//문의하기 페이지
class InquiryPage extends StatefulWidget {
  const InquiryPage({super.key});

  @override
  InquiryPageState createState() => InquiryPageState();
}

class InquiryPageState extends State<InquiryPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[600],
        title: const Text(
          '문의하기',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(nameController, '이름'),
            const SizedBox(height: 10),
            _buildTextField(emailController, '이메일'),
            const SizedBox(height: 10),
            _buildTextField(titleController, '제목'),
            const SizedBox(height: 10),
            _buildTextField(contentController, '문의 내용', maxLines: 5),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[600],
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
              ),
              child: const Text('확인'),
            ),
          ],
        ),
      ),
    );
  }

  // 텍스트 필드 설정 (툴바 제거 및 키보드 설정 추가)
  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: TextInputType.text, // 기본 키보드
      textInputAction: TextInputAction.done, // "완료" 버튼 표시
      autocorrect: false, // 자동 수정 끄기
      enableSuggestions: false, // 추천 단어 끄기
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}