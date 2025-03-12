package com.example.HandTalk.service;

import com.example.HandTalk.repository.UserRepository;
import com.example.HandTalk.user.OAuthType;
import com.example.HandTalk.user.Role;
import com.example.HandTalk.user.User;
import lombok.RequiredArgsConstructor;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.core.user.DefaultOAuth2User;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;
import java.util.Collections;

@Service
@RequiredArgsConstructor
public class CustomOAuth2UserService extends DefaultOAuth2UserService {

    private final UserRepository userRepository;

    @Override
    public OAuth2User loadUser(OAuth2UserRequest userRequest) {
        OAuth2User oAuth2User = super.loadUser(userRequest);

        // ✅ Google에서 제공하는 사용자 정보
        String email = oAuth2User.getAttribute("email");
        String name = oAuth2User.getAttribute("name");
        String providerId = oAuth2User.getAttribute("sub"); // Google 고유 ID

        // ✅ 기존 사용자 확인
        User user = userRepository.findByEmail(email).orElse(null);

        if (user == null) {
            // ✅ 신규 사용자 등록 (Google OAuth2 로그인)
            user = new User();
            user.setEmail(email);
            user.setName(name);
            user.setOAuthType(OAuthType.GOOGLE);
            user.setProvider("google");
            user.setProviderId(providerId);
            user.setRole(Role.USER); // 기본 역할 설정
            userRepository.save(user);
        } else if (user.getOAuthType() == OAuthType.NONE) {
            // ✅ 기존 일반 로그인 사용자가 Google 로그인 시도 시 오류 반환
            throw new RuntimeException("이미 존재하는 이메일입니다. 일반 로그인을 사용하세요!");
        }

        return new DefaultOAuth2User(Collections.emptyList(), oAuth2User.getAttributes(), "email");
    }
}
