package com.example.HandTalk.config;

import com.example.HandTalk.service.CustomUserDetailsService;
import com.example.HandTalk.service.CustomOAuth2UserService;
import com.example.HandTalk.service.OAuth2SuccessHandler;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

/**
 * 🔹 Spring Security 설정 - JWT + OAuth2 적용
 */
@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final CustomUserDetailsService customUserDetailsService;
    private final JwtUtil jwtUtil;
    private final CustomOAuth2UserService customOAuth2UserService;
    private final OAuth2SuccessHandler oAuth2SuccessHandler;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .csrf(csrf -> csrf.disable()) // ✅ CSRF 비활성화 (JWT 사용 시 필요)
                .cors(cors -> cors.configure(http)) // ✅ CORS 허용 설정
                .sessionManagement(session -> session.sessionCreationPolicy(org.springframework.security.config.http.SessionCreationPolicy.STATELESS)) // ✅ 세션 사용 X (JWT 사용)
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/", "/login", "/register","api/**", "/api/user/register", "/success", "/auth/login", "/oauth2/**","/auth/oauth/google/**","/api/user/**","/auth/**","/check-in/**","/api/password/**").permitAll() // ✅ 로그인, 회원가입은 모두 허용
                        .anyRequest().authenticated() // ✅ 나머지는 인증 필요
                )
                .exceptionHandling(exception -> exception
                        .authenticationEntryPoint((request, response, authException) -> response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized"))
                )
                // ✅ JWT 필터 추가 (인증)
                .addFilterBefore(new JwtAuthenticationFilter(authenticationManager(http.getSharedObject(AuthenticationConfiguration.class)), jwtUtil, customUserDetailsService),
                        UsernamePasswordAuthenticationFilter.class)
                // ✅ JWT 필터 추가 (권한 검증)
                .addFilterBefore(new JwtAuthorizationFilter(jwtUtil, customUserDetailsService),
                        UsernamePasswordAuthenticationFilter.class)
                // ✅ OAuth2 로그인 설정 추가
                .oauth2Login(oauth2 -> oauth2
                        .loginPage("/login") // OAuth2 로그인 페이지 지정
                        .userInfoEndpoint(userInfo -> userInfo.userService(customOAuth2UserService)) // OAuth2 사용자 정보 처리
                        .successHandler(oAuth2SuccessHandler) // 로그인 성공 후 JWT 발급
                );

        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    // ✅ AuthenticationManager Bean 등록 (JWT 인증에 필요)
    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration authenticationConfiguration) throws Exception {
        return authenticationConfiguration.getAuthenticationManager();
    }
}