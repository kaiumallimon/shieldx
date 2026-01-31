import 'package:flutter/material.dart';
import 'package:shieldx/app/core/config/_router.dart';
import 'package:shieldx/app/core/themes/_app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}