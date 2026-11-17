import '../../../core/constants/game_constants.dart';
import '../../../core/utils/game_helpers.dart';
import '../../../core/utils/seeded_random.dart';
import '../domain/services/level_generator_service.dart';
import '../domain/services/puzzle_solver_service.dart';
import 'level_plan.dart';

class BuiltLevel {
  const BuiltLevel(
    this.tubes,
    this.par,
    this.capacity,
    this.source, {
    this.trapRate = 0,
  });
  final RawTubes tubes;
  final int par;
  final int capacity;

  /// 'fixed', 'primary', 'fallbackN' or 'scramble'.
  final String source;
  final double trapRate;
}

/// Deterministically builds level [id] from [LevelPlan]. Used offline by
/// `tool/generate_levels.dart` (and by tests to prove reproducibility).
/// Arrangements in [avoid] (canonical keys) are skipped so every level is
/// distinct.
BuiltLevel buildLevel(
  int id, {
  Set<String> avoid = const {},
  int nodeLimit = GameConstants.devSolverNodeLimit,
}) {
  final e = LevelPlan.entry(id);
  const solver = PuzzleSolverService();
  if (e.fixed != null) {
    final r = solver.solve(e.fixed!, e.capacity, nodeLimit: nodeLimit);
    if (!r.solvable) throw StateError('Fixed level $id is unsolvable');
    return BuiltLevel(e.fixed!, r.moves.length, e.capacity, 'fixed');
  }
  final gen = LevelGeneratorService(nodeLimit: nodeLimit);
  final specs = [e.spec!, ...e.fallbackSpecs];
  for (var s = 0; s < specs.length; s++) {
    for (var k = 0; k < 6; k++) {
      final g = gen.generate(specs[s], e.seed + (s * 6 + k) * 104729);
      if (g != null && !avoid.contains(canonicalKey(g.tubes))) {
        return BuiltLevel(
          g.tubes,
          g.solutionLength,
          specs[s].capacity,
          s == 0 ? 'primary' : 'fallback$s',
          trapRate: g.trapRate,
        );
      }
    }
  }
  // Last resort: reverse scramble is solvable by construction.
  final spec = specs.first;
  final tubes = LevelGeneratorService.reverseScramble(
    LevelGeneratorService.solvedArrangement(
      spec.colors,
      spec.emptyTubes,
      spec.capacity,
    ),
    spec.capacity,
    SeededRandom(e.seed),
    steps: spec.colors * spec.capacity * 8,
  );
  final r = solver.solve(tubes, spec.capacity, nodeLimit: nodeLimit);
  return BuiltLevel(
    tubes,
    r.solvable ? r.moves.length : spec.colors * spec.capacity,
    spec.capacity,
    'scramble',
  );
}
