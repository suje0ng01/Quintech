package com.example.HandTalk.controller;

import com.example.HandTalk.config.JwtUtil;
import com.example.HandTalk.dto.LoginRequestDto;
import com.example.HandTalk.dto.LoginResponseDto;
import com.example.HandTalk.dto.Oauth2GoogleDto;
import com.example.HandTalk.repository.UserRepository;
import com.example.HandTalk.service.CheckInService;
import com.example.HandTalk.service.OAuthService;
import com.example.HandTalk.domain.User;
import io.jsonwebtoken.Claims;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/auth")
@CrossOrigin(origins = "*")  // 또는 특정 origin만 지정도 가능
@RequiredArgsConstructor
public class AuthController {
    private final OAuthService authService;
    private final JwtUtil jwtUtil;
    private final UserRepository userRepository;
    private final CheckInService checkInService;

    @PostMapping("/login")
    public ResponseEntity<LoginResponseDto> login(@RequestBody LoginRequestDto requestDto) {
        LoginResponseDto response = authService.login(requestDto);

        // ✅ DTO에는 사용자 식별 ID(email) 포함돼 있으므로 다시 user 조회
        User user = userRepository.findByEmail(response.getEmail())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "사용자 조회 실패"));

        checkInService.checkIn(user); // 출석 체크

        return ResponseEntity.ok(response);
    }


    // ✅ 구글 로그인 후 jwt반환 api
    @GetMapping("/oauth/google/info")
    public ResponseEntity<LoginResponseDto> getGoogleJwtToken(@RequestParam String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("사용자가 존재하지 않습니다."));

        String jwtToken = jwtUtil.generateToken(user.getEmail(), user.getRole().name());

        // ✅ 자동 출석 체크
        checkInService.checkIn(user);

        return ResponseEntity.ok(new LoginResponseDto(user, jwtToken));
    }

    // ✅ 구글 로그인 후 JWT 토큰만 반환 API (추가)
    @GetMapping("/oauth/google/jwt")
    public ResponseEntity<Oauth2GoogleDto> getGoogleJwtOnly(@RequestParam String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("사용자가 존재하지 않습니다."));

        String jwtToken = jwtUtil.generateToken(user.getEmail(), user.getRole().name());

        // ✅ 자동 출석 체크
        checkInService.checkIn(user);

        return ResponseEntity.ok(new Oauth2GoogleDto(jwtToken));
    }

    //✅ 일반로그인시 jwt인증 테스트용도 api
    @GetMapping("/test")
    public ResponseEntity<?> testToken(@RequestHeader("Authorization") String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("JWT 토큰이 필요합니다.");
        }

        String token = authHeader.substring(7); // "Bearer " 제거
        Claims claims = jwtUtil.parseToken(token);

        return ResponseEntity.ok(claims);
    }
}