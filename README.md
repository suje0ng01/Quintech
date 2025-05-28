# 🧠 HandTalk - 수어 기반 커뮤니케이션 웹 플랫폼 (백엔드)

수어(수화)를 기반으로 한 커뮤니케이션 플랫폼의 백엔드 서버입니다.  
Spring Boot로 구축되었으며, JWT 인증, Google OAuth2, 이메일 인증, 수어 영상 업로드 기능 등을 제공합니다.

> 🔗 본 프로젝트는 팀 프로젝트였으며, 본인은 **백엔드 전반**을 담당했습니다.

---

## 🛠 기술 스택

| 분야 | 기술 |
|------|------|
| 언어 | Java 17 |
| 프레임워크 | Spring Boot, Spring Security, OAuth2 Client |
| ORM | Spring Data JPA (Hibernate) |
| DB | MySQL 8.x |
| 배포 | AWS EC2, GitHub Actions |
| 인증 | JWT, OAuth2 (Google), Naver SMTP 이메일 인증 |
| 파일 업로드 | AWS S3 SDK (NCP 호환) |
| 기타 | Lombok, JUnit5, Thymeleaf, Validation |

---

## 🔐 주요 기능 요약

- ✅ 회원가입 / 로그인 (JWT 인증 기반)
- 🔒 Google OAuth2 로그인 (Google 계정 연동)
- ✉️ 이메일 인증 (SMTP/Naver)
- 📄 게시물 등록, 수어 영상 업로드
- 👥 관리자/사용자 권한 분리
- ☁️ AWS S3 기반 파일 업로드
- 🐞 Spring Security 기반 보안 정책
- 🧪 인증/인가 테스트 및 예외처리

---

## 🧱 시스템 아키텍처 (텍스트 표현)

```plaintext
[ Client (웹/모바일) ]
        ↓
[ Controller (REST API) ]
        ↓
[ Service Layer ]
        ↓
[ Repository (JPA) ] → [ MySQL ]
        ↓
[ JWT Token 발급/검증 ]
        ↓
[ OAuth2 (Google) ]
        ↓
[ Email 인증 (SMTP) ]
        ↓
[ 영상 업로드 (AWS S3) ]




src/
├── controller       # API 진입 지점
├── service          # 비즈니스 로직
├── repository       # JPA 인터페이스
├── entity           # 도메인 모델
├── config           # 보안, CORS, 필터 설정
├── security         # JWT 인증 관련 클래스
├── dto              # 요청/응답 DTO
└── util             # 유틸리티/도우미 클래스

