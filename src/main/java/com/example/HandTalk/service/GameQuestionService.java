package com.example.HandTalk.service;

import com.example.HandTalk.domain.ContentType;
import com.example.HandTalk.domain.PracticeLog;
import com.example.HandTalk.domain.User;
import com.example.HandTalk.dto.GameQuestionDto;
import com.example.HandTalk.repository.PracticeLogRepository;
import com.example.HandTalk.repository.UserRepository;
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
    private final WordTopicLoader wordTopicLoader;

    public List<GameQuestionDto> generateGameQuestions(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("사용자 없음"));

        List<PracticeLog> completedLogs = practiceLogRepository.findByUserAndCompletedTrue(user);

        // 자음/모음 완료 여부 확인
        boolean hasConsonant = completedLogs.stream().anyMatch(log -> log.getContentType() == ContentType.CONSONANT);
        boolean hasVowel = completedLogs.stream().anyMatch(log -> log.getContentType() == ContentType.VOWEL);

        // 단어 완료 주제 수집
        Set<String> completedTopics = completedLogs.stream()
                .filter(log -> log.getContentType() == ContentType.WORD)
                .map(PracticeLog::getTopic)
                .collect(Collectors.toSet());

        List<GameQuestionDto> fullPool = new ArrayList<>();

        // ✅ 자음 전체 포함
        if (hasConsonant) {
            List<String> consonants = List.of("ㄱ", "ㄴ", "ㄷ", "ㄹ", "ㅁ", "ㅂ", "ㅅ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ");
            for (String consonant : consonants) {
                fullPool.add(new GameQuestionDto(ContentType.CONSONANT, null, consonant));
            }
        }

        // ✅ 모음 전체 포함
        if (hasVowel) {
            List<String> vowels = List.of("ㅏ", "ㅑ", "ㅓ", "ㅕ", "ㅗ", "ㅛ", "ㅜ", "ㅠ", "ㅡ", "ㅣ", "ㅐ", "ㅔ", "ㅚ", "ㅟ", "ㅢ");
            for (String vowel : vowels) {
                fullPool.add(new GameQuestionDto(ContentType.VOWEL, null, vowel));
            }
        }

        // ✅ 단어 전체 포함 (완료 주제만)
        for (String topic : completedTopics) {
            List<String> words = wordTopicLoader.getWordsByTopic(topic);
            if (words != null) {
                for (String word : words) {
                    fullPool.add(new GameQuestionDto(ContentType.WORD, topic, word));
                }
            }
        }

        // ✅ 전체 pool에서 랜덤 섞기
        Collections.shuffle(fullPool);

        // ✅ 최대 20문제만 반환
        return fullPool.stream().limit(20).collect(Collectors.toList());
    }
}