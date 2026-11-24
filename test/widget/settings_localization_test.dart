import 'dart:convert';

import 'package:ball_sort_puzzle_game/app/app.dart';
import 'package:ball_sort_puzzle_game/app/theme.dart';
import 'package:ball_sort_puzzle_game/core/l10n/l10n.dart';
import 'package:ball_sort_puzzle_game/features/game/domain/models/game_progress.dart';
import 'package:ball_sort_puzzle_game/features/game/presentation/widgets/settings_popup.dart';
import 'package:ball_sort_puzzle_game/features/settings/presentation/how_to_play_popup.dart';
import 'package:ball_sort_puzzle_game/features/settings/presentation/language_picker_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ball_sort_puzzle_game/storage/local_storage_service.dart';

import '../helpers/test_helpers.dart';

/// Small phone (360x640 dp): long translations must not overflow.
Future<void> _pump(WidgetTester tester, Locale locale, Brightness b, Widget child) async {
  tester.view.physicalSize = const Size(1080, 1920);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    overrides: await testOverrides(),
    child: MaterialApp(
      locale: locale,
      theme: buildTheme(b),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Center(child: child)),
    ),
  ));
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  for (final lang in AppLanguage.supported) {
    for (final b in Brightness.values) {
      testWidgets('settings + language picker fit: ${lang.code} ${b.name}', (tester) async {
        await _pump(tester, lang.locale, b, const SettingsPopup(inGame: true));
        expect(tester.takeException(), isNull);
        await _pump(tester, lang.locale, b, const LanguagePickerPopup());
        expect(tester.takeException(), isNull);
      });

      testWidgets('how to play pages fit: ${lang.code} ${b.name}', (tester) async {
        await _pump(tester, lang.locale, b, const HowToPlayPopup());
        for (var page = 0; page < 5; page++) {
          expect(tester.takeException(), isNull, reason: 'page $page');
          await tester.drag(find.byType(PageView), const Offset(-400, 0));
          for (var i = 0; i < 10; i++) {
            await tester.pump(const Duration(milliseconds: 50));
          }
        }
      });
    }
  }

  // Level 50 is timed with a move target (widest header), 25 is special,
  // 17 is the first mystery level (longest "NEW:" banner).
  for (final lang in AppLanguage.supported) {
    testWidgets('home and game screens fit: ${lang.code}', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final overrides = await testOverrides(prefs: {
        LocalStorageService.progressKey: jsonEncode(GameProgress(
          highestUnlockedLevel: 60,
          tutorialsCompleted: {'basicMove', 'sameColor', 'powerUps'},
        ).toJson()),
        LocalStorageService.settingsKey: jsonEncode({'language': lang.code, 'theme': 'light'}),
      });
      await tester.pumpWidget(ProviderScope(overrides: overrides, child: const BallSortApp()));
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull, reason: 'home');
      for (final level in [50, 25, 17]) {
        GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/game/$level');
        for (var i = 0; i < 20; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(tester.takeException(), isNull, reason: 'level $level');
        // Dismiss the special-level intro if it opened.
        final nav = Navigator.of(tester.element(find.byType(Scaffold).last));
        if (nav.canPop()) nav.pop();
        await tester.pump(const Duration(milliseconds: 400));
      }
    });
  }
}
