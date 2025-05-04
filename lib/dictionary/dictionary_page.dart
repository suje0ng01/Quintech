import 'package:flutter/material.dart';
import 'package:quintech/main.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../member/profilepage.dart';
import '../state/login_state.dart';
import '../settings/setting_page.dart';

import '../data/dummy_dictionary.dart'; //TODO : 더미데이터 클래스 - firebase 연동 시 삭제
import '../data/dummy_member.dart'; //TODO : 더미 사용자 정보 > 추후 삭제

//단어장 페이지
class DictionaryPage extends StatefulWidget {
  @override
  State<DictionaryPage> createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  final FocusNode searchFocusNode = FocusNode();
  final TextEditingController searchController = TextEditingController();

  //TODO : 더미 데이터 사용 (Firebase 연동 시 교체 예정)
  final List<String> dummyWords = DummyDictionary.words;

  String searchText = '';
  late List<String> filteredWords;
  late Map<String, GlobalKey> sectionKeys;
  final ScrollController scrollController = ScrollController();

  // TODO: 영상 경로 리스트 -> Firebase Storage로 전환 예정
  final List<String> sampleVideoPaths = [
    'assets/videos/test_video1.mp4',
    'assets/videos/test_video2.mp4',
  ];

  // TODO: 단어별 영상 매핑 -> Firebase URL로 대체 예정
  late final Map<String, String> wordToVideoMap = DummyDictionary.wordToVideoMap;

  @override
  void initState() {
    super.initState();

    // 강제로 키보드 포커스 제거 (키보드 내려가게 하기)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchFocusNode.unfocus();
      searchController.clear();
    });

    filteredWords = List.from(dummyWords);

    // 자음별 위치 저장용 Key 초기화
    sectionKeys = {
      for (var ch in ['ㄱ','ㄴ','ㄷ','ㄹ','ㅁ','ㅂ','ㅅ','ㅇ','ㅈ','ㅊ','ㅋ','ㅌ','ㅍ','ㅎ'])
        ch: GlobalKey()
    };
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = Provider.of<LoginState>(context).isLoggedIn;
    final groupedWords = groupByInitialConsonant(filteredWords); // 정렬 및 자음 그룹화
    final user = DummyUser.example; //더미 회원 정보

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (!didPop) {
          FocusManager.instance.primaryFocus?.unfocus(); // 뒤로가기 시 키보드 내려주기
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.yellow[600],
          centerTitle: true,
          title: const Text(
            '단어장',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SafeArea( // 🔐 SafeArea로 전체 감싸기 (디버그 레이아웃 방지)
          child: Column(
            children: [
              // 검색창
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: searchController,
                  focusNode: searchFocusNode,
                  autofocus: false,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.search,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    hintText: '검색어를 입력하세요',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                      filteredWords = dummyWords
                          .where((word) => word.contains(searchText))
                          .toList();
                    });
                  },
                ),
              ),
              // 자음 바 + 단어 리스트
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 자음 바 (왼쪽) - 고정된 너비와 안정적인 높이 확보
                        Expanded(
                          flex: 0, // 고정된 너비만큼만 차지
                          child: SizedBox(
                            width: 40,
                            child: Container(
                              color: Colors.white, // 디버그 무늬 방지
                              padding: const EdgeInsets.only(top: 8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: sectionKeys.keys.map((ch) {
                                  return GestureDetector(
                                    onTap: () {
                                      final keyContext = sectionKeys[ch]!.currentContext;
                                      if (keyContext != null) {
                                        Scrollable.ensureVisible(
                                          keyContext,
                                          duration: const Duration(milliseconds: 300),
                                        );
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Text(
                                        ch,
                                        style: const TextStyle(fontSize: 14, color: Colors.blue),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        // 단어 리스트 (오른쪽)
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: groupedWords.length,
                            itemBuilder: (context, index) {
                              final initial = groupedWords.keys.elementAt(index);
                              final words = groupedWords[initial]!;

                              if (words.isEmpty) return const SizedBox();

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    key: sectionKeys[initial],
                                    width: double.infinity,
                                    color: Colors.blue[100],
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                    child: Text(
                                      initial,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                  ...words.map((word) => ListTile(
                                        title: Text(word),
                                        trailing: TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => WordDetailPage(
                                                  word: word,
                                                  videoUrl: wordToVideoMap[word]!, // TODO: Firebase 연동 시 URL로 변경
                                                ),
                                              ),
                                            );
                                          },
                                          child: const Text('수어 >'),
                                        ),
                                      )),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: IconButton(
            icon: const Icon(Icons.home, size: 30),
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus(); // 홈 이동 전 키보드 내리기
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HomeScreen()),
              );
            },
          ),
        ),
      ),
    );
  }

  //자음 추출 및 정렬
  Map<String, List<String>> groupByInitialConsonant(List<String> words) {
    Map<String, List<String>> grouped = {
      for (var ch in ['ㄱ','ㄴ','ㄷ','ㄹ','ㅁ','ㅂ','ㅅ','ㅇ','ㅈ','ㅊ','ㅋ','ㅌ','ㅍ','ㅎ']) ch: []
    };

    for (var word in words) {
      final firstChar = word.characters.first;
      final rawInitial = _getInitialConsonant(firstChar);
      final normalizedInitial = _normalizeInitial(rawInitial);
      if (grouped.containsKey(normalizedInitial)) {
        grouped[normalizedInitial]!.add(word);
      }
    }

    for (var list in grouped.values) {
      list.sort();
    }

    return grouped;
  }

  String _getInitialConsonant(String char) {
    int codeUnit = char.codeUnitAt(0) - 0xAC00;
    if (codeUnit < 0 || codeUnit > 11171) return char;
    int initialIndex = codeUnit ~/ 588;
    const initials = [
      'ㄱ','ㄲ','ㄴ','ㄷ','ㄸ','ㄹ','ㅁ','ㅂ','ㅃ','ㅅ','ㅆ',
      'ㅇ','ㅈ','ㅉ','ㅊ','ㅋ','ㅌ','ㅍ','ㅎ'
    ];
    return initials[initialIndex];
  }

  String _normalizeInitial(String initial) {
    const mapping = {
      'ㄲ': 'ㄱ',
      'ㄸ': 'ㄷ',
      'ㅃ': 'ㅂ',
      'ㅆ': 'ㅅ',
      'ㅉ': 'ㅈ',
    };
    return mapping[initial] ?? initial;
  }
}

//단어장 상세 페이지
// TODO: Firebase 연동 시 network()로 변경
class WordDetailPage extends StatefulWidget {
  final String word;
  final String videoUrl;

  const WordDetailPage({
    super.key,
    required this.word,
    required this.videoUrl,
  });
  @override
  State<WordDetailPage> createState() => _WordDetailPageState();
}

class _WordDetailPageState extends State<WordDetailPage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    final isNetwork = widget.videoUrl.startsWith('http');
    _controller = isNetwork
        ? VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
        : VideoPlayerController.asset(widget.videoUrl);

    _controller.initialize().then((_) {
      setState(() {});
      _controller.play();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        backgroundColor: Colors.yellow[600],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const CircularProgressIndicator(),
            const SizedBox(height: 30),
            Text(
              widget.word,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
