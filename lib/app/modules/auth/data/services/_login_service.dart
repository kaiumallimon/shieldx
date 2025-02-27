import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../../../core/interceptors/_auth_interceptor.dart';

class LoginService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: dotenv.env['BASE_SERVER_URL'] ?? '',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  )..interceptors.add(AuthInterceptor());

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  /// Logs in and returns the response with token data
  Future<Map<String, dynamic>> login(
      {required Map<String, dynamic> data}) async {
    try {
      final response = await dio.post('/api/auth/login', data: data);

      if (response.statusCode == 200 && response.data != null) {
        return {'status': 'success', 'data': response.data['data']};
      } else {
        return {
          'status': 'error',
          'message': response.data?['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Login request failed: $e'};
    }
  }

  

  /// Refreshes the access token if expired
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await storage.read(key: 'refreshToken');
      if (refreshToken == null) return false;

      final response = await dio
          .post('/api/auth/refresh', data: {'refresh_token': refreshToken});

      if (response.statusCode == 200 && response.data != null) {
        await storeTokens(
          accessToken: response.data['accessToken'],
          refreshToken: response.data['refreshToken'],
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Stores tokens securely
  Future<bool> storeTokens(
      {required String accessToken, required String refreshToken}) async {
    try {
      await storage.write(key: 'accessToken', value: accessToken);
      await storage.write(key: 'refreshToken', value: refreshToken);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Retrieves the stored access token
  Future<String?> getAccessToken() async =>
      await storage.read(key: 'accessToken');

  /// Retrieves the stored refresh token
  Future<String?> getRefreshToken() async =>
      await storage.read(key: 'refreshToken');

  /// Deletes access and refresh tokens
  Future<bool> deleteTokens() async {
    try {
      await storage.delete(key: 'accessToken');
      await storage.delete(key: 'refreshToken');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Logs out the user by clearing authentication data
  Future<bool> logout() async {
    try {
      await storage.deleteAll();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isTokenExpired() async {
    String? token = await storage.read(key: 'accessToken');
    if (token == null) return true; // No token means expired

    // Decode JWT and check expiration
    return JwtDecoder.isExpired(token);
  }
}
