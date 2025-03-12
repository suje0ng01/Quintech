package com.example.HandTalk.controller;

import com.example.HandTalk.config.JwtUtil;
import com.example.HandTalk.dto.LoginRequestDto;
import com.example.HandTalk.dto.LoginResponseDto;
import com.example.HandTalk.dto.Oauth2GoogleDto;
import com.example.HandTalk.repository.UserRepository;
import com.example.HandTalk.service.OAuthService;
import com.example.HandTalk.domain.User;
import io.jsonwebtoken.Claims;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {
    private final OAuthService authService;
    private final JwtUtil jwtUtil;
    private final UserRepository userRepository;


    // ✅ 로그인하는 api(jwt반환)

    @PostMapping("/login")
    public ResponseEntity<LoginResponseDto> login(@RequestBody LoginRequestDto requestDto) {
        return ResponseEntity.ok(authService.login(requestDto));
    }



    // ✅ 구글 로그인 후 jwt반환 api
    //사용자 정보도반환 --> 나중필요시 jwt토큰만 반환하는 api 개발 가능
    @GetMapping("/oauth/google/info")
    public ResponseEntity<LoginResponseDto> getGoogleJwtToken(@RequestParam String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("사용자가 존재하지 않습니다."));

        String jwtToken = jwtUtil.generateToken(user.getEmail(), user.getRole().name());

        return ResponseEntity.ok(new LoginResponseDto(user, jwtToken)); // ✅ 사용자 정보와 JWT 함께 반환
    }
    // ✅ 구글 로그인 후 JWT 토큰만 반환 API (추가)
    @GetMapping("/oauth/google/jwt")
    public ResponseEntity<Oauth2GoogleDto> getGoogleJwtOnly(@RequestParam String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("사용자가 존재하지 않습니다."));

        String jwtToken = jwtUtil.generateToken(user.getEmail(), user.getRole().name());

        return ResponseEntity.ok(new Oauth2GoogleDto(jwtToken)); // ✅ JWT 토큰만 반환
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
