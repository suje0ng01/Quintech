package com.example.HandTalk.controller;

import com.example.HandTalk.dto.PasswordResetRequestDto;
import com.example.HandTalk.service.PasswordResetService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/password")
@CrossOrigin(origins = "*")  // 또는 특정 origin만 지정도 가능
@RequiredArgsConstructor
public class PasswordResetController {

    private final PasswordResetService passwordResetService;

    /**
     * 1) 비밀번호 재설정 인증번호 발송
     *  - 사용자가 이메일을 입력 -> 해당 이메일 계정 존재 여부 확인 -> 인증번호 생성 & 이메일 전송
     */
    @PostMapping("/forgot")
    public ResponseEntity<String> forgotPassword(@RequestParam String email) {
        passwordResetService.sendResetCode(email);
        return ResponseEntity.ok("인증번호가 발송되었습니다. 이메일을 확인하세요.");
    }

    /**
     * 2) 인증번호 검증
     *  - 사용자가 인증번호 입력 -> 서버에서 만료 여부와 코드 일치 여부 확인
     */
    @PostMapping("/verify")
    public ResponseEntity<String> verifyCode(@RequestParam String email,
                                             @RequestParam String code) {
        passwordResetService.verifyResetCode(email, code);
        return ResponseEntity.ok("인증번호가 유효합니다.");
    }

    /**
     * 3) 비밀번호 재설정
     *  - 인증이 완료된 후 새 비밀번호와 비밀번호 확인을 받아 변경
     */
    @PostMapping("/reset")
    public ResponseEntity<String> resetPassword(@RequestParam String email,
                                                @RequestBody PasswordResetRequestDto requestDto) {
        passwordResetService.resetPassword(email, requestDto);
        return ResponseEntity.ok("비밀번호가 재설정되었습니다.");
    }
}
