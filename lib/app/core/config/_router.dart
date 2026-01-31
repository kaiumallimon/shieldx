import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shieldx/app/features/auth/pages/_login_page.dart';
import 'package:shieldx/app/features/auth/pages/_register_page.dart';
import 'package:shieldx/app/features/splash/pages/_splash_page.dart';
import 'package:shieldx/app/features/welcome/pages/_welcome_page.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) =>
          material3TransitionPage(child: const SplashPage()),
    ),

    GoRoute(
      path: '/welcome',
      pageBuilder: (context, state) =>
          material3TransitionPage(child: const WelcomePage()),
    ),

    GoRoute(
      path: '/login',
      pageBuilder: (context, state) =>
          material3TransitionPage(child: const LoginPage()),
    ),

    GoRoute(
      path: '/register',
      pageBuilder: (context, state) =>
          material3TransitionPage(child: const RegisterPage()),
    ),
  ],
);

CustomTransitionPage<T> material3TransitionPage<T>({
  required Widget child,
  Duration duration = const Duration(milliseconds: 300),
  SharedAxisTransitionType type = SharedAxisTransitionType.scaled,
}) {
  return CustomTransitionPage<T>(
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SharedAxisTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: type,
        child: child,
      );
    },
  );
}
