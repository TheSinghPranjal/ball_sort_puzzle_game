import 'dart:isolate';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/level_config.dart';
import 'level_data.dart';
import 'level_plan.dart';

/// Runs CPU-heavy work. The default uses a background isolate; tests can
/// override [backgroundRunnerProvider] with [SyncRunner].
abstract class BackgroundRunner {
  Future<R> run<R>(R Function() computation);
}

class IsolateRunner implements BackgroundRunner {
  const IsolateRunner();
  @override
  Future<R> run<R>(R Function() computation) => Isolate.run(computation);
}

class SyncRunner implements BackgroundRunner {
  const SyncRunner();
  @override
  Future<R> run<R>(R Function() computation) async => computation();
}

final backgroundRunnerProvider = Provider<BackgroundRunner>(
  (ref) => const IsolateRunner(),
);

/// All levels ship as solver-verified static data (see
/// `tool/generate_levels.dart`), so loading is instant and fully offline.
class LevelRepository {
  final _cache = <int, LevelConfig>{};

  int get totalLevels => curatedLevelData.length;

  bool isCurated(int id) => id >= 1 && id <= curatedLevelData.length;

  LevelConfig curated(int id) {
    if (!isCurated(id)) throw RangeError.range(id, 1, curatedLevelData.length);
    return _cache.putIfAbsent(id, () {
      final raw = curatedLevelData[id - 1];
      final tubes = [
        for (final t in raw[0] as List) [for (final c in t as List) c as int],
      ];
      return build(LevelPlan.entry(id), tubes, raw[1] as int, raw[2] as int);
    });
  }

  Future<LevelConfig> getLevel(int id) async => curated(id);

  static LevelConfig build(
    LevelPlanEntry e,
    List<List<int>> tubes,
    int par,
    int capacity,
  ) {
    return LevelConfig(
      levelId: e.id,
      name: LevelPlan.nameFor(e.id),
      tubeCapacity: capacity,
      initialTubeArrangement: tubes,
      difficulty: e.difficulty,
      parMoves: par,
      moveTarget: LevelPlan.moveTargetFor(e, par),
      timeLimitSeconds: LevelPlan.timeLimitFor(e, par),
      availablePowerUps: e.powerUps,
      newMechanic: e.newMechanic,
      tutorial: e.tutorial,
      mystery: e.mystery,
    );
  }
}

final levelRepositoryProvider = Provider((ref) => LevelRepository());
