package com.example.HandTalk.controller;

import com.example.HandTalk.config.JwtUtil;
import com.example.HandTalk.dto.PracticeLogRequestDto;
import com.example.HandTalk.dto.PracticeStatsResponseDto;
import com.example.HandTalk.service.PracticeService;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.MalformedJwtException;
import io.jsonwebtoken.SignatureException;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/practice")
@RequiredArgsConstructor
public class PracticeController {

    private final PracticeService practiceService;
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
