# 🧠 HandTalk - 딥러닝 기반 수어 학습 어플리케이션 개발 (백엔드)

수어(수화)를 기반으로 한 커뮤니케이션 플랫폼의 백엔드 REST API 서버입니다.  
Spring Boot 3 기반으로 구현되었으며, 이메일 인증, 회원가입,문제출제, 통계 등 사용자 중심 기능을 제공합니다.

> 🔗 본 프로젝트는 팀 프로젝트이며, 본인은 **백엔드 전체 개발**을 담당했습니다.

---

🛠 기술 스택
분류	기술
언어	Java 21
프레임워크	Spring Boot 3
빌드 도구	Gradle
인증/보안	Spring Security (JWT 기반 로그인)
DB	MySQL
배포 인프라	Naver Cloud
메일 인증	Naver SMTP
API 방식	RESTful
기타	Firebase Firestore 연동 (AI 인식 결과 공유용)



---

🔑 주요 기능 요약
✅ 사용자 인증 및 관리
이메일 기반 회원가입 & JWT 로그인

닉네임 수정, 회원 탈퇴

이메일 중복 확인 API

✅ 학습 기능
자음, 모음, 단어별 학습 문제 출제

학습 결과 저장 및 진도율 조회

✅ 게임 기능
학습 기반 게임 문제 20개 자동 출제

게임 결과 저장 및 통계 제공

✅ 비밀번호 재설정
인증번호 발송 → 인증번호 검증 → 비밀번호 재설정 3단계 API

---

## 🧱 아키텍처 구조


<img width="807" alt="스크린샷 2025-05-28 오후 10 18 02" src="https://github.com/user-attachments/assets/82b704d8-689e-4e2c-8c74-0f803fa5c51a" />

---

🗂️ 폴더 구조
bash
복사
편집
📁 src/main/java/com/example/HandTalk
├── config               # JWT, Security 설정 등
├── controller           # REST API 컨트롤러
├── domain               # 엔티티 클래스
├── dto                  # 요청/응답 DTO
├── repository           # JPA 리포지토리
├── service              # 비즈니스 로직
├── util                 # 유틸 클래스 (ex. 토픽 로딩 등)

---
기술적 고민
