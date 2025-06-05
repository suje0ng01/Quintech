package com.example.HandTalk.controller;

import com.example.HandTalk.config.JwtUtil;
import com.example.HandTalk.dto.GameLogRequestDto;
import com.example.HandTalk.dto.GameQuestionDto;
import com.example.HandTalk.service.GameLogService;
import com.example.HandTalk.service.GameQuestionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;



@RestController
@RequestMapping("/api/game")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
public class GameController {

    private final GameLogService gameLogService;
    private final GameQuestionService gameQuestionService;
    private final JwtUtil jwtUtil;

    @PostMapping("/save")
    public ResponseEntity<?> saveGameResult(
            @RequestHeader("Authorization") String authHeader,
            @RequestBody GameLogRequestDto dto
    ) {
        String email = extractEmail(authHeader);
        if (email == null) {
            return ResponseEntity.status(401).body(Map.of("message", "유효하지 않은 JWT입니다."));
        }

        gameLogService.saveGameResult(email, dto);
        return ResponseEntity.ok(Map.of("message", "게임 결과가 저장되었습니다."));
    }

    @GetMapping("/questions")
    public ResponseEntity<?> getGameQuestionList(@RequestHeader("Authorization") String authHeader) {
        String email = extractEmail(authHeader);
        if (email == null) {
            return ResponseEntity.status(401).body(Map.of("message", "유효하지 않은 JWT입니다."));
        }

        List<GameQuestionDto> questions = gameQuestionService.generateGameQuestions(email);

        if (questions.isEmpty()) {
            return ResponseEntity.status(400).body(Map.of(
                    "message", "연습을 완료한 항목이 없어 게임 문제를 생성할 수 없습니다."
            ));
        }

        if (questions.size() < 20) {
            return ResponseEntity.ok(Map.of(
                    "message", "연습 완료 항목이 적어 20문제 미만이 출제되었습니다.",
                    "questions", questions
            ));
        }

        return ResponseEntity.ok(Map.of(
                "message", "게임 문제가 정상 출제되었습니다.",
                "questions", questions
        ));

    }


    // ✅ GET /api/game/stats → Weekly 통계 제공
    @GetMapping("/stats")
    public ResponseEntity<?> getGameStats(@RequestHeader("Authorization") String authHeader) {
        String email = extractEmail(authHeader);
        if (email == null) {
            return ResponseEntity.status(401).body(Map.of("message", "유효하지 않은 JWT입니다."));
        }

        return ResponseEntity.ok(gameLogService.getGameStats(email));
    }

    private String extractEmail(String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) return null;
        String token = authHeader.substring(7);
        try {
            return jwtUtil.parseToken(token).getSubject();
        } catch (Exception e) {
            return null;
        }
    }
}
