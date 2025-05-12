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

        int correct = dto.getCorrectCount();
        int total = dto.getTotalCount();
        double accuracy = (total == 0) ? 0.0 : (correct * 100.0) / total;
        boolean completed = accuracy >= 80.0;

        PracticeLog log = new PracticeLog();
        log.setUser(user);
        log.setContentType(dto.getContentType());
        log.setCorrectCount(correct);
        log.setTotalCount(total);
        log.setAccuracy(accuracy);
        log.setCompleted(completed);
        log.setFinishedAt(dto.getFinishedAt());
        log.setTopic(dto.getTopic());

        practiceLogRepository.save(log);
    }

    // ✅ 진도율 조회 (자음, 모음, 단어 통계 포함)
    public PracticeStatsResponseDto getProgressStats(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("사용자 없음"));

        Map<String, Boolean> consonantVowelProgress = getConsonantVowelProgress(user);
        Map<String, Boolean> wordProgress = getWordProgress(user);

        // ✅ 가장 최근 학습 기록 가져오기
        Optional<PracticeLog> latestLogOpt = practiceLogRepository.findTopByUserOrderByFinishedAtDesc(user);

        ContentType latestType = null;
        String latestTopic = null;
        if (latestLogOpt.isPresent()) {
            PracticeLog log = latestLogOpt.get();
            latestType = log.getContentType();
            latestTopic = log.getTopic(); // WORD가 아닐 경우 null일 수 있음
        }

        return new PracticeStatsResponseDto(
                consonantVowelProgress,
                wordProgress,
                latestType,
                latestTopic
        );
    }

    // 자음/모음 완료 여부
    private Map<String, Boolean> getConsonantVowelProgress(User user) {
        boolean consonantDone = practiceLogRepository.existsByUserAndContentTypeAndCompletedTrue(user, ContentType.CONSONANT);
        boolean vowelDone = practiceLogRepository.existsByUserAndContentTypeAndCompletedTrue(user, ContentType.VOWEL);

        Map<String, Boolean> map = new HashMap<>();
        map.put("consonant", consonantDone);
        map.put("vowel", vowelDone);
        return map;
    }

    // 단어 주제별 완료 여부
    private Map<String, Boolean> getWordProgress(User user) {
        List<PracticeLog> completedLogs = practiceLogRepository.findByUserAndContentTypeAndCompletedTrue(user, ContentType.WORD);
        Set<String> completedTopics = completedLogs.stream()
                .map(PracticeLog::getTopic)
                .filter(Objects::nonNull)
                .collect(Collectors.toSet());

        return wordTopicLoader.getTopicToChapterCount().keySet().stream()
                .collect(Collectors.toMap(
                        topic -> topic,
                        completedTopics::contains
                ));
    }
}
