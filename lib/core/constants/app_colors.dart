import 'package:flutter/painting.dart';

class BallColorSpec {
  const BallColorSpec(this.name, this.primary, this.highlight, this.shadow);
  final String name;
  final Color primary;
  final Color highlight;
  final Color shadow;
}

class AppColors {
  AppColors._();

  // Background
  static const background = Color(0xFF0B082B);
  static const backgroundCenter = Color(0xFF2A1F68);
  static const backgroundEdge = Color(0xFF05031A);

  // Glass
  static const tubeOutline = Color(0xFFA5A0B9);
  static const tubeHighlight = Color(0xFFE5E1FF);
  static const tubeInnerShadow = Color(0xFF353050);
  static const tubeSelected = Color(0xFFD9CCFF);

  // UI
  static const panel = Color(0xFF241A5C);
  static const panelDark = Color(0xFF150F3D);
  static const panelBorder = Color(0xFF9C8CE0);
  static const lavender = Color(0xFFB7A6FF);
  static const buttonTop = Color(0xFFA48BFF);
  static const buttonBottom = Color(0xFF6A4BE0);
  static const badge = Color(0xFFFF3B4E);
  static const gold = Color(0xFFFFC93C);
  static const success = Color(0xFF3DDC84);
  static const danger = Color(0xFFFF4D5E);
  static const textMuted = Color(0xFFB9B2DD);

  /// Ball palette. Index = colorId. The first eight follow the design spec;
  /// the rest are extra, clearly distinct hues for larger levels.
  static const balls = <BallColorSpec>[
    BallColorSpec('Orange', Color(0xFFFF8C00), Color(0xFFFFD05B), Color(0xFFD95B00)),
    BallColorSpec('Purple', Color(0xFF8200FF), Color(0xFFD9A4FF), Color(0xFF4B00C8)),
    BallColorSpec('Green', Color(0xFF00D923), Color(0xFF9CFF77), Color(0xFF008D16)),
    BallColorSpec('Blue', Color(0xFF168BFF), Color(0xFF9CE5FF), Color(0xFF0753D1)),
    BallColorSpec('Pink', Color(0xFFFF3D9A), Color(0xFFFFB2DD), Color(0xFFC80062)),
    BallColorSpec('Yellow', Color(0xFFFFD21C), Color(0xFFFFF49B), Color(0xFFDB9100)),
    BallColorSpec('Red', Color(0xFFF52C42), Color(0xFFFF9A9A), Color(0xFFAD0B28)),
    BallColorSpec('Cyan', Color(0xFF00D7DF), Color(0xFFA5FFFF), Color(0xFF008EAD)),
    BallColorSpec('Pearl', Color(0xFFE9E7F5), Color(0xFFFFFFFF), Color(0xFF9C97B8)),
    BallColorSpec('Brown', Color(0xFF9A5A2C), Color(0xFFE0A576), Color(0xFF5C2E10)),
    BallColorSpec('Lime', Color(0xFFB4E61A), Color(0xFFF0FF9A), Color(0xFF6E9400)),
    BallColorSpec('Navy', Color(0xFF3A3FC9), Color(0xFF9EA6FF), Color(0xFF1C1C7A)),
  ];

  static BallColorSpec ball(int colorId) => balls[colorId % balls.length];
}
