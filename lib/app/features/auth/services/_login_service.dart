import 'package:shieldx/app/data/services/_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginService {
  Future<LoginModel> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final client = SupabaseService.client;

      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      final session = response.session;

      if (user == null || session == null) {
        throw Exception('Login failed');
      }

      return LoginModel.fromAuthResponse(response);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final client = SupabaseService.client;
      await client.auth.signOut();
    } catch (error) {
      rethrow;
    }
  }

  Future<LoginModel?> getCurrentUser() async {
    try {
      final client = SupabaseService.client;
      final session = client.auth.currentSession;
      final user = client.auth.currentUser;

      if (user == null || session == null) {
        return null;
      }

      return LoginModel(
        user: user,
        session: session,
      );
    } catch (error) {
      return null;
    }
  }
}

class LoginModel {
  final User user;
  final Session session;

  LoginModel({
    required this.user,
    required this.session,
  });

  factory LoginModel.fromAuthResponse(AuthResponse response) {
    return LoginModel(
      user: response.user!,
      session: response.session!,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user': user.toJson(),
      'session': session.toJson(),
    };
  }
}
