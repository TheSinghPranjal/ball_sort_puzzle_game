import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.buttonBottom,
      brightness: Brightness.dark,
      surface: AppColors.panelDark,
    ),
    scaffoldBackgroundColor: AppColors.background,
  );
  return base.copyWith(
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.panel,
      contentTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.lavender,
    ),
  );
}
