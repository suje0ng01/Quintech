package com.example.HandTalk.service;

import com.example.HandTalk.config.JwtUtil;
import com.example.HandTalk.repository.UserRepository;
import com.example.HandTalk.user.OAuthType;
import com.example.HandTalk.user.Role;
import com.example.HandTalk.user.User;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.core.user.DefaultOAuth2User;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class CustomOAuth2UserService extends DefaultOAuth2UserService {

    private final UserRepository userRepository;
    private final JwtUtil jwtUtil;

    @Override
    public OAuth2User loadUser(OAuth2UserRequest userRequest) {
        OAuth2User oAuth2User = super.loadUser(userRequest);
        Map<String, Object> attributes = oAuth2User.getAttributes(); // ✅ attributes 정의

        // ✅ Google에서 제공하는 사용자 정보
        String email = (String) attributes.get("email");
        String name = (String) attributes.get("name");
        String providerId = (String) attributes.get("sub"); // Google 고유 ID

        // ✅ 기존 사용자 확인
        User user = userRepository.findByEmail(email).orElse(null);

        if (user == null) {
            // ✅ 신규 사용자 등록 (Google OAuth2 로그인)
            String nickname = generateUniqueNickname(generateNickname(attributes));

            user = new User();
            user.setEmail(email);
            user.setName(name);
            user.setNickname(nickname); // 닉네임 추가
            user.setOAuthType(OAuthType.GOOGLE);
            user.setProvider("google");
            user.setProviderId(providerId);
            user.setRole(Role.USER); // 기본 역할 설정

            userRepository.save(user);
        } else if (user.getOAuthType() == OAuthType.NONE) {
            // ✅ 기존 일반 로그인 사용자가 Google 로그인 시도 시 오류 반환
            throw new RuntimeException("이미 존재하는 이메일입니다. 일반 로그인을 사용하세요!");
        }
        // ✅ JWT 발급 추가
        String jwtToken = jwtUtil.generateToken(user.getEmail(),user.getRole().name());
        System.out.println("JWT 생성: " + jwtToken);

        // ✅ JWT를 response에 포함
        Map<String, Object> newAttributes = new HashMap<>(attributes);
        newAttributes.put("jwtToken", jwtToken);


        return new DefaultOAuth2User(
                Collections.singletonList(new SimpleGrantedAuthority(user.getRole().name())),
                attributes,
                "email"
        );
    }

    // ✅ 닉네임 자동 생성 메서드
    private String generateNickname(Map<String, Object> attributes) {
        if (attributes.containsKey("nickname")) {
            return (String) attributes.get("nickname");
        } else if (attributes.containsKey("name")) {
            return (String) attributes.get("name");
        } else if (attributes.containsKey("email")) {
            return ((String) attributes.get("email")).split("@")[0]; // 이메일 앞부분 사용
        }
        return "user_" + UUID.randomUUID().toString().substring(0, 8);
    }

    // ✅ 닉네임 중복 검사 및 유니크한 닉네임 생성
    private String generateUniqueNickname(String baseNickname) {
        String nickname = baseNickname;
        int count = 1;
        while (userRepository.existsByNickname(nickname)) {
            nickname = baseNickname + count;
            count++;
        }
        return nickname;
    }
}
