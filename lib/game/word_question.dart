// lib/pages/game_word_question_view.dart
import 'package:flutter/material.dart';
import 'package:quintech/game/video_playerwidget.dart' show VideoPlayerWidget;

class WordQuestionView extends StatelessWidget {
  final Map<String, dynamic> questionData;
  final TextEditingController answerController;
  final VoidCallback onAnswerCorrect;
  final VoidCallback onAnswerIncorrect;

  const WordQuestionView({
    required this.questionData,
    required this.answerController,
    required this.onAnswerCorrect,
    required this.onAnswerIncorrect,
    Key? key,
  }) : super(key: key);

  bool isVideoUrl(String? url) {
    if (url == null) return false;
    final lowerUrl = url.toLowerCase();
    final path = lowerUrl.split('?').first;
    return path.endsWith('.mp4') || path.endsWith('.mov');
  }

  @override
  Widget build(BuildContext context) {
    final String question = questionData['question'] ?? '';
    final String? videoUrl = questionData['videoUrl'];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            '수어 영상을 보고 단어를 입력하세요',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // 비디오 또는 이미지 표시
          if (videoUrl != null && videoUrl.isNotEmpty)
            isVideoUrl(videoUrl)
                ? AspectRatio(
              aspectRatio: 16 / 9,
              child: VideoPlayerWidget(url: videoUrl),
            )
                : Image.network(
              videoUrl,
              width: 300,
              height: 200,
              fit: BoxFit.contain,
            )
          else
            const Text('미디어 없음'),

          const SizedBox(height: 20),

          // 정답 입력 필드
          TextField(
            controller: answerController,
            decoration: const InputDecoration(
              labelText: "정답을 입력하세요",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          // 정답 확인 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final userInput = answerController.text.trim();
                // ① 입력값이 비어 있으면 경고 다이얼로그
                if (userInput.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('입력 필요'),
                      content: const Text('정답을 입력해주세요.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('확인'),
                        ),
                      ],
                    ),
                  );
                  return;
                }

                final correctAnswer = question.trim().toLowerCase();
                // ② 정답일 때
                if (userInput.toLowerCase() == correctAnswer) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) => AlertDialog(
                      title: const Text('🎉 정답입니다!'),
                      content: const Text('정답을 맞추셨습니다.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            onAnswerCorrect(); // 정답 콜백 호출 (correctCount +1)
                          },
                          child: const Text('다음'),
                        ),
                      ],
                    ),
                  );
                } else {
                  // ③ 오답일 때
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) => AlertDialog(
                      title: const Text('❌ 오답입니다'),
                      content: const Text('아쉽게도 틀렸습니다.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            onAnswerIncorrect(); // 오답 콜백 호출 (correctCount 증가 안 함)
                          },
                          child: const Text('다음'),
                        ),
                      ],
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "정답 확인",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
