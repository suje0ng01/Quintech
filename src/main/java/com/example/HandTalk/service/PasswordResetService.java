package com.example.HandTalk.service;

import com.example.HandTalk.domain.OAuthType;
import com.example.HandTalk.domain.PasswordResetToken;
import com.example.HandTalk.domain.User;
import com.example.HandTalk.dto.PasswordResetRequestDto;
import com.example.HandTalk.repository.PasswordResetTokenRepository;
import com.example.HandTalk.repository.UserRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.Random;

@Service
@RequiredArgsConstructor
public class PasswordResetService {

    private final UserRepository userRepository;
    private final PasswordResetTokenRepository tokenRepository;
    private final EmailService emailService;
    private final PasswordEncoder passwordEncoder;

    // 인증번호 유효 시간 (분 단위)
    private static final int RESET_TOKEN_EXPIRATION_MINUTES = 10;

    /**
     * 비밀번호 재설정을 위해 인증번호(코드)를 이메일로 전송
     */
    @Transactional
    public void sendResetCode(String email) {
        // 1) 사용자 존재 여부 확인
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "해당 이메일의 사용자가 없습니다."));

        // 2) (선택) 이미 OAuth2 회원이면, 비밀번호 재설정 불가하도록 처리할 수 있음
         if (user.getOAuthType() != OAuthType.NONE) {
             throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "OAuth2 계정은 비밀번호 재설정이 불가능합니다.");
         }

        // 3) 인증번호 생성
        String code = generateCode(6); // 예: 6자리 숫자

        // 4) 기존 토큰 삭제 (1회성 관리)
        tokenRepository.deleteByUser(user);

        // 5) 새 토큰 생성 및 DB 저장
        LocalDateTime expiresAt = LocalDateTime.now().plusMinutes(RESET_TOKEN_EXPIRATION_MINUTES);
        PasswordResetToken resetToken = new PasswordResetToken(user, code, expiresAt);
        tokenRepository.save(resetToken);

        // 6) 이메일 전송
        String subject = "[HandTalk] 비밀번호 재설정을 위한 인증번호 안내";
        String content = "<h1>비밀번호 재설정 인증번호</h1>"
                + "<p>아래의 인증번호를 입력해 주세요.</p>"
                + "<h3>" + code + "</h3>"
                + "<p>유효 시간: " + RESET_TOKEN_EXPIRATION_MINUTES + "분</p>";
        emailService.sendEmail(email, subject, content);
    }

    /**
     * 사용자가 입력한 인증번호(코드) 검증
     */
    @Transactional
    public void verifyResetCode(String email, String code) {
        PasswordResetToken resetToken = getTokenByEmail(email);

        // 만료 체크
        if (resetToken.getExpiresAt().isBefore(LocalDateTime.now())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "인증번호가 만료되었습니다. 다시 요청해 주세요.");
        }

        // 코드 검증
        if (!resetToken.getCode().equals(code)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "인증번호가 올바르지 않습니다.");
        }
        // 검증 성공 시, 별도 로직 없음 (상태 체크용)
    }

    /**
     * 인증 코드 검증 후, 사용자가 제출한 새 비밀번호로 변경
     */
    @Transactional
    public void resetPassword(String email, PasswordResetRequestDto requestDto) {
        PasswordResetToken resetToken = getTokenByEmail(email);

        // 토큰 만료 체크 (verify 단계에서 했더라도 최종 변경 시 다시 한 번 체크)
        if (resetToken.getExpiresAt().isBefore(LocalDateTime.now())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "인증번호가 만료되었습니다. 다시 요청해 주세요.");
        }

        // **비밀번호 & 비밀번호 확인 필드 비교**
        if (!requestDto.getNewPassword().equals(requestDto.getConfirmPassword())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "새 비밀번호와 비밀번호 확인이 일치하지 않습니다.");
        }

        // 새 비밀번호 암호화 후 저장
        User user = resetToken.getUser();
        String encodedPassword = passwordEncoder.encode(requestDto.getNewPassword());
        user.setPassword(encodedPassword);
        userRepository.save(user);

        // 토큰 사용 후 삭제 (1회용)
        tokenRepository.delete(resetToken);
    }

    /**
     * PasswordResetToken 조회 메서드
     */
    private PasswordResetToken getTokenByEmail(String email) {
        Optional<PasswordResetToken> optionalToken = tokenRepository.findByUser_Email(email);
        if (optionalToken.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "해당 사용자는 인증번호가 발급되지 않았습니다.");
        }
        return optionalToken.get();
    }

    /**
     * 인증번호 생성 (기본: 숫자 N자리)
     */
    private String generateCode(int length) {
        Random random = new Random();
        StringBuilder sb = new StringBuilder();
        for(int i = 0; i < length; i++) {
            sb.append(random.nextInt(10)); // 0~9
        }
        return sb.toString();
    }
}
