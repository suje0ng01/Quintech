package com.example.HandTalk.service;

import com.example.HandTalk.domain.ContentType;
import com.example.HandTalk.domain.GameLog;
import com.example.HandTalk.domain.GameProblem;
import com.example.HandTalk.domain.User;
import com.example.HandTalk.dto.GameAttemptDto;
import com.example.HandTalk.dto.GameLogRequestDto;
import com.example.HandTalk.dto.GameProblemLogDto;
import com.example.HandTalk.dto.WeeklyGameStatsDto;
import com.example.HandTalk.repository.GameLogRepository;
import com.example.HandTalk.repository.GameProblemRepository;
import com.example.HandTalk.repository.UserRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class GameLogService {

    private final GameLogRepository gameLogRepository;
    private final UserRepository userRepository;

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

        for (GameProblemLogDto problemDto : dto.getProblems()) {
            boolean isCorrect;

            String answer = problemDto.getContent();
            String userInput = problemDto.getUserInput();
            ContentType contentType = problemDto.getContentType();

            if (contentType == ContentType.WORD) {
                isCorrect = (userInput != null && answer != null) &&
                        answer.trim().equalsIgnoreCase(userInput.trim());
            } else {
                isCorrect = Boolean.TRUE.equals(problemDto.getIsCorrect());
            }

            GameProblem problem = new GameProblem();
            problem.setGameLog(log);
            problem.setTopic(problemDto.getTopic());
            problem.setContent(answer);
            problem.setUserInput(userInput);
            problem.setCorrect(isCorrect);
            log.getProblems().add(problem);
        }
    }

    public WeeklyGameStatsDto getGameStats(String email) {
        User user = findUserByEmail(email);
        LocalDateTime oneWeekAgo = LocalDateTime.now().minusDays(7);

        List<GameLog> myLogs = gameLogRepository.findByUserAndPlayedAtAfter(user, oneWeekAgo);
        List<GameLog> allLogs = gameLogRepository.findByPlayedAtAfter(oneWeekAgo);

        double myAvg = averageAccuracy(myLogs);
        double globalAvg = averageAccuracy(allLogs);

        List<GameAttemptDto> history = myLogs.stream()
                .map(log -> new GameAttemptDto(
                        log.getPlayedAt(),
                        log.getCorrectCount(),
                        log.getTotalCount(),
                        round(log.getAccuracy())
                ))
                .toList();

        return new WeeklyGameStatsDto(
                myLogs.size(),
                round(myAvg),
                round(globalAvg),
                history
        );
    }

    private double averageAccuracy(List<GameLog> logs) {
        return logs.isEmpty() ? 0.0 :
                logs.stream().mapToDouble(GameLog::getAccuracy).average().orElse(0.0);
    }

    private double calculateAccuracy(int correct, int total) {
        return (total == 0) ? 0.0 : (correct * 100.0) / total;
    }

    private double round(double value) {
        return Math.round(value * 10.0) / 10.0;
    }

    private User findUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("사용자 없음"));
    }
}
