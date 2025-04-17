package com.example.HandTalk.service;

import com.example.HandTalk.domain.ContentType;
import com.example.HandTalk.domain.PracticeLog;
import com.example.HandTalk.domain.User;
import com.example.HandTalk.dto.GameQuestionDto;
import com.example.HandTalk.repository.PracticeLogRepository;
import com.example.HandTalk.repository.UserRepository;
import com.example.HandTalk.util.FirebaseImageMapper;
import com.example.HandTalk.util.WordTopicLoader;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class GameQuestionService {

    private final UserRepository userRepository;
    private final PracticeLogRepository practiceLogRepository;
    private final FirebaseImageMapper firebaseImageMapper;
    private final WordTopicLoader wordTopicLoader; // ✅ 단어 목록 불러오는 컴포넌트

    public List<GameQuestionDto> generateGameQuestions(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("사용자 없음"));

        // ✅ 1. 완료된 학습 항목 수집 (정답률 80% 이상)
        List<PracticeLog> completedLogs = practiceLogRepository.findByUserAndCompletedTrue(user);

        // ✅ 자음/모음/단어 로그 분리
        boolean hasConsonant = false;
        boolean hasVowel = false;
        List<PracticeLog> wordLogs = new ArrayList<>();

        for (PracticeLog log : completedLogs) {
            if (log.getContentType() == ContentType.CONSONANT) {
                hasConsonant = true;
            } else if (log.getContentType() == ContentType.VOWEL) {
                hasVowel = true;
            } else if (log.getContentType() == ContentType.WORD) {
                wordLogs.add(log);
            }
        }

        List<GameQuestionDto> allQuestions = new ArrayList<>();

        // ✅ 자음 1개 랜덤 포함
        if (hasConsonant) {
            List<String> consonants = new ArrayList<>(List.of("ㄱ", "ㄴ", "ㄷ", "ㄹ", "ㅁ", "ㅂ", "ㅅ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"));
            Collections.shuffle(consonants);
            for (String c : consonants) {
                String url = firebaseImageMapper.getImageUrl(ContentType.CONSONANT, c);
                if (url != null) {
                    allQuestions.add(new GameQuestionDto(ContentType.CONSONANT, null, c, url));
                    break;
                }
            }
        }

        // ✅ 모음 1개 랜덤 포함
        if (hasVowel) {
            List<String> vowels = new ArrayList<>(List.of("ㅏ", "ㅑ", "ㅓ", "ㅕ", "ㅗ", "ㅛ", "ㅜ", "ㅠ", "ㅡ", "ㅣ", "ㅐ", "ㅔ", "ㅚ", "ㅟ", "ㅢ"));
            Collections.shuffle(vowels);
            for (String v : vowels) {
                String url = firebaseImageMapper.getImageUrl(ContentType.VOWEL, v);
                if (url != null) {
                    allQuestions.add(new GameQuestionDto(ContentType.VOWEL, null, v, url));
                    break;
                }
            }
        }

        // ✅ 단어 문제 생성
        for (PracticeLog wordLog : wordLogs) {
            allQuestions.addAll(toQuestionDto(wordLog));
        }

        // ✅ 셔플 후 최대 20개 반환
        Collections.shuffle(allQuestions);
        return allQuestions.stream()
                .filter(q -> q.getImageUrl() != null)
                .limit(20)
                .collect(Collectors.toList());
    }


    private List<GameQuestionDto> toQuestionDto(PracticeLog log) {
        ContentType type = log.getContentType();

        // ✅ 자음 또는 모음 문제 처리
        if (type == ContentType.CONSONANT || type == ContentType.VOWEL) {
            String key = (type == ContentType.CONSONANT) ? "consonant" : "vowel";
            String imageUrl = firebaseImageMapper.getImageUrl(type, key);

            if (imageUrl == null) return Collections.emptyList();

            return List.of(new GameQuestionDto(type, null, key, imageUrl));
        }

        // ✅ 단어(WORD) 문제 처리
        String topic = log.getTopic();
        List<String> words = wordTopicLoader.getWordsByTopic(topic);
        if (words == null || words.isEmpty()) return Collections.emptyList();

        return words.stream()
                .map(word -> {
                    String imageUrl = firebaseImageMapper.getImageUrl(type, word);
                    return (imageUrl != null)
                            ? new GameQuestionDto(type, topic, word, imageUrl)
                            : null;
                })
                .filter(Objects::nonNull)
                .collect(Collectors.toList());
    }
}
