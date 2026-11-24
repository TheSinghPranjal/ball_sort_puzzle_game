import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

/// Theme-dependent colors for the game's custom-painted UI.
///
/// Brand colors that read well on both backgrounds (ball colors, button
/// gradients, gold stars, success/danger) stay in [AppColors]. Everything
/// that depends on light/dark lives here, so a theme switch animates: the
/// [lerp] lets [MaterialApp]'s built-in theme animation cross-fade the
/// background, panels, text and glass tubes together.
@immutable
class GamePalette extends ThemeExtension<GamePalette> {
  const GamePalette({
    required this.background,
    required this.backgroundCenter,
    required this.backgroundEdge,
    required this.star,
    required this.panel,
    required this.panelDark,
    required this.panelBorder,
    required this.accent,
    required this.text,
    required this.textMuted,
    required this.highlight,
    required this.tubeOutline,
    required this.tubeHighlight,
    required this.tubeInnerShadow,
    required this.tubeSelected,
    required this.lockedTileTop,
    required this.lockedTileBottom,
    required this.shadow,
  });

  final Color background;
  final Color backgroundCenter;
  final Color backgroundEdge;
  final Color star;
  final Color panel;
  final Color panelDark;
  final Color panelBorder;

  /// Icons, section labels and other secondary accents.
  final Color accent;
  final Color text;
  final Color textMuted;

  /// Emphasis text (gold on dark, deep amber on light for contrast).
  final Color highlight;
  final Color tubeOutline;
  final Color tubeHighlight;
  final Color tubeInnerShadow;
  final Color tubeSelected;
  final Color lockedTileTop;
  final Color lockedTileBottom;
  final Color shadow;

  static const dark = GamePalette(
    background: AppColors.background,
    backgroundCenter: AppColors.backgroundCenter,
    backgroundEdge: AppColors.backgroundEdge,
    star: Colors.white,
    panel: AppColors.panel,
    panelDark: AppColors.panelDark,
    panelBorder: AppColors.panelBorder,
    accent: AppColors.lavender,
    text: Colors.white,
    textMuted: AppColors.textMuted,
    highlight: AppColors.gold,
    tubeOutline: AppColors.tubeOutline,
    tubeHighlight: AppColors.tubeHighlight,
    tubeInnerShadow: AppColors.tubeInnerShadow,
    tubeSelected: AppColors.tubeSelected,
    lockedTileTop: Color(0xFF2E2756),
    lockedTileBottom: Color(0xFF1C1640),
    shadow: Colors.black54,
  );

  /// "Daylight" variant: soft lavender sky, white glass panels, deep
  /// indigo text. Tuned so the white glass reflections still read.
  static const light = GamePalette(
    background: Color(0xFFDCD3FF),
    backgroundCenter: Color(0xFFF8F5FF),
    backgroundEdge: Color(0xFFB9AAF3),
    star: Color(0xFF7B61E8),
    panel: Color(0xFFFFFFFF),
    panelDark: Color(0xFFEDE7FF),
    panelBorder: Color(0xFFA592F0),
    accent: Color(0xFF6A4BE0),
    text: Color(0xFF241A5C),
    textMuted: Color(0xFF5E5494),
    highlight: Color(0xFFB86E00),
    tubeOutline: Color(0xFF7D72B0),
    tubeHighlight: Color(0xFFFFFFFF),
    tubeInnerShadow: Color(0xFF8C80C4),
    tubeSelected: Color(0xFF6A4BE0),
    lockedTileTop: Color(0xFFCFC6F2),
    lockedTileBottom: Color(0xFFB4A8E6),
    shadow: Color(0x406A4BE0),
  );

  @override
  GamePalette copyWith() => this;

  @override
  GamePalette lerp(GamePalette? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return GamePalette(
      background: c(background, other.background),
      backgroundCenter: c(backgroundCenter, other.backgroundCenter),
      backgroundEdge: c(backgroundEdge, other.backgroundEdge),
      star: c(star, other.star),
      panel: c(panel, other.panel),
      panelDark: c(panelDark, other.panelDark),
      panelBorder: c(panelBorder, other.panelBorder),
      accent: c(accent, other.accent),
      text: c(text, other.text),
      textMuted: c(textMuted, other.textMuted),
      highlight: c(highlight, other.highlight),
      tubeOutline: c(tubeOutline, other.tubeOutline),
      tubeHighlight: c(tubeHighlight, other.tubeHighlight),
      tubeInnerShadow: c(tubeInnerShadow, other.tubeInnerShadow),
      tubeSelected: c(tubeSelected, other.tubeSelected),
      lockedTileTop: c(lockedTileTop, other.lockedTileTop),
      lockedTileBottom: c(lockedTileBottom, other.lockedTileBottom),
      shadow: c(shadow, other.shadow),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is GamePalette &&
      other.background == background &&
      other.backgroundCenter == backgroundCenter &&
      other.backgroundEdge == backgroundEdge &&
      other.star == star &&
      other.panel == panel &&
      other.panelDark == panelDark &&
      other.panelBorder == panelBorder &&
      other.accent == accent &&
      other.text == text &&
      other.textMuted == textMuted &&
      other.highlight == highlight &&
      other.tubeOutline == tubeOutline &&
      other.tubeHighlight == tubeHighlight &&
      other.tubeInnerShadow == tubeInnerShadow &&
      other.tubeSelected == tubeSelected &&
      other.lockedTileTop == lockedTileTop &&
      other.lockedTileBottom == lockedTileBottom &&
      other.shadow == shadow;

  @override
  int get hashCode => Object.hashAll([
    background,
    backgroundCenter,
    backgroundEdge,
    star,
    panel,
    panelDark,
    panelBorder,
    accent,
    text,
    textMuted,
    highlight,
    tubeOutline,
    tubeHighlight,
    tubeInnerShadow,
    tubeSelected,
    lockedTileTop,
    lockedTileBottom,
    shadow,
  ]);
}

extension GamePaletteContext on BuildContext {
  /// The active palette. Falls back to dark when no theme provides one
  /// (e.g. a widget test that pumps a bare MaterialApp).
  GamePalette get palette =>
      Theme.of(this).extension<GamePalette>() ?? GamePalette.dark;
}
