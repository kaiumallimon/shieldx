import 'package:flutter/material.dart';
import 'package:shieldx/app/core/constants/_colors.dart';

class AppTheme {
  ThemeData light = ThemeData(
      colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          secondary: AppColors.secondary,
          onSecondary: AppColors.onSecondary,
          error: AppColors.error,
          onError: AppColors.onError,
          surface: AppColors.surface,
          onSurface: AppColors.onSurface));
}
