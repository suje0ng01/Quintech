package com.example.HandTalk.dto;

import com.example.HandTalk.user.User;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import javax.xml.bind.annotation.XmlSeeAlso;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
//로그인후 jwt토큰 반환시 사용 (일반 폼로그인회원)
public class LoginResponseDto {
    private Long id;        // 사용자 ID
    private String name;    // 사용자 이름
    private String email;   // 사용자 이메일
    private String nickname; // 사용자 닉네임
    private String token;   // JWT 토큰

    public LoginResponseDto(User user, String token) {
        this.id = user.getId();
        this.name = user.getName();
        this.email = user.getEmail();
        this.nickname = user.getNickname();
        this.token = token;
    }
}
