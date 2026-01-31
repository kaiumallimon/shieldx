import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => material3TransitionPage(
        child: const Scaffold(body: Center(child: Text('Home Page'))),
      ),
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
