import 'package:flutter/material.dart';
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

  LoginState() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _isLoggedIn = _prefs.getBool('isLoggedIn') ?? false;
    _isInitialized = true;
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
    notifyListeners();
  }

  Future<void> logOut() async {
    await _prefs.clear();
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<void> updateNickname(String newNickname) async {
    await _prefs.setString('nickname', newNickname);
    notifyListeners();
  }
}
