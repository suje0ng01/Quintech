package com.example.HandTalk.domain;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
public class PracticeLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id") // 주인 쪽에서 JoinColumn
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ContentType contentType; // CONSONANT, VOWEL, WORD

    @Column(nullable = true)
    private String chapter; // Only for WORD type

    @Column(nullable = false)
    private int correctCount;

    @Column(nullable = false)
    private int totalCount;

    @Column(nullable = false)
    private double accuracy;

    @Column(nullable = false)
    private boolean completed;

    private LocalDateTime finishedAt;
}
