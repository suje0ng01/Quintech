package com.example.HandTalk.config;

import com.example.HandTalk.domain.User;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

/**
 * 로그인 필터: JWT를 생성하여 응답
 */
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends UsernamePasswordAuthenticationFilter {

    private final AuthenticationManager authenticationManager;
    private final JwtUtil jwtUtil;
    private final UserDetailsService userDetailsService;

    @Override
    public Authentication attemptAuthentication(HttpServletRequest request, HttpServletResponse response)
            throws AuthenticationException {
        try {
            // 요청 바디에서 email, password 파싱
            User loginRequest = new ObjectMapper().readValue(request.getInputStream(), User.class);

            // 인증 토큰 생성 (email + password)
            UsernamePasswordAuthenticationToken authenticationToken =
                    new UsernamePasswordAuthenticationToken(loginRequest.getEmail(), loginRequest.getPassword());

            // AuthenticationManager를 사용하여 인증 시도
            return authenticationManager.authenticate(authenticationToken);
        } catch (IOException e) {
            throw new RuntimeException("로그인 요청을 읽을 수 없습니다.", e);
        }
    }

    @Override
    protected void successfulAuthentication(HttpServletRequest request, HttpServletResponse response,
                                            FilterChain chain, Authentication authResult)
            throws IOException, ServletException {
        // 인증된 사용자 정보 가져오기
        UserDetails userDetails = (UserDetails) authResult.getPrincipal();

        // 사용자 email 가져오기
        String email = userDetails.getUsername(); // email 사용
        String role = userDetails.getAuthorities().stream()
                .findFirst()
                .map(String::valueOf)
                .orElse("USER"); // 기본값 USER

        // JWT 토큰 생성
        String token = jwtUtil.generateToken(email, role);

        // 응답 헤더에 JWT 추가
        response.setHeader("Authorization", "Bearer " + token);

        // JSON 응답으로도 토큰을 제공
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        Map<String, String> tokenResponse = new HashMap<>();
        tokenResponse.put("token", token);
        tokenResponse.put("email", email);
        tokenResponse.put("role", role);

        if (!response.isCommitted()) {  // 응답이 아직 커밋되지 않았다면 작성
            ObjectMapper objectMapper = new ObjectMapper();
            objectMapper.writeValue(response.getWriter(), tokenResponse);
            response.getWriter().flush();  // 강제 전송
        }
    }

    @Override
    protected void unsuccessfulAuthentication(HttpServletRequest request, HttpServletResponse response,
                                              AuthenticationException failed)
            throws IOException, ServletException {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        Map<String, String> errorResponse = new HashMap<>();
        errorResponse.put("error", "인증 실패: " + failed.getMessage());

        if (!response.isCommitted()) {
            ObjectMapper objectMapper = new ObjectMapper();
            objectMapper.writeValue(response.getWriter(), errorResponse);
            response.getWriter().flush();
        }
    }
}
