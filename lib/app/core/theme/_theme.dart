import 'package:flutter/material.dart';
import 'package:shieldx/app/core/constants/_colors.dart';

class AppTheme {
  ThemeData light = ThemeData(
      fontFamily: 'Poppins',
      useMaterial3: true,
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

  ThemeData dark = ThemeData(
      fontFamily: 'Poppins',
      useMaterial3: true,
      colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.darkPrimary,
          onPrimary: AppColors.onDarkPrimary,
          secondary: AppColors.darkSecondary,
          onSecondary: AppColors.onDarkSecondary,
          error: AppColors.error,
          onError: AppColors.onError,
          surface: AppColors.darkSurface,
          onSurface: AppColors.onDarkSurface));
}
