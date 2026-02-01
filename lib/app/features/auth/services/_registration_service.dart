import 'package:shieldx/app/data/services/_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegistrationService {
  Future<RegistrationModel> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final client = SupabaseService.client;

      // Create user account
      final response = await client.auth.signUp(
        email: email,
        password: password,

      );

      final user = response.user;

      if (user == null) {
        throw Exception('User registration failed');
      }

      // Insert user profile data into 'profiles' table
      try {
        await client.from('profiles').insert({
          'id': user.id,
          'full_name': name,
          'email': email,
        });
      } catch (profileError) {
        // If profile insertion fails, attempt to clean up the user
        try {
          await client.auth.admin.deleteUser(user.id);
        } catch (_) {
          // Ignore cleanup errors
        }
        throw Exception('Failed to create user profile: $profileError');
      }

      return RegistrationModel.fromAuthResponse(response);
    } catch (error) {
      rethrow;
    }
  }
}

class RegistrationModel{
  final User? user;
  final Session? session;
  final String? avatarUrl;

  RegistrationModel({
    required this.user,
    required this.session,
    this.avatarUrl,
  });

  factory RegistrationModel.fromAuthResponse(AuthResponse response, {String? avatarUrl}){
    return RegistrationModel(
      user: response.user,
      session: response.session,
      avatarUrl: avatarUrl,
    );
  }

  Map<String, dynamic> toMap(){
    return {
      'user': user?.toJson(),
      'session': session?.toJson(),
    };
  }
}