import '../services/_login_service.dart';

class LoginRepository {
  final LoginService _loginService = LoginService();

  /// Logs in and returns the response
  Future<Map<String, dynamic>> login(
      {required Map<String, dynamic> data}) async {
    return await _loginService.login(data: data);
  }

  /// Stores access and refresh tokens
  Future<bool> storeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    return await _loginService.storeTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  /// Retrieves stored access token
  Future<String?> getAccessToken() async {
    return await _loginService.getAccessToken();
  }

  /// Retrieves stored refresh token
  Future<String?> getRefreshToken() async {
    return await _loginService.getRefreshToken();
  }

  /// Refreshes the access token
  Future<bool> refreshToken() async {
    return await _loginService.refreshToken();
  }

  /// Deletes stored tokens
  Future<bool> deleteTokens() async {
    return await _loginService.deleteTokens();
  }

  /// Logs out the user
  Future<bool> logout() async {
    return await _loginService.logout();
  }

  /// check if access token is expired
  Future<bool> isAccessTokenExpired() async {
    return await _loginService.isTokenExpired();
  }
}
