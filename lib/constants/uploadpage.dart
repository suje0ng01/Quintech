import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class UploadPage extends StatefulWidget {
  final String category;   // 카테고리명 받기 (예: 자음)
  final String documentId; // 문서ID 받기 (예: ㄱ)

  const UploadPage({Key? key, required this.category, required this.documentId}) : super(key: key);

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  String uploadMessage = '';

  Future<void> uploadFile(bool isImage) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = isImage
          ? await picker.pickImage(source: ImageSource.gallery)
          : await picker.pickVideo(source: ImageSource.gallery);

      if (pickedFile == null) {
        setState(() {
          uploadMessage = '파일 선택을 취소했습니다.';
        });
        return;
      }

      final file = File(pickedFile.path);

      if (!await file.exists()) {
        setState(() {
          uploadMessage = '선택한 파일이 존재하지 않습니다.';
        });
        return;
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';
      final ref = FirebaseStorage.instance.ref('uploads/$fileName');

      final uploadTask = ref.putFile(file);
      await uploadTask;

      final downloadUrl = await ref.getDownloadURL();

      // ✅ 여기 수정됨: 이미지/비디오 상관없이 imageUrl 필드에 저장
      await FirebaseFirestore.instance
          .collection('learningdata')
          .doc('category')
          .collection(widget.category)
          .doc(widget.documentId)
          .set({
        'imageUrl': downloadUrl,               // ✅ 항상 imageUrl 키에 저장
        'question': widget.documentId,         // ✅ question 필드도 같이 저장
      }, SetOptions(merge: true));              // ⚡ 기존 데이터 유지 병합

      setState(() {
        uploadMessage = '업로드 및 Firestore 저장 성공!';
      });

      print('업로드 성공, URL: $downloadUrl');
    } catch (e) {
      print('에러 발생: $e');
      setState(() {
        uploadMessage = '업로드 실패: $e';
      });
    }
  }

  void showUploadOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('이미지 업로드'),
                onTap: () {
                  Navigator.pop(context);
                  uploadFile(true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('비디오 업로드'),
                onTap: () {
                  Navigator.pop(context);
                  uploadFile(false);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('파일 업로드'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: showUploadOptions,
              child: const Text('파일 업로드 (이미지/비디오)'),
            ),
            const SizedBox(height: 20),
            Text(uploadMessage),
          ],
        ),
      ),
    );
  }
}
