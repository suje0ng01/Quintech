package com.example.HandTalk.service;

import com.example.HandTalk.dto.LoginRequestDto;
import com.example.HandTalk.dto.LoginResponseDto;
import com.example.HandTalk.repository.UserRepository;
import com.example.HandTalk.domain.User;
import com.example.HandTalk.config.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
@RequiredArgsConstructor
public class OAuthService {

    private final AuthenticationManager authenticationManager;
    private final UserRepository userRepository;
    private final JwtUtil jwtUtil;

    public LoginResponseDto login(LoginRequestDto requestDto) {
        // ✅ 1. 이메일 직접 먼저 확인
        User user = userRepository.findByEmail(requestDto.getEmail())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "존재하지 않는 이메일입니다."));

        try {
            // ✅ 2. 비밀번호 인증만 수행
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            requestDto.getEmail(),
                            requestDto.getPassword()
                    )
            );

            // ✅ 3. JWT 생성
            String token = jwtUtil.generateToken(user.getEmail(), user.getRole().name());
            return new LoginResponseDto(user, token);

        } catch (BadCredentialsException e) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "비밀번호가 틀렸습니다.");
        }
    }
}
