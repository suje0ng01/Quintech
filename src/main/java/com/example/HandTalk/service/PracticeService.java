package com.example.HandTalk.service;

import com.example.HandTalk.domain.ContentType;
import com.example.HandTalk.domain.PracticeLog;
import com.example.HandTalk.domain.User;
import com.example.HandTalk.dto.PracticeLogRequestDto;
import com.example.HandTalk.dto.PracticeStatsResponseDto;
import com.example.HandTalk.repository.PracticeLogRepository;
import com.example.HandTalk.repository.UserRepository;
import com.example.HandTalk.util.WordTopicLoader;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PracticeService {

    private final PracticeLogRepository practiceLogRepository;
    private final UserRepository userRepository;
    private final WordTopicLoader wordTopicLoader;

    // ✅ 학습 결과 저장
    @Transactional
    public void savePractice(String email, PracticeLogRequestDto dto) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("사용자 없음"));

        PracticeLog log = new PracticeLog();
        log.setUser(user);
        log.setContentType(dto.getContentType());
        log.setCorrectCount(dto.getCorrectCount());
        log.setTotalCount(dto.getTotalCount());
        log.setAccuracy(dto.getAccuracy());
        log.setCompleted(dto.isCompleted());
        log.setFinishedAt(dto.getFinishedAt());
        log.setTopic(dto.getTopic());

        practiceLogRepository.save(log);
    }

    // ✅ 자음/모음 + 단어 통합 진도율 조회
    public PracticeStatsResponseDto getProgressStats(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("사용자 없음"));

        // 1. 자음/모음 완료 여부
        Map<String, Boolean> consonantVowelProgress = new HashMap<>();
        boolean consonantDone = practiceLogRepository.existsByUserAndContentTypeAndCompletedTrue(user, ContentType.CONSONANT);
        boolean vowelDone = practiceLogRepository.existsByUserAndContentTypeAndCompletedTrue(user, ContentType.VOWEL);
        consonantVowelProgress.put("consonant", consonantDone);
        consonantVowelProgress.put("vowel", vowelDone);

        // 2. 단어 완료 여부
        List<PracticeLog> completedWordLogs = practiceLogRepository
                .findByUserAndContentTypeAndCompletedTrue(user, ContentType.WORD);

        Set<String> completedTopics = completedWordLogs.stream()
                .map(PracticeLog::getTopic)
                .filter(Objects::nonNull)
                .collect(Collectors.toSet());

        Set<String> allTopics = wordTopicLoader.getTopicToChapterCount().keySet();

        Map<String, Boolean> wordProgress = new HashMap<>();
        for (String topic : allTopics) {
            wordProgress.put(topic, completedTopics.contains(topic));
        }

        return new PracticeStatsResponseDto(consonantVowelProgress, wordProgress);
    }
}
