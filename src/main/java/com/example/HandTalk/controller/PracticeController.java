package com.example.HandTalk.controller;

import com.example.HandTalk.config.JwtUtil;
import com.example.HandTalk.dto.PracticeLogRequestDto;
import com.example.HandTalk.dto.PracticeQuestionDto;
import com.example.HandTalk.dto.PracticeStatsResponseDto;
import com.example.HandTalk.service.PracticeQuestionService;
import com.example.HandTalk.service.PracticeService;
import com.example.HandTalk.util.WordTopicLoader;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.MalformedJwtException;
import io.jsonwebtoken.SignatureException;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/practice")
@CrossOrigin(origins = "*")  // 또는 특정 origin만 지정도 가능
@RequiredArgsConstructor
public class PracticeController {

    private final PracticeService practiceService;
    private final PracticeQuestionService practiceQuestionService;
    private final WordTopicLoader wordTopicLoader;
    private final JwtUtil jwtUtil;

    // ✅ 학습 결과 저장
    @PostMapping("/save")
    public ResponseEntity<?> savePractice(
            @RequestHeader("Authorization") String authHeader,
            @RequestBody PracticeLogRequestDto requestDto
    ) {
        String email = extractEmail(authHeader);
        if (email == null) {
            return ResponseEntity.status(401).body("유효하지 않은 JWT입니다.");
        }

        practiceService.savePractice(email, requestDto);
        return ResponseEntity.ok("학습 결과가 저장되었습니다.");
    }

    // ✅ 진도율(자음/모음/단어) 조회
    @GetMapping("/progress")
    public ResponseEntity<?> getProgress(@RequestHeader("Authorization") String authHeader) {
        String email = extractEmail(authHeader);
        if (email == null) {
            return ResponseEntity.status(401).body("유효하지 않은 JWT입니다.");
        }

        PracticeStatsResponseDto response = practiceService.getProgressStats(email);
        return ResponseEntity.ok(response);
    }

    // ✅ 자음 문제 출제
    @GetMapping("/questions/consonant")
    public ResponseEntity<?> getConsonantQuestions() {
        return ResponseEntity.ok(practiceQuestionService.getConsonantQuestions());
    }

    // ✅ 모음 문제 출제
    @GetMapping("/questions/vowel")
    public ResponseEntity<?> getVowelQuestions() {
        return ResponseEntity.ok(practiceQuestionService.getVowelQuestions());
    }



    // ✅ 토픽별 단어 문제 출제
    @GetMapping("/questions/word")
    public ResponseEntity<?> getWordQuestions(@RequestParam("topic") String topic) {
        topic = topic.trim();
        wordTopicLoader.ensureInitialized();

        if (!wordTopicLoader.getTopicToWords().containsKey(topic)) {
            return ResponseEntity.badRequest().body("❌ 존재하지 않는 topic입니다: " + topic);
        }

        List<PracticeQuestionDto> questions = practiceQuestionService.getWordQuestions(topic);
        if (questions.isEmpty()) {
            return ResponseEntity.status(404).body("⚠️ 해당 토픽에 등록된 단어 비디오가 없습니다.");
        }

        return ResponseEntity.ok(questions);
    }


    // ✅ JWT에서 이메일 안전하게 추출
    private String extractEmail(String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return null;
        }

        String token = authHeader.substring(7);
        try {
            Claims claims = jwtUtil.parseToken(token);
            return claims.getSubject();
        } catch (ExpiredJwtException | MalformedJwtException | SignatureException e) {
            System.err.println("❌ JWT 파싱 실패: " + e.getMessage());
            return null;
        }
    }
}
