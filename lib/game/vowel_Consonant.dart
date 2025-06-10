// lib/pages/vowel_consonant_view.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class VowelConsonantView extends StatelessWidget {
  final Map<String, dynamic> questionData;
  final CameraController? cameraController;
  final bool isCameraInitialized;
  final bool isRecognizing;
  final bool hasRecognized;
  final VoidCallback onRecognize;
  final VoidCallback onNext; // 전달은 되지만 버튼에서 사용 X

  const VowelConsonantView({
    Key? key,
    required this.questionData,
    required this.cameraController,
    required this.isCameraInitialized,
    required this.isRecognizing,
    required this.hasRecognized,
    required this.onRecognize,
    required this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final question = questionData['question'] as String? ?? '';
    final screenWidth = MediaQuery.of(context).size.width;
    final mainBoxSize = screenWidth * 0.8 > 400.0 ? 400.0 : screenWidth * 0.8;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            '아래 적힌 단어를 손으로 표현해보세요',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // 질문 텍스트 박스
          Container(
            width: mainBoxSize,
            constraints: const BoxConstraints(minHeight: 80),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: Colors.blueAccent.shade100, width: 2.0),
            ),
            child: Text(
              question,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),

          // 카메라 프리뷰
          Container(
            width: mainBoxSize,
            height: mainBoxSize,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2.0),
              borderRadius: BorderRadius.circular(18.0),
            ),
            child: isCameraInitialized && cameraController != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(18.0),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: cameraController!.value.previewSize!.height,
                    height: cameraController!.value.previewSize!.width,
                    child: CameraPreview(cameraController!),
                  ),
                ),
              ),
            )
                : const Center(child: CircularProgressIndicator()),
          ),
          const SizedBox(height: 20),

          // 수어 인식 시작 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (!isRecognizing && !hasRecognized) ? onRecognize : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text(
                isRecognizing
                    ? '인식 중…'
                    : hasRecognized
                    ? '완료'
                    : '수어 인식 시작',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // "다음 문제" 버튼 제거됨 → 아래 부분 삭제
          // SizedBox(
          //   width: double.infinity,
          //   child: ElevatedButton(
          //     onPressed: onNext,
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: Colors.blueAccent,
          //       padding: const EdgeInsets.symmetric(vertical: 16.0),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(10.0),
          //       ),
          //     ),
          //     child: const Text(
          //       '다음 문제',
          //       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
