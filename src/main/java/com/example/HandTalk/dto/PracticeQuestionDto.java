package com.example.HandTalk.dto;

import com.example.HandTalk.domain.ContentType;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class PracticeQuestionDto {
    private ContentType contentType;  // CONSONANT, VOWEL
    private String question;          // ex. "ㄱ"
    private String videoUrl;          // ex. "https://...firebase/ㄱ.mp4"
}
