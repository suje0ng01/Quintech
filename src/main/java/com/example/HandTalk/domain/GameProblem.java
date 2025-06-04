package com.example.HandTalk.domain;


import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class GameProblem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    private GameLog gameLog;

    private String topic;       // "자음", "모음", "단어"
    private String content;     // 정답
    private String userInput;   // 사용자 입력
    private boolean isCorrect;  // 정답 여부
}
