import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shieldx/app/modules/auth/data/repository/_login_repository.dart';

class AccountServices {
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
  );

  final LoginRepository loginRepository = LoginRepository();

  AccountServices() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          String? accessToken = await loginRepository.getAccessToken();

          if (accessToken != null && accessToken.isNotEmpty) {
            bool isExpired = await loginRepository.isAccessTokenExpired();
            if (isExpired) {
              bool refreshed = await loginRepository.refreshToken();
              if (refreshed) {
                accessToken = await loginRepository.getAccessToken();
              } else {
                return handler.reject(
                  DioException(
                    requestOptions: options,
                    response: Response(
                      requestOptions: options,
                      statusCode: 401,
                      data: {'message': 'Session expired, please login again'},
                    ),
                    type: DioExceptionType.badResponse,
                  ),
                );
              }
            }
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
        } catch (e) {
          return handler.reject(DioException(
            requestOptions: options,
            error: 'Failed to attach token: $e',
          ));
        }

        return handler.next(options); // Continue request
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          print("❌ Unauthorized! Refreshing token...");
          bool refreshed = await loginRepository.refreshToken();
          if (refreshed) {
            String? newAccessToken = await loginRepository.getAccessToken();
            if (newAccessToken != null) {
              e.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
              return handler.resolve(await dio.fetch(e.requestOptions));
            }
          }
          print("⚠️ Refresh token failed. User needs to login again.");
        }
        return handler.next(e);
      },
    ));
  }

  Future<Map<String, dynamic>> getAccountDetails() async {
    try {
      final response = await dio.get('/api/profile/me');
      return response.data;
    } on DioException catch (e) {
      print("⚠️ Error fetching account details: ${e.message}");
      return {'error': e.response?.data ?? 'Failed to fetch account details'};
    } catch (e) {
      print("⚠️ Unexpected error: $e");
      return {'error': 'An unexpected error occurred'};
    }
  }
}
