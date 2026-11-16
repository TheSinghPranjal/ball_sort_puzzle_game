import 'dart:convert';

import 'package:ball_sort_puzzle_game/app/app.dart';
import 'package:ball_sort_puzzle_game/features/game/domain/models/game_progress.dart';
import 'package:ball_sort_puzzle_game/features/game/presentation/controllers/game_controller.dart';
import 'package:ball_sort_puzzle_game/features/game/presentation/screens/game_screen.dart';
import 'package:ball_sort_puzzle_game/features/game/presentation/widgets/glossy_ball_widget.dart';
import 'package:ball_sort_puzzle_game/features/game/presentation/widgets/tube_view.dart';
import 'package:ball_sort_puzzle_game/features/settings/settings_repository.dart';
import 'package:ball_sort_puzzle_game/storage/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

Map<String, Object> _progress({int highest = 1, bool tutorialsDone = true}) => {
      LocalStorageService.progressKey: jsonEncode(GameProgress(
        highestUnlockedLevel: highest,
        tutorialsCompleted: tutorialsDone ? {'basicMove', 'sameColor', 'powerUps'} : {},
      ).toJson()),
    };

Future<ProviderContainer> _pumpGame(WidgetTester tester, int level, {Map<String, Object>? prefs}) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final overrides = await testOverrides(prefs: prefs ?? _progress(highest: level));
  final container = ProviderContainer(overrides: overrides);
  addTearDown(container.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp(home: GameScreen(levelId: level)),
  ));
  await tester.pump(); // post-frame load
  await tester.pump(const Duration(milliseconds: 500));
  return container;
}

/// Pumps frames in 50ms steps, like a device rendering continuously.
Future<void> _frames(WidgetTester tester, int ms) async {
  for (var t = 0; t < ms; t += 50) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  testWidgets('renders header, board and power-ups', (tester) async {
    final c = await _pumpGame(tester, 3);
    expect(find.text('LEVEL 3'), findsOneWidget);
    expect(find.text('MOVES 0'), findsOneWidget);
    expect(find.byType(TubeView), findsNWidgets(5));
    expect(find.text('UNDO'), findsOneWidget);
    expect(find.text('SHUFFLE'), findsOneWidget);
    expect(find.text('ADD TUBE'), findsOneWidget);
    expect(c.read(gameControllerProvider)!.currentLevel, 3);
  });

  testWidgets('select, valid move, completion popup and continue', (tester) async {
    final c = await _pumpGame(tester, 1);
    // Level 1: [[0,0,0],[0]].
    await tester.tap(find.byType(TubeView).at(1));
    await tester.pump(const Duration(milliseconds: 200));
    expect(c.read(gameControllerProvider)!.selectedTubeIndex, 1);
    await tester.tap(find.byType(TubeView).at(0));
    await _frames(tester, 600); // flight
    expect(c.read(gameControllerProvider)!.isLevelCompleted, isTrue);
    expect(c.read(gameControllerProvider)!.isAnimating, isFalse);
    expect(find.text('MOVES 1'), findsOneWidget);
    await _frames(tester, 1600); // celebration, then popup
    expect(find.text('LEVEL COMPLETE!'), findsOneWidget);
    expect(find.text('1 MOVES'), findsOneWidget);
    await tester.tap(find.text('CONTINUE'));
    await _frames(tester, 800);
    expect(find.text('LEVEL 2'), findsOneWidget);
    expect(c.read(gameControllerProvider)!.moveCount, 0);
    await _frames(tester, 3000); // let confetti finish
  });

  testWidgets('invalid move shakes and does not count', (tester) async {
    final c = await _pumpGame(tester, 3);
    await tester.tap(find.byType(TubeView).at(0));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byType(TubeView).at(1));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('MOVES 0'), findsOneWidget);
    expect(c.read(gameControllerProvider)!.selectedTubeIndex, 1);
  });

  testWidgets('add tube and undo buttons work', (tester) async {
    final c = await _pumpGame(tester, 3);
    await tester.tap(find.text('ADD TUBE'));
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.byType(TubeView), findsNWidgets(6));
    expect(c.read(gameControllerProvider)!.addTubeRemaining, 1);
    await tester.tap(find.text('UNDO'));
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.byType(TubeView), findsNWidgets(5));
    expect(c.read(gameControllerProvider)!.undoRemaining, 4);
  });

  testWidgets('shuffle button rearranges the board', (tester) async {
    final c = await _pumpGame(tester, 3);
    final before = [for (final t in c.read(gameControllerProvider)!.tubes) t.colorIds];
    await tester.tap(find.text('SHUFFLE'));
    await tester.pump(const Duration(milliseconds: 700));
    final after = [for (final t in c.read(gameControllerProvider)!.tubes) t.colorIds];
    expect(after, isNot(before));
    expect(c.read(gameControllerProvider)!.shuffleRemaining, 1);
  });

  testWidgets('restart asks for confirmation and resets the board', (tester) async {
    final c = await _pumpGame(tester, 3);
    await tester.tap(find.text('ADD TUBE'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.bySemanticsLabel('Restart level'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('RESTART?'), findsOneWidget);
    await tester.tap(find.text('CANCEL'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(TubeView), findsNWidgets(6));
    await tester.tap(find.bySemanticsLabel('Restart level'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('RESTART'));
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.byType(TubeView), findsNWidgets(5));
    expect(c.read(gameControllerProvider)!.addTubeRemaining, 2);
  });

  testWidgets('settings popup toggles persist and pause the game', (tester) async {
    final c = await _pumpGame(tester, 3);
    await tester.tap(find.bySemanticsLabel('Settings'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('SETTINGS'), findsOneWidget);
    expect(c.read(gameControllerProvider)!.isPaused, isTrue);
    await tester.tap(find.byType(Switch).first);
    await tester.pump();
    expect(c.read(settingsProvider).soundEnabled, isFalse);
    expect(c.read(localStorageProvider).readJson(LocalStorageService.settingsKey)!['sound'], isFalse);
    await tester.tap(find.text('RESUME'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('SETTINGS'), findsNothing);
    expect(c.read(gameControllerProvider)!.isPaused, isFalse);
  });

  testWidgets('level 1 tutorial guides the first move and can be skipped', (tester) async {
    await _pumpGame(tester, 1, prefs: _progress(tutorialsDone: false));
    expect(find.text('Tap to Select Ball'), findsOneWidget);
    await tester.tap(find.byType(TubeView).at(1));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Tap another tube to move the ball'), findsOneWidget);
    await tester.tap(find.text('Skip tutorial'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Tap another tube to move the ball'), findsNothing);
  });

  testWidgets('level 2 tutorial shows correct and incorrect destinations', (tester) async {
    await _pumpGame(tester, 2, prefs: _progress(highest: 2, tutorialsDone: false));
    await tester.tap(find.byType(TubeView).at(0)); // top color 1
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Only balls of the same color can be stacked together.'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget); // empty tube
    expect(find.byIcon(Icons.close_rounded), findsOneWidget); // tube with color 0 on top
    await tester.tap(find.text('Skip tutorial'));
    await tester.pump(const Duration(milliseconds: 200));
  });

  testWidgets('level 3 tutorial highlights each power-up', (tester) async {
    final c = await _pumpGame(tester, 3, prefs: _progress(highest: 3, tutorialsDone: false));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Take back your last move.'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Remix the balls into a new, still-solvable puzzle.'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Get an extra empty tube for this level.'), findsOneWidget);
    await tester.tap(find.text('Got it!'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Get an extra empty tube for this level.'), findsNothing);
    expect(c.read(localStorageProvider).readJson(LocalStorageService.progressKey)!['tutorials'], contains('powerUps'));
  });

  testWidgets('navigation: home -> levels -> game, locked levels blocked', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final overrides = await testOverrides(prefs: _progress(highest: 2));
    await tester.pumpWidget(ProviderScope(overrides: overrides, child: const BallSortApp()));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('BALL SORT'), findsOneWidget);
    await tester.tap(find.text('LEVELS'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('SELECT LEVEL'), findsOneWidget);
    // Level 5 is locked: tapping it stays on the selection screen.
    await tester.tap(find.bySemanticsLabel('Level 5 locked'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('SELECT LEVEL'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Level 2'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('LEVEL 2'), findsOneWidget);
    // Exit via settings.
    await tester.tap(find.bySemanticsLabel('Settings'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('EXIT TO HOME'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('BALL SORT'), findsOneWidget);
  });

  testWidgets('mystery level draws hidden balls as "?" and reveals on move', (tester) async {
    final c = await _pumpGame(tester, 17);
    final s = c.read(gameControllerProvider)!;
    final hiddenCount = s.tubes.fold<int>(0, (n, t) => n + (t.balls.isEmpty ? 0 : t.balls.length - 1));
    expect(find.byType(MysteryBallWidget), findsNWidgets(hiddenCount));
    // Move a top ball off a full tube: the ball beneath flips to its color.
    final from = s.tubes.indexWhere((t) => t.balls.length > 1);
    final to = s.tubes.indexWhere((t) => t.isEmpty);
    await tester.tap(find.byType(TubeView).at(from));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byType(TubeView).at(to));
    await _frames(tester, 800);
    expect(find.byType(MysteryBallWidget), findsNWidgets(hiddenCount - 1));
  });

  testWidgets('special level shows the intro popup', (tester) async {
    await _pumpGame(tester, 25);
    await _frames(tester, 400);
    expect(find.text('SPECIAL LEVEL'), findsOneWidget);
    await tester.tap(find.text('PLAY'));
    await _frames(tester, 400);
    expect(find.text('SPECIAL LEVEL'), findsNothing);
  });
}
