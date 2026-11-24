import 'package:ball_sort_puzzle_game/core/l10n/l10n.dart';
import 'package:ball_sort_puzzle_game/features/settings/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('defaults: English, dark theme, all feedback on', () {
    const s = GameSettings();
    expect(s.languageCode, 'en');
    expect(s.themeMode, ThemeMode.dark);
    expect(s.soundEnabled && s.musicEnabled && s.vibrationEnabled, isTrue);
  });

  test('round-trips through JSON', () {
    const s = GameSettings(
      soundEnabled: false,
      themeMode: ThemeMode.system,
      languageCode: 'hi',
    );
    final back = GameSettings.fromJson(s.toJson());
    expect(back.soundEnabled, isFalse);
    expect(back.themeMode, ThemeMode.system);
    expect(back.languageCode, 'hi');
  });

  test('settings saved by an older version keep working', () {
    final s = GameSettings.fromJson({'sound': false, 'music': true, 'vibration': true});
    expect(s.soundEnabled, isFalse);
    expect(s.themeMode, ThemeMode.dark);
    expect(s.languageCode, 'en');
  });

  test('unknown language or theme values fall back to defaults', () {
    final s = GameSettings.fromJson({'language': 'xx', 'theme': 'neon'});
    expect(s.languageCode, 'en');
    expect(s.themeMode, ThemeMode.dark);
  });

  test('every selectable language has a generated translation', () {
    final generated = AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet();
    for (final lang in AppLanguage.supported) {
      expect(generated, contains(lang.code), reason: lang.englishName);
    }
  });
}
