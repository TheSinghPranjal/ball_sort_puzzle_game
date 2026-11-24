import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import 'game_palette.dart';

export 'game_palette.dart';

ThemeData buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final palette = isDark ? GamePalette.dark : GamePalette.light;
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.buttonBottom,
      brightness: brightness,
      surface: palette.panelDark,
    ),
    scaffoldBackgroundColor: palette.background,
    extensions: [palette],
  );
  return base.copyWith(
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: palette.panel,
      contentTextStyle: TextStyle(
        color: palette.text,
        fontWeight: FontWeight.w600,
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: palette.accent),
  );
}
