import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RegisterService {
  final dio = Dio(BaseOptions(
      baseUrl: dotenv.env['BASE_SERVER_URL']!,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }));

  Future<Map<String, dynamic>> register(
      {required Map<String, dynamic> data}) async {
    try {
      final response = await dio.post('/api/auth/register', data: data);

      if (response.statusCode == 201) {
        print(response.data);
        return {'status': 'success', 'message': 'User registered successfully'};
      } else {
        print("Error: ${response.data}");
        return {
          'status': 'error',
          'message': response.data['message'] ?? 'Registration failed'
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }
}
