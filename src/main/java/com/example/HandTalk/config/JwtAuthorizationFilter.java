package com.example.HandTalk.config;

import com.example.HandTalk.service.CustomUserDetailsService;
import io.jsonwebtoken.Claims;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

/**
 * 🔹 JWT 인증 필터 (모든 요청마다 JWT 검사 & 인증)
 */
@RequiredArgsConstructor
public class JwtAuthorizationFilter extends OncePerRequestFilter {

    private final JwtUtil jwtUtil;
    private final CustomUserDetailsService userDetailsService;

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain chain)
            throws ServletException, IOException {

        // 1. 요청 헤더에서 Authorization 값 추출
        String authorizationHeader = request.getHeader("Authorization");
        if (authorizationHeader == null || !authorizationHeader.startsWith("Bearer ")) {
            // JWT가 없다면 익명 사용자로 간주 -> 다음 필터로
            chain.doFilter(request, response);
            return;
        }

        // 2. "Bearer " 접두사 제거 후 실제 토큰만 추출
        String token = authorizationHeader.substring(7);

        try {
            // 3. 토큰 검증 및 정보 파싱
            Claims claims = jwtUtil.parseToken(token);
            String email = claims.getSubject();          // 표준 클레임: sub → email
            String role = claims.get("role", String.class);  // 커스텀 클레임: role

            // 4. SecurityContext에 인증 정보가 없는 경우에만 설정
            if (email != null && SecurityContextHolder.getContext().getAuthentication() == null) {

                // 5. DB에서 사용자 정보 조회 (UserDetailsService)
                //    → UserDetails에는 username(=email), password, authorities 정보가 있어야 함
                UserDetails userDetails = userDetailsService.loadUserByUsername(email);

                // 6. 인증 토큰 생성 (Spring Security 인증 객체)
                UsernamePasswordAuthenticationToken authentication =
                        new UsernamePasswordAuthenticationToken(
                                userDetails,
                                null,
                                userDetails.getAuthorities() // 권한 목록
                        );
                authentication.setDetails(
                        new WebAuthenticationDetailsSource().buildDetails(request)
                );

                // 7. SecurityContext에 인증 정보 등록
                SecurityContextHolder.getContext().setAuthentication(authentication);
            }

        } catch (Exception e) {
            // JWT 검증 실패 시 로그만 남기고 익명 사용자로 처리
            System.err.println("🔴 JWT 검증 실패: " + e.getMessage());
        }

        // 8. 다음 필터로 넘어가기
        chain.doFilter(request, response);
    }
}
