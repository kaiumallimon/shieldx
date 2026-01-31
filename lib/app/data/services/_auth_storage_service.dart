import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthStorageService {
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';
  static const String _keyRememberMe = 'remember_me';
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';

  Future<void> saveUserSession({
    required String userId,
    required String email,
    required String name,
    required String accessToken,
    required String refreshToken,
    bool rememberMe = true,
  }) async {
    if (!rememberMe) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyUserEmail, email);
    await prefs.setString(_keyUserName, name);
    await prefs.setString(_keyAccessToken, accessToken);
    await prefs.setString(_keyRefreshToken, refreshToken);
    await prefs.setBool(_keyRememberMe, rememberMe);
  }

  Future<Map<String, dynamic>?> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(_keyRememberMe) ?? false;

    if (!rememberMe) return null;

    final userId = prefs.getString(_keyUserId);
    final email = prefs.getString(_keyUserEmail);
    final name = prefs.getString(_keyUserName);
    final accessToken = prefs.getString(_keyAccessToken);
    final refreshToken = prefs.getString(_keyRefreshToken);

    if (userId == null || email == null || accessToken == null) {
      return null;
    }

    return {
      'userId': userId,
      'email': email,
      'name': name,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

  Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyRememberMe);
  }

  Future<bool> hasStoredSession() async {
    final session = await getUserSession();
    return session != null;
  }
}
