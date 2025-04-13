package com.example.HandTalk.controller;

import com.example.HandTalk.config.JwtUtil;
import com.example.HandTalk.dto.GameLogRequestDto;
import com.example.HandTalk.dto.GameQuestionDto;
import com.example.HandTalk.dto.GameStatsResponseDto;
import com.example.HandTalk.service.GameLogService;
import com.example.HandTalk.service.GameQuestionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/game")
@RequiredArgsConstructor
public class GameController {

    private final GameLogService gameLogService;
    private final GameQuestionService gameQuestionService;
    private final JwtUtil jwtUtil;

    // ✅ 게임 결과 저장
    @PostMapping("/save")
    public ResponseEntity<?> saveGameResult(
            @RequestHeader("Authorization") String authHeader,
            @RequestBody GameLogRequestDto dto
    ) {
        String email = extractEmail(authHeader);
        if (email == null) {
            return ResponseEntity.status(401).body("유효하지 않은 JWT입니다.");
        }

        gameLogService.saveGameResult(email, dto);
        return ResponseEntity.ok("게임 결과가 저장되었습니다.");
    }

    // ✅ 게임 문제 출제
    @GetMapping("/questions")
    public ResponseEntity<?> getGameQuestionList(@RequestHeader("Authorization") String authHeader) {
        String email = extractEmail(authHeader);
        if (email == null) {
            return ResponseEntity.status(401).body("유효하지 않은 JWT입니다.");
        }

        List<GameQuestionDto> questions = gameQuestionService.generateGameQuestions(email);
        return ResponseEntity.ok(questions);
    }

    // ✅ JWT에서 이메일 추출
    private String extractEmail(String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) return null;
        String token = authHeader.substring(7);
        try {
            return jwtUtil.parseToken(token).getSubject();
        } catch (Exception e) {
            return null;
        }
    }
    @GetMapping("/stats")
    public ResponseEntity<?> getGameStats(@RequestHeader("Authorization") String authHeader) {
        String email = extractEmail(authHeader);
        if (email == null) {
            return ResponseEntity.status(401).body("유효하지 않은 JWT입니다.");
        }

        GameStatsResponseDto stats = gameLogService.getGameStats(email);
        return ResponseEntity.ok(stats);
    }

}
