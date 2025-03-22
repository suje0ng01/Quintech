package com.example.HandTalk.controller;


import com.example.HandTalk.config.JwtUtil;
import com.example.HandTalk.domain.User;
import com.example.HandTalk.service.CheckInService;
import com.example.HandTalk.service.UserService;
import io.jsonwebtoken.Claims;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RequiredArgsConstructor
@RestController
@RequestMapping("check-in")
public class CheckInController {


    // ✅ 출석 체크 API(기능 사용안하기로함) --> 팝업형식으로 변경
        private final CheckInService checkInService;
        private final UserService userService;
        private final JwtUtil jwtUtil;

        // ✅ 출석 체크 API(기능 사용안하기로함) --> 팝업형식으로 변경
//        @PostMapping
//        public ResponseEntity<String> checkIn(@RequestHeader("Authorization") String authHeader) {
//            if (authHeader == null || !authHeader.startsWith("Bearer ")) {
//                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("JWT 토큰이 필요합니다.");
//            }
//
//            String token = authHeader.substring(7);
//            Claims claims = jwtUtil.parseToken(token);
//            String email = claims.getSubject();
//
//            User user = userService.getUserEntityByEmail(email);
//            String message = checkInService.checkIn(user);
//
//            return ResponseEntity.ok(message);
//        }

    // ✅ 연속 출석일 조회 API
    @GetMapping("/streak")
    public ResponseEntity<Integer> getStreak(@RequestHeader("Authorization") String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        String token = authHeader.substring(7);
        Claims claims = jwtUtil.parseToken(token);
        String email = claims.getSubject();

        User user = userService.getUserEntityByEmail(email);
        int streak = checkInService.calculateStreak(user);

        return ResponseEntity.ok(streak);
    }



}

