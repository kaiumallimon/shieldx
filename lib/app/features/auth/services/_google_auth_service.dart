import 'package:shieldx/app/data/services/_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoogleAuthService {
  /// Sign in with Google using OAuth
  Future<GoogleAuthModel> signInWithGoogle() async {
    try {
      final client = SupabaseService.client;

      final response = await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.shieldx://login-callback/',
      );

      if (!response) {
        throw Exception('Google sign-in was cancelled or failed');
      }

      // Wait for the session to be established
      await Future.delayed(const Duration(seconds: 2));

      final session = client.auth.currentSession;
      final user = client.auth.currentUser;

      if (user == null || session == null) {
        throw Exception('Failed to get user session after Google sign-in');
      }

      // Check if profile exists, create if not
      await _ensureProfileExists(user);

      return GoogleAuthModel(
        user: user,
        session: session,
      );
    } catch (error) {
      rethrow;
    }
  }

  /// Ensure user profile exists in the profiles table
  Future<void> _ensureProfileExists(User user) async {
    try {
      final client = SupabaseService.client;

      // Check if profile already exists
      final existingProfile = await client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (existingProfile == null) {
        // Create profile from Google user data
        final fullName = user.userMetadata?['full_name'] ??
            user.userMetadata?['name'] ??
            user.email?.split('@').first ??
            'User';

        await client.from('profiles').insert({
          'id': user.id,
          'full_name': fullName,
          'email': user.email ?? '',
          'avatar_url': user.userMetadata?['avatar_url'] ??
              user.userMetadata?['picture'],
        });
      }
    } catch (error) {
      // If profile creation fails, continue anyway as user is authenticated
      // The profile can be created later
      print('Profile creation warning: $error');
    }
  }
}

class GoogleAuthModel {
  final User user;
  final Session session;

  GoogleAuthModel({
    required this.user,
    required this.session,
  });
}
