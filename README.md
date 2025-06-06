![Visitor Count](https://visitor-badge.laobi.icu/badge?page_id=bbbbs17.Quintech)

# 🧠 HandTalk - 딥러닝 기반 수어 학습 어플리케이션 개발 (백엔드)

수어(수화)를 기반으로 한 커뮤니케이션 플랫폼의 **백엔드 REST API 서버**입니다.  
Spring Boot 3 기반으로 구현되었으며, 이메일 인증, 회원가입, 문제 출제, 통계 등 사용자 중심 기능을 제공합니다.

> 🔗 **본 프로젝트는 팀 프로젝트이며, 본인은 백엔드 전체 개발을 담당했습니다.**

---

## 🛠 기술 스택

| 분류       | 기술                                           |
|------------|------------------------------------------------|
| 언어       | Java 21                                        |
| 프레임워크 | Spring Boot 3                                  |
| 빌드 도구  | Gradle                                         |
| 인증/보안  | Spring Security (JWT 기반 로그인)              |
| DB         | MySQL                                          |
| 배포 인프라 | Naver Cloud                                    |
| 메일 인증  | Naver SMTP                                     |
| API 방식   | RESTful                                        |


---

## 🔑 주요 기능 요약

### ✅ 사용자 인증 및 관리
- 이메일 기반 회원가입 및 JWT 로그인
- 닉네임 수정, 회원 탈퇴
- 이메일 중복 확인 API

### ✅ 학습 기능
- 자음, 모음, 단어별 학습 문제 출제
- 학습 결과 저장 및 진도율 조회

### ✅ 게임 기능
- 학습 기반 게임 문제 자동 출제 (최대 20개)
- 게임 결과 저장 및 주간 통계 제공

### ✅ 비밀번호 재설정
- 인증번호 발송 → 인증번호 검증 → 비밀번호 재설정  
  (총 3단계 API 제공)

---

## 🧱 아키텍처 구조

> AI 수어 인식, Flutter 앱, 백엔드, Firestore 연동 포함 전체 시스템 구성

<img width="819" alt="스크린샷 2025-05-28 오후 10 20 43" src="https://github.com/user-attachments/assets/fee31458-476c-4242-bf95-d1e522069224" />
  

---

## 🗂️ 폴더 구조

📁 src/main/java/com/example/HandTalk

├── 📁 config # JWT, Security 등 설정

├── 📁 controller # REST API 엔드포인트

├── 📁 domain # JPA 엔티티 클래스

├── 📁 dto # 요청/응답 DTO

├── 📁 repository # JPA 인터페이스

├── 📁 service # 핵심 비즈니스 로직

└── 📁 util # 공통 유틸 (ex. JSON 로더 등)

---


## 🧩 데이터베이스 ERD 구조

> 주요 테이블 간 관계를 나타낸 ERD입니다. (MySQL 기준)

> <img width="838" alt="스크린샷 2025-05-28 오후 11 57 28" src="https://github.com/user-attachments/assets/639b4003-53da-4b5c-ae37-9da98f0162ef" />


---


## ⚙️ 기술적 고민과 해결

---

### 1️⃣ Lazy Loading과 연관 엔티티 접근 시점 제어

🧩 문제 상황  
수어 학습 결과, 게임 기록, 출석 등은 모두 `User`와 연관된 엔티티입니다.  
연관 관계는 `@ManyToOne(fetch = LAZY)`로 설정되어 있어, 실제 접근 시점에 쿼리가 발생합니다.

```java
// CheckInService.java
CheckIn checkIn = new CheckIn();
checkIn.setUser(user);          // LAZY 설정 → 이 시점엔 쿼리 X
checkInRepository.save(checkIn);

// 통계 API 호출 시
List<CheckIn> checkIns = 
    checkInRepository.findByUserOrderByCheckInDateDesc(user);
```
✅ 고민과 해결

불필요한 N+1 쿼리 발생 방지를 위해 @EntityGraph 또는 join fetch 적용 고려

연관 객체 접근 시점과 쿼리 발생 시점을 명확히 인식하고 설계


### 2️⃣ 관심사 분리 (Separation of Concerns)

🧩 적용 예시: 이메일 인증 및 비밀번호 재설정

```java
// PasswordResetService.java
String token = UUID.randomUUID().toString();
emailService.sendEmail(email, subject, content);
```

✅ 고민과 해결

메일 전송 로직을 EmailService로 분리하여
👉 기술 세부사항(이메일 구현)
👉 비즈니스 로직(비밀번호 재설정)
을 명확히 분리

이후 Naver SMTP → 다른 메일 서비스 등으로 전환되더라도 서비스 로직 변경 없음


### 3️⃣ 통계 및 쿼리 응답 최적화
🧩 문제 상황
사용자의 학습 진도율과 최근 학습 이력을 /api/practice/progress 한 API에서 함께 반환해야 했음


```java
// PracticeService.java
practiceLogRepository.findTopByUserOrderByFinishedAtDesc(user);  // 최근 학습 이력
practiceLogRepository.countByContentTypeAndUser(...);             // 통계 데이터'
```

✅ 고민과 해결

복수 쿼리로 데이터를 나누어 조회한 뒤, DTO로 통합 응답

복잡한 조건이 많아지면 QueryDSL 등으로 통합 쿼리 리팩토링 고려



