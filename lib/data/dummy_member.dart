/// 더미 유저 데이터 모델
class DummyUser {
  final int id;
  final String name;
  final String nickname;
  final String email;
  final String password;
  final String profileImageUrl;
  final int attendanceDays;

  const DummyUser({
    required this.id,
    required this.name,
    required this.nickname,
    required this.email,
    required this.password,
    required this.profileImageUrl,
    required this.attendanceDays,
  });

  /// 예시 더미 사용자
  static const example = DummyUser(
    id: 1,
    name: '홍길동',
    nickname: '별명',
    email: 'example@email.com',
    password: 'pw1234',
    profileImageUrl: 'https://i.pravatar.cc/150?img=50',
    attendanceDays: 57,
  );

  /// 회원가입 API 요청 바디 예시
  static Map<String, dynamic> get registerRequest => {
        'name': example.name,
        'nickname': example.nickname,
        'email': example.email,
        'password': example.password,
      };

  /// 로그인 API 요청 바디 예시
  static Map<String, dynamic> get loginRequest => {
        'email': example.email,
        'password': example.password,
      };

  /// /api/user/check API 응답 예시
  static Map<String, dynamic> get checkResponse => {
        'id': example.id,
        'name': example.name,
        'nickname': example.nickname,
        'email': example.email,
        'profile_image': example.profileImageUrl,
        'attendance_days': example.attendanceDays,
      };
}