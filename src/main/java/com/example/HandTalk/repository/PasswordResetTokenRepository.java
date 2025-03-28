package com.example.HandTalk.repository;

import com.example.HandTalk.domain.PasswordResetToken;
import com.example.HandTalk.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface PasswordResetTokenRepository extends JpaRepository<PasswordResetToken, Long> {

    // 특정 사용자의 비밀번호 재설정 토큰을 조회 (사용자 엔티티 기준)
    Optional<PasswordResetToken> findByUser(User user);

    // 또는 사용자 이메일을 기준으로 조회 (User 엔티티의 email 필드가 unique인 경우)
    Optional<PasswordResetToken> findByUser_Email(String email);

    // 특정 사용자의 비밀번호 재설정 토큰 삭제 (비밀번호 재설정 완료 후 삭제)
    void deleteByUser(User user);
}
