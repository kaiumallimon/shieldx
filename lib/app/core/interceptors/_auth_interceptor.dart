import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../modules/auth/data/services/_login_service.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final LoginService loginService = LoginService();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final accessToken = await storage.read(key: 'accessToken');

    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 403) {
      bool refreshed = await loginService.refreshToken();

      if (refreshed) {
        final accessToken = await storage.read(key: 'accessToken');
        err.requestOptions.headers['Authorization'] = 'Bearer $accessToken';

        try {
          final retryResponse = await loginService.dio.fetch(err.requestOptions);
          return handler.resolve(retryResponse);
        } catch (e) {
          return handler.reject(err);
        }
      }
    }

    handler.next(err);
  }
}
