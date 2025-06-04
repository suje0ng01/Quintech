package com.example.HandTalk.dto;

import com.example.HandTalk.domain.ContentType; // enum import

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class GameProblemLogDto {

    private ContentType contentType;  // ✅ enum 타입으로 추가
    private String topic;             // 주제 (WORD일 때만)
    private String content;           // 정답
    private String userInput;         // 사용자 입력 (WORD일 때만)
    private Boolean isCorrect;        // 자음/모음만 프론트가 판단
}
