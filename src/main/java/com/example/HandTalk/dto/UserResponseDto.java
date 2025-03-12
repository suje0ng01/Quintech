package com.example.HandTalk.dto;

import com.example.HandTalk.domain.User;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
//회원가입후 사용자 정보 반환 , 사용자 정보조회 응답
public class UserResponseDto {
    private Long id;
    private String name;
    private String email;
    private String nickname; // ✅ 닉네임 추가




    // ✅ 회원가입 시 사용 (JWT 없음)
    public UserResponseDto(User user) {
        this.id = user.getId();
        this.name = user.getName();
        this.email = user.getEmail();
        this.nickname = user.getNickname(); // ✅ 닉네임 추가
    }
}
