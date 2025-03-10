package com.example.HandTalk.dto;

import com.example.HandTalk.user.User;
import lombok.Getter;

@Getter
public class UserResponseDto {
    private Long id;
    private String name;
    private String email;
    private String token; // ✅ JWT 토큰 필드 유지

    // ✅ 로그인 시 사용 (JWT 포함)
    public UserResponseDto(User user, String token) {
        this.id = user.getId();
        this.name = user.getName();
        this.email = user.getEmail();
        this.token = token;
    }

    // ✅ 회원가입 시 사용 (JWT 없음)
    public UserResponseDto(User user) {
        this.id = user.getId();
        this.name = user.getName();
        this.email = user.getEmail();
        this.token = null; // 회원가입에는 토큰이 필요 없음
    }
}
