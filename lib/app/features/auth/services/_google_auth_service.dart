import 'dart:async';
import 'package:shieldx/app/data/services/_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoogleAuthService {
  /// Sign in with Google using OAuth
  /// Waits for auth state change and returns the authenticated user
  Future<GoogleAuthModel> signInWithGoogle() async {
    try {
      final client = SupabaseService.client;

      // Create a completer to wait for auth state change
      final completer = Completer<GoogleAuthModel>();

      // Listen for auth state changes
      late final StreamSubscription<AuthState> subscription;
      subscription = client.auth.onAuthStateChange.listen((data) async {
        final session = data.session;
        if (session != null && !completer.isCompleted) {
          // Cancel subscription
          await subscription.cancel();

          // Check if profile exists, create if not
          await _ensureProfileExists(session.user);

          completer.complete(GoogleAuthModel(
            user: session.user,
            session: session,
          ));
        }
      });

      // Start OAuth flow - this will open browser
      final success = await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.shieldx://login-callback',
      );

      if (!success) {
        await subscription.cancel();
        throw Exception('Google sign-in was cancelled or failed');
      }

      // Wait for auth state change or timeout after 60 seconds
      return await completer.future.timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          subscription.cancel();
          throw Exception('Google sign-in timeout - please try again');
        },
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
