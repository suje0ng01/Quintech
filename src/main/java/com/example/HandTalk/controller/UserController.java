package com.example.HandTalk.controller;

import com.example.HandTalk.config.JwtUtil;
import com.example.HandTalk.domain.User;
import com.example.HandTalk.dto.UserRequestDto;
import com.example.HandTalk.dto.UserResponseDto;
import com.example.HandTalk.dto.UserUpdateRequestDto;
import com.example.HandTalk.repository.UserRepository;
import com.example.HandTalk.service.CheckInService;
import com.example.HandTalk.service.UserService;
import io.jsonwebtoken.Claims;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@CrossOrigin(origins = "*")  // 또는 특정 origin만 지정도 가능
@RequestMapping("/api/user")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;
    private final JwtUtil jwtUtil;
    private final CheckInService checkInService;
    private final UserRepository userRepository;
    // ✅ 회원가입 API
    @PostMapping("/register")
    public ResponseEntity<?> registerUser(@Valid @RequestBody UserRequestDto userRequestDto) {
        UserResponseDto savedUser = userService.registerUser(userRequestDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(savedUser);
    }

    @GetMapping("/check-email")
    public ResponseEntity<?> checkEmailDuplicate(@RequestParam("email") String email) {
        boolean exists = userRepository.existsByEmail(email);
        if (exists) {
            return ResponseEntity.ok(Map.of(
                    "available", false,
                    "message", "이미 사용 중인 이메일입니다."
            ));
        } else {
            return ResponseEntity.ok(Map.of(
                    "available", true,
                    "message", "사용 가능한 이메일입니다."
            ));
        }
    }

    @GetMapping("/check")
    public ResponseEntity<?> getUserInfo(@RequestHeader("Authorization") String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("JWT 토큰이 필요합니다.");
        }

        String token = authHeader.substring(7); // "Bearer " 제거
        Claims claims = jwtUtil.parseToken(token);
        String email = claims.getSubject(); // JWT에서 email 추출

        // 🔽 ✅ 사용자 엔티티 조회
        User user = userService.getUserEntityByEmail(email);

        // 🔽 ✅ 출석 기록 자동 저장
        checkInService.checkIn(user);

        // 🔽 ✅ 사용자 정보 + streak 계산
        UserResponseDto userResponse = userService.getUserByEmail(email);
        return ResponseEntity.ok(userResponse);
    }


    // ✅ 사용자 닉네임 수정
    @PutMapping("/update")
    public ResponseEntity<UserResponseDto> updateUserProfile(
            @RequestHeader("Authorization") String authHeader,
            @Valid @RequestBody UserUpdateRequestDto updateRequest) {

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(null);
        }

        String token = authHeader.substring(7);
        Claims claims = jwtUtil.parseToken(token);
        String email = claims.getSubject();

        UserResponseDto updatedUser = userService.updateUserProfile(email, updateRequest);
        return ResponseEntity.ok(updatedUser);
    }

    // ✅ 회원 탈퇴
    @DeleteMapping("/delete")
    public ResponseEntity<String> deleteUser(@RequestHeader("Authorization") String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("JWT 토큰이 필요합니다.");
        }

        String token = authHeader.substring(7); // "Bearer " 제거
        Claims claims = jwtUtil.parseToken(token);
        String email = claims.getSubject(); // JWT에서 이메일 추출

        userService.deleteUserByEmail(email);
        return ResponseEntity.ok("회원 탈퇴가 완료되었습니다.");
    }
}
