package com.example.HandTalk.dto;

import com.example.HandTalk.domain.ContentType;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
public class GameQuestionDto {
    private ContentType contentType;   // CONSONANT, VOWEL, WORD
    private String topic;              // 단어일 경우 주제명
    private String question;           // 문제 식별자 (ex. "ㄱ", "기본 인사")
    private String videoUrl;           // Firebase 경로
}
