import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shieldx/app/data/services/_auth_storage_service.dart';
import 'package:shieldx/app/data/services/_supabase.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final AuthStorageService _authStorage = AuthStorageService();

  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  /// Check auth status and navigate accordingly after 2 seconds
  Future<void> _navigateAfterDelay() async {
    // Wait for 2 seconds to show splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check if user has completed onboarding
    final prefs = await SharedPreferences.getInstance();
    final hasCompletedOnboarding = prefs.getBool('onboarded') ?? false;

    if (!hasCompletedOnboarding) {
      if (mounted) context.go('/welcome');
      return;
    }

    // Check if user has stored session
    final hasStoredSession = await _authStorage.hasStoredSession();

    // Check if Supabase has active session
    final supabaseSession = SupabaseService.client.auth.currentSession;

    if (hasStoredSession && supabaseSession != null) {
      // User is authenticated, go to home
      if (mounted) context.go('/home');
    } else {
      // Clear any stale local data
      await _authStorage.clearUserSession();
      // User is not authenticated, go to auth page
      if (mounted) context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final windowSize = MediaQuery.sizeOf(context);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Image.asset(
                'assets/logo/1.png',
                height: windowSize.height * 0.4,
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: CupertinoActivityIndicator(
                  color: theme.colorScheme.onSurface.withAlpha(128),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
