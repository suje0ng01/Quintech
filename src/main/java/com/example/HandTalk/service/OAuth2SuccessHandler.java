package com.example.HandTalk.service;

import com.example.HandTalk.config.JwtUtil;
import com.example.HandTalk.repository.UserRepository;
import com.example.HandTalk.user.User;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;

@Component
@RequiredArgsConstructor
public class OAuth2SuccessHandler implements AuthenticationSuccessHandler {

    private final JwtUtil jwtUtil;
    private final UserRepository userRepository;

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response, Authentication authentication) throws IOException {
        OAuth2User oAuth2User = (OAuth2User) authentication.getPrincipal();
        String email = oAuth2User.getAttribute("email");

        // ✅ DB에서 사용자 조회
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("사용자를 찾을 수 없습니다."));

        // ✅ JWT 생성 (email & role 포함)
        String token = jwtUtil.generateToken(user.getEmail(), user.getRole().name());

        // ✅ 클라이언트에 JWT 전달 (리디렉션 방식)
        response.sendRedirect("/success?token=" + token);
    }
}
