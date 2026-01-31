import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  /// Check onboarding status and navigate accordingly after 2 seconds
  Future<void> _navigateAfterDelay() async {
    // Wait for 2 seconds to show splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check if user has completed onboarding
    final prefs = await SharedPreferences.getInstance();
    final hasCompletedOnboarding = prefs.getBool('onboarded') ?? false;

    if (!mounted) return;

    // Navigate based on onboarding status
    if (hasCompletedOnboarding) {
      context.go('/auth?index=1');
    } else {
      context.go('/welcome');
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
