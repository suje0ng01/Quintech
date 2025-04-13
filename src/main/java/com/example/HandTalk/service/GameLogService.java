package com.example.HandTalk.service;

import com.example.HandTalk.domain.GameLog;
import com.example.HandTalk.domain.User;
import com.example.HandTalk.dto.GameLogRequestDto;
import com.example.HandTalk.dto.GameStatsResponseDto;
import com.example.HandTalk.repository.GameLogRepository;
import com.example.HandTalk.repository.UserRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class GameLogService {

    private final GameLogRepository gameLogRepository;
    private final UserRepository userRepository;

    // ✅ 게임 결과 저장
    @Transactional
    public void saveGameResult(String email, GameLogRequestDto dto) {
        User user = findUserByEmail(email);
        double accuracy = calculateAccuracy(dto.getCorrectCount(), dto.getTotalCount());

        GameLog log = new GameLog();
        log.setUser(user);
        log.setCorrectCount(dto.getCorrectCount());
        log.setTotalCount(dto.getTotalCount());
        log.setAccuracy(accuracy);
        log.setPlayedAt(dto.getPlayedAt());

        gameLogRepository.save(log);
    }

    // ✅ 게임 정답률 통계 조회 (내 평균 + 전체 평균)
    public GameStatsResponseDto getGameStats(String email) {
        User user = findUserByEmail(email);

        double myAccuracy = averageAccuracy(gameLogRepository.findByUser(user));
        double globalAccuracy = averageAccuracy(gameLogRepository.findAll());

        return new GameStatsResponseDto(round(myAccuracy), round(globalAccuracy));
    }

    // ✅ 평균 계산
    private double averageAccuracy(List<GameLog> logs) {
        return logs.isEmpty() ? 0.0 :
                logs.stream().mapToDouble(GameLog::getAccuracy).average().orElse(0.0);
    }

    // ✅ 정확도 계산
    private double calculateAccuracy(int correct, int total) {
        return (total == 0) ? 0.0 : (correct * 100.0) / total;
    }

    // ✅ 사용자 조회
    private User findUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("사용자 없음"));
    }

    // ✅ 소수점 첫째 자리 반올림
    private double round(double value) {
        return Math.round(value * 10.0) / 10.0;
    }
}
