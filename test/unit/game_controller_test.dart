import 'dart:convert';

import 'package:ball_sort_puzzle_game/features/game/data/progress_repository.dart';
import 'package:ball_sort_puzzle_game/features/game/domain/models/game_state.dart';
import 'package:ball_sort_puzzle_game/features/game/domain/services/game_rules_service.dart';
import 'package:ball_sort_puzzle_game/features/game/domain/services/puzzle_solver_service.dart';
import 'package:ball_sort_puzzle_game/features/game/presentation/controllers/game_controller.dart';
import 'package:ball_sort_puzzle_game/storage/local_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

void main() {
  late ProviderContainer c;
  GameController ctrl() => c.read(gameControllerProvider.notifier);
  GameState st() => c.read(gameControllerProvider)!;
  List<List<int>> colors() => [for (final t in st().tubes) t.colorIds];
  Set<int> ballIds() => {for (final t in st().tubes) for (final b in t.balls) b.id};

  /// Plays a valid move and finishes its animation.
  void move(int from, int to) {
    ctrl().tapTube(from);
    ctrl().tapTube(to);
    final e = st().events.whereType<BallMovedEvent>().lastOrNull;
    if (e != null) ctrl().onAnimationComplete(e.seq);
  }

  /// Finds any legal (from, to) pair on the current board.
  (int, int) anyLegalMove() {
    const rules = GameRulesService();
    for (var f = 0; f < st().tubes.length; f++) {
      for (var t = 0; t < st().tubes.length; t++) {
        if (rules.canMove(st().tubes, f, t)) return (f, t);
      }
    }
    throw StateError('no legal move');
  }

  setUp(() async {
    c = await testContainer();
  });
  tearDown(() => c.dispose());

  group('selection', () {
    setUp(() => ctrl().startLevel(5));

    test('tapping an empty tube with nothing selected does nothing', () async {
      await ctrl().startLevel(5);
      final empty = st().tubes.indexWhere((t) => t.isEmpty);
      ctrl().tapTube(empty);
      expect(st().selectedTubeIndex, isNull);
    });

    test('selecting the same tube twice deselects', () async {
      await ctrl().startLevel(5);
      ctrl().tapTube(0);
      expect(st().selectedTubeIndex, 0);
      ctrl().tapTube(0);
      expect(st().selectedTubeIndex, isNull);
      expect(st().moveCount, 0);
    });

    test('invalid destination with balls switches the selection, no move counted', () async {
      await ctrl().startLevel(2); // [[0,0,1,1],[1,1,0,0],[]]
      ctrl().tapTube(0); // top = 1
      ctrl().tapTube(1); // top = 0 -> invalid
      expect(st().selectedTubeIndex, 1);
      expect(st().moveCount, 0);
      expect(st().undoHistory, isEmpty);
      expect(st().lastEvent, isA<InvalidMoveEvent>());
    });

    test('taps are ignored while a ball is in flight', () async {
      await ctrl().startLevel(2);
      ctrl().tapTube(0);
      ctrl().tapTube(2);
      expect(st().isAnimating, isTrue);
      final before = colors();
      ctrl().tapTube(1);
      expect(colors(), before);
      expect(st().selectedTubeIndex, isNull);
    });
  });

  group('moves and completion', () {
    test('valid move updates tubes, counter and history', () async {
      await ctrl().startLevel(2);
      move(0, 2);
      expect(colors(), [[0, 0, 1], [1, 1, 0, 0], [1]]);
      expect(st().moveCount, 1);
      expect(st().undoHistory.length, 1);
      expect(ballIds().length, 8);
    });

    test('solving a level completes it, saves progress and unlocks the next', () async {
      await ctrl().startLevel(1);
      final hint = const PuzzleSolverService().nextHint(GameRulesService.toRaw(st().tubes), 4)!;
      move(hint.from, hint.to);
      expect(st().isLevelCompleted, isTrue);
      expect(st().stars, 3);
      final p = c.read(progressProvider);
      expect(p.isCompleted(1), isTrue);
      expect(p.highestUnlockedLevel, 2);
      // Input is disabled after completion.
      ctrl().tapTube(0);
      expect(st().selectedTubeIndex, isNull);
    });

    test('playing the reference solution completes every tutorial level', () async {
      for (final id in [1, 2, 3, 4, 5]) {
        await ctrl().startLevel(id, resume: false);
        final r = const PuzzleSolverService().solve(GameRulesService.toRaw(st().tubes), 4);
        for (final m in r.moves) {
          move(m.from, m.to);
        }
        expect(st().isLevelCompleted, isTrue, reason: 'level $id');
        expect(st().moveCount, r.moves.length);
      }
      expect(c.read(progressProvider).highestUnlockedLevel, 6);
    });

    test('next level loads only on request', () async {
      await ctrl().startLevel(1);
      move(1, 0);
      expect(st().currentLevel, 1);
      await ctrl().nextLevel();
      expect(st().currentLevel, 2);
      expect(st().moveCount, 0);
    });
  });

  group('undo', () {
    test('undo one move restores the exact state and counter', () async {
      await ctrl().startLevel(5);
      final before = colors();
      final ids = [for (final t in st().tubes) [for (final b in t.balls) b.id]];
      final (f, t) = anyLegalMove();
      move(f, t);
      expect(ctrl().undo(), PowerUpResult.applied);
      expect(colors(), before);
      expect([for (final t in st().tubes) [for (final b in t.balls) b.id]], ids);
      expect(st().moveCount, 0);
      expect(st().undoRemaining, 4);
    });

    test('undo multiple moves in sequence', () async {
      await ctrl().startLevel(5);
      final snapshots = <List<List<int>>>[colors()];
      for (var i = 0; i < 3; i++) {
        final (f, t) = anyLegalMove();
        move(f, t);
        snapshots.add(colors());
      }
      for (var i = 3; i > 0; i--) {
        ctrl().undo();
        expect(colors(), snapshots[i - 1]);
        expect(st().moveCount, i - 1);
      }
    });

    test('invalid moves create no undo entry', () async {
      await ctrl().startLevel(3); // tube 0 top = 2, tube 1 top = 0
      ctrl().tapTube(0);
      ctrl().tapTube(1);
      expect(st().lastEvent, isA<InvalidMoveEvent>());
      expect(ctrl().undo(), PowerUpResult.nothingToUndo);
      expect(st().undoRemaining, 5);
    });

    test('undo with no history does nothing', () async {
      await ctrl().startLevel(3);
      expect(ctrl().undo(), PowerUpResult.nothingToUndo);
      expect(st().undoRemaining, 5);
    });

    test('undo is refused when no uses remain', () async {
      await ctrl().startLevel(5);
      for (var i = 0; i < 6; i++) {
        final (f, t) = anyLegalMove();
        move(f, t);
      }
      for (var i = 0; i < 5; i++) {
        expect(ctrl().undo(), PowerUpResult.applied);
      }
      expect(ctrl().undo(), PowerUpResult.noUsesLeft);
      expect(st().undoRemaining, 0);
    });

    test('undo never modifies the level configuration', () async {
      await ctrl().startLevel(5);
      final initial = st().level.initialTubeArrangement.toString();
      move(anyLegalMove().$1, anyLegalMove().$2);
      ctrl().undo();
      expect(st().level.initialTubeArrangement.toString(), initial);
    });

    test('power-ups are unavailable on levels 1-2', () async {
      await ctrl().startLevel(2);
      move(0, 2);
      expect(ctrl().undo(), PowerUpResult.unavailable);
      expect(ctrl().addTube(), PowerUpResult.unavailable);
    });
  });

  group('shuffle', () {
    test('preserves balls and colors, is solvable, undo restores', () async {
      await ctrl().startLevel(30);
      final before = colors();
      final ids = ballIds();
      final counts = <int, int>{};
      for (final t in before) {
        for (final x in t) {
          counts[x] = (counts[x] ?? 0) + 1;
        }
      }
      expect(await ctrl().shuffle(seed: 11), PowerUpResult.applied);
      expect(st().shuffleRemaining, 1);
      expect(ballIds(), ids);
      expect(st().tubes.length, before.length);
      final after = <int, int>{};
      for (final t in st().tubes) {
        expect(t.balls.length, lessThanOrEqualTo(t.capacity));
        for (final b in t.balls) {
          after[b.colorId] = (after[b.colorId] ?? 0) + 1;
        }
      }
      expect(after, counts);
      expect(colors(), isNot(before));
      expect(const PuzzleSolverService().solve(GameRulesService.toRaw(st().tubes), 4).solvable, isTrue);
      expect(st().moveCount, 0);
      ctrl().undo();
      expect(colors(), before);
    });

    test('runs out after the allotted uses', () async {
      await ctrl().startLevel(10);
      await ctrl().shuffle(seed: 1);
      await ctrl().shuffle(seed: 2);
      expect(await ctrl().shuffle(seed: 3), PowerUpResult.noUsesLeft);
    });
  });

  group('add tube', () {
    test('adds one empty, usable tube and keeps existing balls', () async {
      await ctrl().startLevel(20);
      final before = colors();
      expect(ctrl().addTube(), PowerUpResult.applied);
      expect(st().tubes.length, before.length + 1);
      expect(st().tubes.last.isEmpty, isTrue);
      expect(st().tubes.last.isExtraTube, isTrue);
      expect(colors().sublist(0, before.length), before);
      // The new tube accepts a ball, and stays after the move.
      move(0, st().tubes.length - 1);
      expect(st().tubes.last.balls.length, 1);
      expect(st().tubes.length, before.length + 1);
    });

    test('undo restores the pre-add-tube state', () async {
      await ctrl().startLevel(20);
      final n = st().tubes.length;
      ctrl().addTube();
      ctrl().undo();
      expect(st().tubes.length, n);
    });

    test('limited uses', () async {
      await ctrl().startLevel(20);
      ctrl().addTube();
      ctrl().addTube();
      expect(ctrl().addTube(), PowerUpResult.noUsesLeft);
    });
  });

  group('restart', () {
    test('restores the original arrangement, tube count and counters', () async {
      await ctrl().startLevel(1);
      move(1, 0); // completes level 1 -> unlocks 2
      await ctrl().startLevel(5);
      final original = colors();
      move(anyLegalMove().$1, anyLegalMove().$2);
      ctrl().addTube();
      ctrl().restart();
      expect(colors(), original);
      expect(st().moveCount, 0);
      expect(st().undoHistory, isEmpty);
      expect(st().addTubeRemaining, 2);
      // Progress is preserved.
      expect(c.read(progressProvider).highestUnlockedLevel, 2);
    });
  });

  group('timer', () {
    test('untimed levels have no countdown', () async {
      await ctrl().startLevel(5);
      expect(st().remainingSeconds, isNull);
    });

    test('countdown pauses and expires', () async {
      await ctrl().startLevel(30);
      final start = st().remainingSeconds!;
      ctrl().tick();
      expect(st().remainingSeconds, start - 1);
      ctrl().setPaused('settings', true);
      ctrl().tick();
      expect(st().remainingSeconds, start - 1);
      ctrl().setPaused('settings', false);
      for (var i = 0; i < start; i++) {
        ctrl().tick();
      }
      expect(st().isTimeUp, isTrue);
      ctrl().tapTube(0);
      expect(st().selectedTubeIndex, isNull);
      ctrl().restart();
      expect(st().isTimeUp, isFalse);
      expect(st().remainingSeconds, start);
    });

    test('pause reasons stack', () async {
      await ctrl().startLevel(5);
      ctrl().setPaused('settings', true);
      ctrl().setPaused('lifecycle', true);
      ctrl().setPaused('settings', false);
      expect(st().isPaused, isTrue);
      ctrl().setPaused('lifecycle', false);
      expect(st().isPaused, isFalse);
    });
  });

  group('persistence', () {
    test('an in-progress level is restored after an app restart', () async {
      await ctrl().startLevel(5);
      move(anyLegalMove().$1, anyLegalMove().$2);
      ctrl().addTube();
      final saved = colors();
      final moves = st().moveCount;
      final storage = c.read(localStorageProvider);
      final raw = jsonEncode(storage.readJson(LocalStorageService.savedGameKey));
      final progress = jsonEncode(c.read(progressProvider).toJson());
      c.dispose();

      c = await testContainer(prefs: {
        LocalStorageService.savedGameKey: raw,
        LocalStorageService.progressKey: progress,
      });
      await ctrl().startLevel(5);
      expect(colors(), saved);
      expect(st().moveCount, moves);
      expect(st().addTubeRemaining, 1);
      ctrl().undo();
      expect(st().tubes.length, saved.length - 1);
    });

    test('a corrupted save is discarded', () async {
      c.dispose();
      c = await testContainer(prefs: {
        LocalStorageService.savedGameKey: jsonEncode({
          'level': 5,
          'tubes': [
            {'id': 0, 'cap': 4, 'b': [{'i': 0, 'c': 0}]},
          ],
          'moves': 3, 'history': [], 'undo': 5, 'shuffle': 2, 'add': 2,
        }),
      });
      await ctrl().startLevel(5);
      expect(st().moveCount, 0);
      expect(st().tubes.length, st().level.tubeCount);
    });
  });

  group('mystery balls', () {
    Set<int> hidden() => {
          for (final t in st().tubes)
            for (final b in t.balls)
              if (st().isHidden(b.id)) b.id,
        };

    test('only the top ball of each tube is visible at start', () async {
      await ctrl().startLevel(17);
      expect(st().level.mystery, isTrue);
      for (final t in st().tubes.where((t) => t.balls.isNotEmpty)) {
        expect(st().isHidden(t.topBall!.id), isFalse);
        for (final b in t.balls.sublist(0, t.balls.length - 1)) {
          expect(st().isHidden(b.id), isTrue);
        }
      }
    });

    test('a ball is revealed when it reaches the top and stays revealed after undo', () async {
      await ctrl().startLevel(17);
      final (f, t) = anyLegalMove();
      final under = st().tubes[f].balls[st().tubes[f].balls.length - 2];
      expect(st().isHidden(under.id), isTrue);
      move(f, t);
      expect(st().isHidden(under.id), isFalse);
      ctrl().undo();
      expect(st().isHidden(under.id), isFalse);
    });

    test('rules and solvability are unaffected; completion reveals everything', () async {
      await ctrl().startLevel(17);
      final r = const PuzzleSolverService().solve(GameRulesService.toRaw(st().tubes), 4);
      for (final m in r.moves) {
        move(m.from, m.to);
      }
      expect(st().isLevelCompleted, isTrue);
      expect(hidden(), isEmpty);
    });

    test('revealed balls survive an app restart', () async {
      await ctrl().startLevel(17);
      final (f, t) = anyLegalMove();
      move(f, t);
      final before = hidden();
      final raw = jsonEncode(c.read(localStorageProvider).readJson(LocalStorageService.savedGameKey));
      c.dispose();
      c = await testContainer(prefs: {LocalStorageService.savedGameKey: raw});
      await ctrl().startLevel(17);
      expect(hidden(), before);
    });

    test('non-mystery levels hide nothing', () async {
      await ctrl().startLevel(16);
      expect(hidden(), isEmpty);
    });
  });

  test('special levels use tall tubes everywhere, including added tubes', () async {
    await ctrl().startLevel(25);
    expect(st().level.isSpecial, isTrue);
    expect(st().tubes.every((t) => t.capacity == 6), isTrue);
    ctrl().addTube();
    expect(st().tubes.last.capacity, 6);
    expect(await ctrl().shuffle(seed: 4), PowerUpResult.applied);
    expect(st().tubes.every((t) => t.balls.length <= 6), isTrue);
  });
}
