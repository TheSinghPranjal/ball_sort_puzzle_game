import 'package:ball_sort_puzzle_game/core/utils/game_helpers.dart';
import 'package:ball_sort_puzzle_game/core/utils/seeded_random.dart';
import 'package:ball_sort_puzzle_game/features/game/domain/services/game_rules_service.dart';
import 'package:ball_sort_puzzle_game/features/game/domain/services/level_generator_service.dart';
import 'package:ball_sort_puzzle_game/features/game/domain/services/puzzle_solver_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const gen = LevelGeneratorService();
  const solver = PuzzleSolverService();

  test('seeded random is deterministic', () {
    final a = SeededRandom(99), b = SeededRandom(99);
    expect(List.generate(20, (_) => a.nextInt(1000)), List.generate(20, (_) => b.nextInt(1000)));
  });

  test('generation is reproducible and verified solvable', () {
    const spec = LevelSpec(colors: 5, emptyTubes: 2, maxRun: 2, minMoves: 10);
    final a = gen.generate(spec, 1234)!;
    final b = gen.generate(spec, 1234)!;
    expect(a.tubes, b.tubes);
    final r = solver.solve(a.tubes, 4);
    expect(r.solvable, isTrue);
    expect(PuzzleSolverService.verifySolution(a.tubes, 4, r.moves), isTrue);
  });

  test('generated level has correct counts, layout and no trivial state', () {
    const spec = LevelSpec(colors: 7, emptyTubes: 2, maxRun: 2);
    final g = gen.generate(spec, 77)!;
    expect(g.tubes.length, 9);
    expect(g.tubes.where((t) => t.isEmpty).length, 2);
    expect(colorCounts(g.tubes).values, everyElement(4));
    expect(GameRulesService.isSolvedRaw(g.tubes), isFalse);
    for (final t in g.tubes.where((t) => t.isNotEmpty)) {
      expect(t.length, 4);
      expect(t.every((c) => c == t.first), isFalse, reason: 'no pre-completed tubes');
    }
  });

  test('respects maxRun', () {
    final g = gen.generate(const LevelSpec(colors: 6, emptyTubes: 2, maxRun: 1), 5)!;
    for (final t in g.tubes) {
      for (var i = 1; i < t.length; i++) {
        expect(t[i], isNot(t[i - 1]));
      }
    }
  });

  test('reverse scramble always yields a solvable board', () {
    for (var seed = 0; seed < 20; seed++) {
      final t = LevelGeneratorService.reverseScramble(
        LevelGeneratorService.solvedArrangement(6, 2, 4), 4, SeededRandom(seed), steps: 120);
      expect(colorCounts(t).values, everyElement(4));
      expect(solver.solve(t, 4, nodeLimit: 200000).solvable, isTrue, reason: 'seed $seed');
    }
  });

  group('shuffle', () {
    final current = [
      [0, 1, 2, 3], [4, 5, 6, 7], [8, 9, 10, 11], <int>[], [12, 13], <int>[],
    ];
    final colors = [0, 1, 0, 2, 1, 2, 0, 1, 2, 0, 1, 2, 3, 3];
    // Colors 0..2 have 4 balls each; color 3 has 2 (a partial game state).

    test('preserves every ball, color counts, capacity and tube count', () {
      for (var seed = 0; seed < 10; seed++) {
        final out = gen.shuffleSolvable(colorsByToken: colors, current: current, capacity: 4, seed: seed);
        expect(out.length, current.length);
        final flat = [for (final t in out) ...t]..sort();
        expect(flat, List.generate(colors.length, (i) => i));
        for (final t in out) {
          expect(t.length, lessThanOrEqualTo(4));
        }
      }
    });

    test('result is solvable and different from the input', () {
      for (var seed = 0; seed < 10; seed++) {
        final out = gen.shuffleSolvable(colorsByToken: colors, current: current, capacity: 4, seed: seed);
        final raw = [for (final t in out) [for (final i in t) colors[i]]];
        final before = [for (final t in current) [for (final i in t) colors[i]]];
        expect(canonicalKey(raw), isNot(canonicalKey(before)));
        expect(solver.solve(raw, 4, nodeLimit: 200000).solvable, isTrue);
      }
    });

    test('works with several empty tubes', () {
      final cur = [[0, 1, 2, 3], [4, 5, 6, 7], <int>[], <int>[], <int>[]];
      final cols = [0, 1, 0, 1, 1, 0, 1, 0];
      final out = gen.shuffleSolvable(colorsByToken: cols, current: cur, capacity: 4, seed: 3);
      expect([for (final t in out) ...t]..sort(), List.generate(8, (i) => i));
    });
  });
}
