package com.example.HandTalk.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class PasswordResetRequestDto {

    @NotBlank(message = "새 비밀번호를 입력하세요.")
    @Size(min = 4, message = "비밀번호는 최소 4자리 이상이어야 합니다.")
    private String newPassword;

    @NotBlank(message = "비밀번호 확인을 입력하세요.")
    private String confirmPassword;
}
