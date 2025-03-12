package com.example.HandTalk.user;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotEmpty;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Getter
@Setter
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
    @Column(nullable = false, unique = true, length = 50) // 이메일은 유니크하게 설정
    private String email;

    @Column(nullable = false, unique = true, length = 50) // 닉네임 필드 추가
    private String nickname;

    @Column(nullable = true, length = 255) // 비밀번호는 해싱되므로 길이 여유롭게 설정
    private String password;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<PracticeLog> practiceLogList;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private OAuthType oAuthType = OAuthType.NONE;

    @Enumerated(EnumType.STRING)
    private Role role;


    // OAuth2 로그인 제공자 (ex: "google")
    @Column(nullable = true, length = 50)
    private String provider;

    // 제공자에서 부여한 사용자 고유 ID
    @Column(nullable = true, length = 100, unique = true)
    private String providerId;

    @CreationTimestamp
    private LocalDateTime createdAt;

    @UpdateTimestamp
    private LocalDateTime updatedAt;
}