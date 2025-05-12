package com.example.HandTalk.domain;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotEmpty;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_id", nullable = false)
    private Long id;

    @NotEmpty
    @Column(nullable = false, length = 255)
    private String name;

    @NotEmpty
    @Column(nullable = false, unique = true, length = 50)
    private String email;

    @Column(nullable = false, unique = true, length = 50)
    private String nickname;

    @Column(nullable = true, length = 255)
    private String password;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private OAuthType oAuthType = OAuthType.NONE;

    @Enumerated(EnumType.STRING)
    private Role role;

    @Column(length = 50)
    private String provider;

    @Column(length = 100, unique = true)
    private String providerId;

    @CreationTimestamp
    private LocalDateTime createdAt;

    @UpdateTimestamp
    private LocalDateTime updatedAt;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<PracticeLog> practiceLogs = new ArrayList<>();

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<CheckIn> checkIns = new ArrayList<>();

    // 연관관계 편의 메서드
    public void addPracticeLog(PracticeLog log) {
        practiceLogs.add(log);
        log.setUser(this);
    }

    public void addCheckIn(CheckIn checkIn) {
        checkIns.add(checkIn);
        checkIn.setUser(this);
    }
}
