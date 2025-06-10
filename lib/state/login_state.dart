import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginState with ChangeNotifier {
  bool _isLoggedIn = false;
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  bool get isLoggedIn => _isLoggedIn;
  bool get isInitialized => _isInitialized;

  String? get name => _prefs.getString('name');
  String? get email => _prefs.getString('email');
  String? get nickname => _prefs.getString('nickname');
  String? get token => _prefs.getString('token');
  int? get userId => _prefs.getInt('userId');

  int? _streak;
  int? get streak => _streak;

  LoginState() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _isLoggedIn = _prefs.getBool('isLoggedIn') ?? false;
    _isInitialized = true;

    // 로그인 상태라면 streak도 불러오기
    if (_isLoggedIn) {
      await fetchStreak();
    }

    notifyListeners();
  }

  Future<void> logIn({
    required String name,
    required String email,
    required String nickname,
    required int userId,
    required String token,
  }) async {
    await _prefs.setBool('isLoggedIn', true);
    await _prefs.setString('token', token);
    await _prefs.setString('name', name);
    await _prefs.setString('email', email);
    await _prefs.setString('nickname', nickname);
    await _prefs.setInt('userId', userId);

    _isLoggedIn = true;
    await fetchStreak(); // 로그인 후 streak도 가져오기
    notifyListeners();
  }

  Future<void> logOut() async {
    await _prefs.clear();
    _isLoggedIn = false;
    _streak = null;
    notifyListeners();
  }

  Future<void> updateNickname(String newNickname) async {
    await _prefs.setString('nickname', newNickname);
    notifyListeners();
  }

  Future<void> fetchStreak() async {
    final String? userToken = token;
    if (userToken == null) return;

    try {
      final response = await http.get(
        Uri.parse('http://223.130.136.121:8082/api/user/check'),
        headers: {
          'Authorization': 'Bearer $userToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _streak = data['streak']; // ✅ 여기서 바로 streak 가져오기
        notifyListeners();
      } else {
        print('Failed to fetch streak: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching streak: $e');
    }
  }
}
