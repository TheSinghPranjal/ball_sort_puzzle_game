import 'package:ball_sort_puzzle_game/core/constants/game_constants.dart';
import 'package:ball_sort_puzzle_game/core/utils/game_helpers.dart';
import 'package:ball_sort_puzzle_game/core/utils/seeded_random.dart';
import 'package:ball_sort_puzzle_game/features/game/data/level_builder.dart';
import 'package:ball_sort_puzzle_game/features/game/data/level_plan.dart';
import 'package:ball_sort_puzzle_game/features/game/data/level_repository.dart';
import 'package:ball_sort_puzzle_game/features/game/domain/services/level_generator_service.dart';
import 'package:ball_sort_puzzle_game/features/game/domain/models/game_progress.dart';
import 'package:ball_sort_puzzle_game/features/game/domain/models/level_config.dart';
import 'package:ball_sort_puzzle_game/features/game/domain/services/game_rules_service.dart';
import 'package:ball_sort_puzzle_game/features/game/domain/services/level_progress_service.dart';
import 'package:ball_sort_puzzle_game/features/game/domain/services/puzzle_solver_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Development validation tool: runs the solver over every curated level.
void main() {
  final repo = LevelRepository();
  const solver = PuzzleSolverService();

  test('there are 2000 curated levels', () {
    expect(GameConstants.curatedLevelCount, 2000);
    expect(repo.totalLevels, 2000);
    for (var id = 1; id <= GameConstants.curatedLevelCount; id++) {
      expect(repo.isCurated(id), isTrue);
    }
  });

  for (var id = 1; id <= GameConstants.curatedLevelCount; id++) {
    test('level $id is valid and solvable', () {
      final l = repo.curated(id);
      final raw = l.initialTubeArrangement;
      expect(l.levelId, id);
      expect(l.name, isNotEmpty);
      expect(l.tubeCapacity, inInclusiveRange(4, 10));
      expect(l.isSpecial, l.tubeCapacity > 4);
      // Capacity respected.
      for (final t in raw) {
        expect(t.length, lessThanOrEqualTo(l.tubeCapacity));
      }
      // Ball count per color equals capacity (standard levels).
      final counts = colorCounts(raw);
      expect(
        counts.values,
        everyElement(l.tubeCapacity),
        reason: 'level $id color counts',
      );
      expect(l.ballCount, l.colorCount * l.tubeCapacity);
      // Color ids contiguous from 0.
      expect(counts.keys.toSet(), {for (var i = 0; i < l.colorCount; i++) i});
      // Not already solved, at least one meaningful move.
      expect(GameRulesService.isSolvedRaw(raw), isFalse);
      expect(GameRulesService.hasAnyLegalMoveRaw(raw, l.tubeCapacity), isTrue);
      // Solvable, verified by replaying through the game rules.
      final r = solver.solve(
        raw,
        l.tubeCapacity,
        nodeLimit: GameConstants.devSolverNodeLimit,
      );
      expect(r.solvable, isTrue, reason: 'level $id unsolvable');
      expect(
        PuzzleSolverService.verifySolution(raw, l.tubeCapacity, r.moves),
        isTrue,
      );
      expect(l.parMoves, isNotNull);
    });
  }

  test('levels follow the difficulty progression', () {
    for (var id = 1; id <= 100; id++) {
      final l = repo.curated(id);
      final (minC, maxC, minT, maxT) = switch (id) {
        <= 5 => (1, 3, 2, 5),
        <= 20 => (3, 5, 4, 6),
        <= 40 => (5, 7, 6, 8),
        <= 60 => (6, 8, 7, 10),
        <= 80 => (7, 9, 8, 11),
        _ => (8, 10, 9, 12),
      };
      expect(
        l.colorCount,
        inInclusiveRange(minC, maxC),
        reason: 'level $id colors',
      );
      expect(
        l.tubeCount,
        inInclusiveRange(minT, maxT),
        reason: 'level $id tubes',
      );
      expect(
        l.emptyTubeCount,
        inInclusiveRange(0, 2),
        reason: 'level $id empties',
      );
    }
    final l1 = repo.curated(1);
    expect((l1.tubeCount, l1.colorCount, l1.ballCount), (2, 1, 4));
    final l2 = repo.curated(2);
    expect((l2.tubeCount, l2.colorCount, l2.emptyTubeCount), (3, 2, 1));
    final l3 = repo.curated(3);
    expect((l3.tubeCount, l3.colorCount, l3.emptyTubeCount), (5, 3, 2));
    expect(repo.curated(3).tutorial, TutorialType.powerUps);
  });

  test('all curated levels are distinct', () {
    final keys = {
      for (var id = 1; id <= 100; id++)
        canonicalKey(repo.curated(id).initialTubeArrangement),
    };
    expect(keys.length, 100);
  });

  test('average reference solution length grows by band', () {
    double avg(int a, int b) =>
        [
          for (var i = a; i <= b; i++) repo.curated(i).parMoves!,
        ].reduce((x, y) => x + y) /
        (b - a + 1);
    final bands = [
      avg(6, 20),
      avg(21, 40),
      avg(41, 60),
      avg(61, 80),
      avg(81, 100),
    ];
    for (var i = 1; i < bands.length; i++) {
      expect(bands[i], greaterThan(bands[i - 1]), reason: 'band $i');
    }
  });

  test('timed and move-target levels are optional and configured', () {
    expect(repo.curated(1).isTimed, isFalse);
    expect(repo.curated(30).timeLimitSeconds, isNotNull);
    expect(repo.curated(41).moveTarget, isNotNull);
    expect(
      [
        for (var i = 1; i <= 100; i++) repo.curated(i),
      ].where((l) => l.isTimed).length,
      lessThan(10),
    );
  });

  test('completing each level unlocks exactly the next one', () {
    const svc = LevelProgressService();
    var p = GameProgress();
    for (var id = 1; id < 2000; id++) {
      expect(svc.canPlay(p, id), isTrue);
      expect(svc.canPlay(p, id + 1), isFalse);
      p = svc.completeLevel(p, id, 3);
    }
    expect(p.highestUnlockedLevel, 2000);
    p = svc.completeLevel(p, 2000, 3);
    expect(p.highestUnlockedLevel, 2000);
  });

  test('all 2000 levels are distinct', () {
    final keys = {
      for (var id = 1; id <= 2000; id++)
        canonicalKey(repo.curated(id).initialTubeArrangement),
    };
    expect(keys.length, 2000);
  });

  test('level data is reproducible from the seeded builder', () {
    for (final id in [
      7,
      150,
      503,
      777,
      1000,
      1001,
      1253,
      1500,
      1501,
      1764,
      2000,
    ]) {
      final b = buildLevel(id);
      expect(
        b.tubes,
        repo.curated(id).initialTubeArrangement,
        reason: 'level $id',
      );
      expect(b.capacity, repo.curated(id).tubeCapacity);
    }
  });

  test('mystery and special levels appear like the reference game', () {
    expect(repo.curated(LevelPlan.mysteryIntroLevel).mystery, isTrue);
    expect(
      repo.curated(LevelPlan.mysteryIntroLevel).newMechanic,
      LevelMechanic.mystery,
    );
    for (var id = 1; id < LevelPlan.mysteryIntroLevel; id++) {
      expect(repo.curated(id).mystery, isFalse);
    }
    expect(repo.curated(25).isSpecial, isTrue);
    for (var id = 1; id <= 2000; id++) {
      final l = repo.curated(id);
      expect(
        l.isTimed && l.mystery,
        isFalse,
        reason: 'level $id: timed + mystery',
      );
    }
  });

  group('legend levels 501-1000 are much tougher than 101-500', () {
    List<LevelConfig> range(int a, int b) => [
      for (var i = a; i <= b; i++) repo.curated(i),
    ];
    double avg(List<LevelConfig> ls, num Function(LevelConfig) f) =>
        ls.map(f).reduce((a, b) => a + b) / ls.length;
    final challenge = range(101, 500);
    final legend = range(501, 1000);

    test('labelled Legend', () {
      expect(legend.every((l) => l.difficulty == Difficulty.legend), isTrue);
    });

    test('longer solutions and more colors', () {
      expect(
        avg(legend, (l) => l.parMoves!),
        greaterThan(avg(challenge, (l) => l.parMoves!) * 1.25),
      );
      expect(
        avg(legend, (l) => l.colorCount),
        greaterThan(avg(challenge, (l) => l.colorCount)),
      );
      expect(legend.where((l) => l.colorCount >= 11).length, greaterThan(150));
    });

    test('tight one-spare-tube boards, mystery and special levels', () {
      expect(
        legend.where((l) => l.emptyTubeCount == 1).length,
        greaterThanOrEqualTo(90),
      );
      expect(
        legend.where((l) => l.mystery).length,
        greaterThan(challenge.where((l) => l.mystery).length * 1.1),
      );
      expect(legend.where((l) => l.isSpecial).length, greaterThan(100));
    });

    test('second half is tougher than the first half', () {
      expect(
        avg(range(751, 1000), (l) => l.parMoves!),
        greaterThan(avg(range(501, 750), (l) => l.parMoves!)),
      );
      expect(
        range(751, 1000).where((l) => l.mystery).length,
        greaterThan(range(501, 750).where((l) => l.mystery).length),
      );
    });

    test('mistakes are punished more often (trap rate)', () {
      const gen = LevelGeneratorService();
      double traps(List<LevelConfig> ls) {
        var sum = 0.0;
        final sample = [for (var i = 0; i < ls.length; i += 8) ls[i]];
        for (final l in sample) {
          sum += gen.trapRate(
            l.initialTubeArrangement,
            l.tubeCapacity,
            SeededRandom(l.levelId),
            samples: 12,
          );
        }
        return sum / sample.length;
      }

      expect(traps(legend), greaterThan(traps(challenge)));
    });
  });

  group('mythic levels 1001-1500 are tougher than legend 501-1000', () {
    List<LevelConfig> range(int a, int b) => [
      for (var i = a; i <= b; i++) repo.curated(i),
    ];
    double avg(List<LevelConfig> ls, num Function(LevelConfig) f) =>
        ls.map(f).reduce((a, b) => a + b) / ls.length;
    final legend = range(501, 1000);
    final mythic = range(1001, 1500);

    test('labelled Mythic', () {
      expect(mythic.every((l) => l.difficulty == Difficulty.mythic), isTrue);
      expect(repo.curated(1001).newMechanic, LevelMechanic.mythic);
    });

    test('longer solutions and more colors', () {
      expect(
        avg(mythic, (l) => l.parMoves!),
        greaterThan(avg(legend, (l) => l.parMoves!) * 1.1),
      );
      expect(
        avg(mythic, (l) => l.colorCount),
        greaterThan(avg(legend, (l) => l.colorCount)),
      );
      expect(
        mythic.where((l) => l.colorCount >= 12).length,
        greaterThanOrEqualTo(200),
      );
      expect(mythic.where((l) => l.colorCount == 13).length, greaterThan(100));
    });

    test('tight boards, mystery and special levels', () {
      expect(
        mythic.where((l) => l.emptyTubeCount == 1).length,
        greaterThanOrEqualTo(90),
      );
      expect(
        mythic.where((l) => l.mystery).length,
        greaterThan(legend.where((l) => l.mystery).length * 1.2),
      );
      expect(
        mythic.where((l) => l.isSpecial).length,
        greaterThan(legend.where((l) => l.isSpecial).length),
      );
    });

    test('second half is tougher than the first half', () {
      expect(
        avg(range(1251, 1500), (l) => l.parMoves!),
        greaterThan(avg(range(1001, 1250), (l) => l.parMoves!)),
      );
      expect(
        avg(range(1251, 1500), (l) => l.colorCount),
        greaterThan(avg(range(1001, 1250), (l) => l.colorCount)),
      );
    });

    test('mistakes are punished more often (trap rate)', () {
      const gen = LevelGeneratorService();
      double traps(List<LevelConfig> ls) {
        var sum = 0.0;
        final sample = [for (var i = 0; i < ls.length; i += 8) ls[i]];
        for (final l in sample) {
          sum += gen.trapRate(
            l.initialTubeArrangement,
            l.tubeCapacity,
            SeededRandom(l.levelId),
            samples: 12,
          );
        }
        return sum / sample.length;
      }

      expect(traps(mythic), greaterThan(traps(legend)));
    });
  });

  group('immortal levels 1501-2000 are tougher than mythic 1001-1500', () {
    List<LevelConfig> range(int a, int b) => [
      for (var i = a; i <= b; i++) repo.curated(i),
    ];
    double avg(List<LevelConfig> ls, num Function(LevelConfig) f) =>
        ls.map(f).reduce((a, b) => a + b) / ls.length;
    final mythic = range(1001, 1500);
    final immortal = range(1501, 2000);

    test('labelled Immortal', () {
      expect(
        immortal.every((l) => l.difficulty == Difficulty.immortal),
        isTrue,
      );
      expect(repo.curated(1501).newMechanic, LevelMechanic.immortal);
    });

    test('longer solutions and more colors', () {
      expect(
        avg(immortal, (l) => l.parMoves!),
        greaterThan(avg(mythic, (l) => l.parMoves!) * 1.05),
      );
      expect(
        avg(immortal, (l) => l.colorCount),
        greaterThan(avg(mythic, (l) => l.colorCount)),
      );
      expect(
        immortal.where((l) => l.colorCount == 13).length,
        greaterThanOrEqualTo(200),
      );
    });

    test('tight boards and mystery on almost every level', () {
      expect(
        immortal.where((l) => l.emptyTubeCount == 1).length,
        greaterThanOrEqualTo(90),
      );
      expect(
        avg(
          immortal.where((l) => l.emptyTubeCount == 1).toList(),
          (l) => l.colorCount,
        ),
        greaterThan(
          avg(
            mythic.where((l) => l.emptyTubeCount == 1).toList(),
            (l) => l.colorCount,
          ),
        ),
      );
      expect(
        immortal.where((l) => l.mystery).length,
        greaterThan(mythic.where((l) => l.mystery).length),
      );
      expect(immortal.where((l) => l.mystery).length, 475);
    });

    test('second half is tougher than the first half', () {
      expect(
        avg(range(1751, 2000), (l) => l.parMoves!),
        greaterThan(avg(range(1501, 1750), (l) => l.parMoves!)),
      );
      expect(
        avg(range(1751, 2000), (l) => l.colorCount),
        greaterThan(avg(range(1501, 1750), (l) => l.colorCount)),
      );
    });

    test('mistakes are punished at least as often (trap rate)', () {
      const gen = LevelGeneratorService();
      double traps(List<LevelConfig> ls) {
        var sum = 0.0;
        final sample = [for (var i = 0; i < ls.length; i += 8) ls[i]];
        for (final l in sample) {
          sum += gen.trapRate(
            l.initialTubeArrangement,
            l.tubeCapacity,
            SeededRandom(l.levelId),
            samples: 12,
          );
        }
        return sum / sample.length;
      }

      expect(traps(immortal), greaterThanOrEqualTo(traps(mythic) * 0.95));
    });
  });
}
