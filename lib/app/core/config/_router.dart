import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shieldx/app/features/auth/pages/_auth_page.dart';
import 'package:shieldx/app/features/dashboard/_wrapper_page.dart';
import 'package:shieldx/app/features/dashboard/features/generator/pages/_generator_page.dart';
import 'package:shieldx/app/features/dashboard/features/security/pages/_security_page.dart';
import 'package:shieldx/app/features/dashboard/features/settings/pages/_settings_page.dart';
import 'package:shieldx/app/features/dashboard/features/vault/pages/_vault_page.dart';
import 'package:shieldx/app/features/dashboard/features/vault/pages/_vault_item_detail_page.dart';
import 'package:shieldx/app/features/dashboard/features/tools/pages/_tools_page.dart';
import 'package:shieldx/app/features/dashboard/features/manage/pages/_manage_page.dart';
import 'package:shieldx/app/features/dashboard/features/manage/pages/_all_passwords_page.dart';
import 'package:shieldx/app/features/dashboard/features/manage/pages/_category_detail_page.dart';
import 'package:shieldx/app/features/dashboard/features/manage/pages/_type_detail_page.dart';
import 'package:shieldx/app/features/splash/pages/_splash_page.dart';
import 'package:shieldx/app/features/welcome/pages/_welcome_page.dart';
import 'package:shieldx/app/data/models/vault_item_model.dart';

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
      path: '/auth',
      pageBuilder: (context, state) {
        final index = state.uri.queryParameters['index'];
        return material3TransitionPage(
          child: AuthPage(
            initialIndex: index != null ? int.tryParse(index) ?? 1 : 1,
          ),
        );
      },
    ),

    ShellRoute(
      builder: (context, state, child) {
        return WrapperPage(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) {
            return NoTransitionPage(child: const VaultPage());
          },
        ),
        GoRoute(
          path: '/security',
          pageBuilder: (context, state) {
            return NoTransitionPage(child: const SecurityPage());
          },
        ),
        GoRoute(
          path: '/generator',
          pageBuilder: (context, state) {
            return NoTransitionPage(child: const PasswordGeneratorPage());
          },
        ),

        GoRoute(
          path: '/tools',
          pageBuilder: (context, state) {
            return NoTransitionPage(child: const ToolsPage());
          },
        ),
        GoRoute(
          path: '/manage',
          pageBuilder: (context, state) {
            return NoTransitionPage(child: const ManagePage());
          },
        ),
      ],
    ),

    // Settings page (outside shell route, accessed via drawer)
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) =>
          material3TransitionPage(child: const SettingsPage()),
    ),

    // Manage sub-pages
    GoRoute(
      path: '/manage/all-passwords',
      pageBuilder: (context, state) =>
          material3TransitionPage(child: const AllPasswordsPage()),
    ),
    GoRoute(
      path: '/manage/category/:category',
      pageBuilder: (context, state) {
        final category = state.pathParameters['category'] ?? '';
        return material3TransitionPage(
          child: CategoryDetailPage(category: category),
        );
      },
    ),
    GoRoute(
      path: '/manage/type/:type',
      pageBuilder: (context, state) {
        final type = state.pathParameters['type'] ?? '';
        return material3TransitionPage(
          child: TypeDetailPage(type: type),
        );
      },
    ),

    // Vault item detail page
    GoRoute(
      path: '/vault/item/:id',
      pageBuilder: (context, state) {
        final item = state.extra as VaultItem?;
        if (item == null) {
          // Handle error - item not found
          return material3TransitionPage(
            child: const Scaffold(
              body: Center(child: Text('Item not found')),
            ),
          );
        }
        return material3TransitionPage(
          child: VaultItemDetailPage(vaultItem: item),
        );
      },
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
