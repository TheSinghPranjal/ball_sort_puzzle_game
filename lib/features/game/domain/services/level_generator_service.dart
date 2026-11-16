import 'dart:math' as math;

import '../../../../core/utils/game_helpers.dart';
import '../../../../core/utils/seeded_random.dart';
import 'game_rules_service.dart';
import 'puzzle_solver_service.dart';

/// Parameters describing the kind of puzzle to generate.
class LevelSpec {
  const LevelSpec({
    required this.colors,
    required this.emptyTubes,
    this.capacity = 4,
    this.minMoves = 0,
    this.maxMoves = 1 << 30,
    this.maxRun = 4,
    this.requireSpreadColor = false,
    this.candidates = 10,
    this.quantile = 0.5,
    this.maxAttempts = 600,
    this.trapSamples = 0,
  });

  final int colors;
  final int emptyTubes;
  final int capacity;

  /// Reject puzzles whose reference solution is shorter/longer than this.
  final int minMoves;
  final int maxMoves;

  /// Longest allowed same-color run inside a tube (lower = more mixed).
  final int maxRun;

  /// Require one color to be spread across (almost) every filled tube.
  final bool requireSpreadColor;

  /// How many verified candidates to collect before choosing.
  final int candidates;

  /// Which difficulty quantile (0 = easiest, 1 = hardest) to choose.
  final double quantile;
  final int maxAttempts;

  /// When > 0, each candidate is also scored by how often short random play
  /// from the start leads to an unsolvable board ("traps"). Tough levels
  /// punish careless moves, so higher trap rates are preferred at high
  /// quantiles.
  final int trapSamples;

  int get tubeCount => colors + emptyTubes;

  LevelSpec copyWith({int? emptyTubes, int? maxRun, int? minMoves, bool? requireSpreadColor}) =>
      LevelSpec(
        colors: colors,
        emptyTubes: emptyTubes ?? this.emptyTubes,
        capacity: capacity,
        minMoves: minMoves ?? this.minMoves,
        maxMoves: maxMoves,
        maxRun: maxRun ?? this.maxRun,
        requireSpreadColor: requireSpreadColor ?? this.requireSpreadColor,
        candidates: candidates,
        quantile: quantile,
        maxAttempts: maxAttempts,
        trapSamples: trapSamples,
      );
}

class GeneratedLevel {
  const GeneratedLevel({
    required this.tubes,
    required this.solutionLength,
    required this.nodesExpanded,
    required this.seed,
    this.trapRate = 0,
  });

  final RawTubes tubes;
  final int solutionLength;
  final int nodesExpanded;
  final int seed;

  /// Fraction of short random playouts that end in an unsolvable board.
  final double trapRate;

  /// Difficulty estimate: longer solutions, harder searches and more traps
  /// score higher.
  double get score =>
      solutionLength + 3 * math.log(nodesExpanded + 1) / math.ln2 + 60 * trapRate;
}

class LevelGeneratorService {
  const LevelGeneratorService({
    this.solver = const PuzzleSolverService(),
    this.nodeLimit = 60000,
  });

  final PuzzleSolverService solver;
  final int nodeLimit;

  /// The sorted start point: one full tube per color plus empty tubes.
  static RawTubes solvedArrangement(int colors, int empties, int capacity) => [
        for (var c = 0; c < colors; c++) List<int>.filled(capacity, c),
        for (var e = 0; e < empties; e++) <int>[],
      ];

  /// Generates a verified-solvable level for [spec], reproducible from [seed].
  /// Collects [LevelSpec.candidates] solver-verified candidates and returns the
  /// one at [LevelSpec.quantile] of estimated difficulty. Returns null if no
  /// candidate satisfies the spec within [LevelSpec.maxAttempts].
  GeneratedLevel? generate(LevelSpec spec, int seed) {
    final rng = SeededRandom(seed);
    final found = <GeneratedLevel>[];
    final seen = <String>{};
    for (var attempt = 0;
        attempt < spec.maxAttempts && found.length < spec.candidates;
        attempt++) {
      // Alternate the two construction strategies.
      final tubes = attempt.isEven
          ? _randomFill(spec, rng)
          : _scrambledFill(spec, rng);
      if (tubes == null || !_acceptLayout(tubes, spec)) continue;
      if (!seen.add(canonicalKey(tubes))) continue;
      final result = solver.solve(tubes, spec.capacity, nodeLimit: nodeLimit);
      if (!result.solvable) continue;
      final len = result.moves.length;
      if (len < spec.minMoves || len > spec.maxMoves) continue;
      found.add(GeneratedLevel(
        tubes: tubes,
        solutionLength: len,
        nodesExpanded: result.nodesExpanded,
        seed: seed,
        trapRate: spec.trapSamples > 0
            ? trapRate(tubes, spec.capacity, rng, samples: spec.trapSamples)
            : 0,
      ));
    }
    if (found.isEmpty) return null;
    found.sort((a, b) => a.score.compareTo(b.score));
    final idx = (spec.quantile.clamp(0.0, 1.0) * (found.length - 1)).round();
    return found[idx];
  }

  /// Plays [samples] short random games ([depth] legal single-ball moves, no
  /// immediate back-and-forth) from [tubes] and returns the fraction that end
  /// in a board the solver cannot finish within [budget] nodes.
  double trapRate(
    RawTubes tubes,
    int capacity,
    SeededRandom rng, {
    int samples = 10,
    int depth = 4,
    int budget = 15000,
  }) {
    var traps = 0;
    for (var s = 0; s < samples; s++) {
      final t = cloneRaw(tubes);
      int? lastFrom, lastTo;
      for (var d = 0; d < depth; d++) {
        final moves = <List<int>>[];
        for (var f = 0; f < t.length; f++) {
          for (var to = 0; to < t.length; to++) {
            if (f == lastTo && to == lastFrom) continue;
            if (GameRulesService.canMoveRaw(t, f, to, capacity)) moves.add([f, to]);
          }
        }
        if (moves.isEmpty) break;
        final m = moves[rng.nextInt(moves.length)];
        t[m[1]].add(t[m[0]].removeLast());
        lastFrom = m[0];
        lastTo = m[1];
      }
      if (!solver.solve(t, capacity, nodeLimit: budget).solvable) traps++;
    }
    return traps / samples;
  }

  /// Uniform random distribution of all balls into the color tubes.
  RawTubes? _randomFill(LevelSpec spec, SeededRandom rng) {
    final balls = <int>[
      for (var c = 0; c < spec.colors; c++)
        for (var i = 0; i < spec.capacity; i++) c,
    ];
    rng.shuffle(balls);
    return [
      for (var t = 0; t < spec.colors; t++)
        balls.sublist(t * spec.capacity, (t + 1) * spec.capacity),
      for (var e = 0; e < spec.emptyTubes; e++) <int>[],
    ];
  }

  /// Reverse-shuffle: start solved, apply legal *reverse* moves (each one the
  /// inverse of a legal forward move, so the result is solvable by
  /// construction), then compact back to full tubes + empty tubes using
  /// reverse moves only where possible.
  RawTubes? _scrambledFill(LevelSpec spec, SeededRandom rng) {
    final tubes = reverseScramble(
      solvedArrangement(spec.colors, spec.emptyTubes, spec.capacity),
      spec.capacity,
      rng,
      steps: spec.colors * spec.capacity * 6,
    );
    // Standard levels need full tubes + exact empty tubes. Re-pack by stacking
    // tubes' contents in their scrambled order (keeps the mixing pattern);
    // solvability is then verified by the solver like any other candidate.
    final flat = <int>[for (final t in tubes) ...t];
    return [
      for (var t = 0; t < spec.colors; t++)
        flat.sublist(t * spec.capacity, (t + 1) * spec.capacity),
      for (var e = 0; e < spec.emptyTubes; e++) <int>[],
    ];
  }

  /// Applies [steps] random reverse moves. A reverse move takes the top ball of
  /// tube B (allowed when the ball below it has the same color or B then
  /// becomes empty) and places it on any non-full tube A. Its inverse A->B is
  /// therefore always a legal forward move, so the output is always solvable.
  static RawTubes reverseScramble(
    RawTubes solved,
    int capacity,
    SeededRandom rng, {
    required int steps,
  }) {
    final t = cloneRaw(solved);
    int? lastFrom;
    int? lastTo;
    for (var s = 0; s < steps; s++) {
      final options = <List<int>>[];
      for (var b = 0; b < t.length; b++) {
        final src = t[b];
        if (src.isEmpty) continue;
        final ok = src.length == 1 || src[src.length - 2] == src.last;
        if (!ok) continue;
        for (var a = 0; a < t.length; a++) {
          if (a == b || t[a].length >= capacity) continue;
          if (lastFrom == a && lastTo == b) continue; // don't undo last step
          options.add([b, a]);
        }
      }
      if (options.isEmpty) break;
      final pick = options[rng.nextInt(options.length)];
      t[pick[1]].add(t[pick[0]].removeLast());
      lastFrom = pick[0];
      lastTo = pick[1];
    }
    return t;
  }

  bool _acceptLayout(RawTubes tubes, LevelSpec spec) {
    if (GameRulesService.isSolvedRaw(tubes)) return false;
    final filled = tubes.where((t) => t.isNotEmpty).toList();
    for (final t in filled) {
      // Reject tubes that are already finished.
      if (t.length == spec.capacity && t.every((c) => c == t.first)) {
        return false;
      }
      var run = 1;
      for (var i = 1; i < t.length; i++) {
        run = t[i] == t[i - 1] ? run + 1 : 1;
        if (run > spec.maxRun) return false;
      }
    }
    if (spec.requireSpreadColor) {
      // A color has [capacity] balls, so it can touch at most that many tubes.
      final need = math.min(spec.capacity, math.max(2, filled.length - 1));
      var ok = false;
      for (var c = 0; c < spec.colors && !ok; c++) {
        ok = filled.where((t) => t.contains(c)).length >= need;
      }
      if (!ok) return false;
    }
    return true;
  }

  // ---------------------------------------------------------------------------
  // Shuffle power-up
  // ---------------------------------------------------------------------------

  /// Rearranges the balls of [colorsByToken] (token i has color
  /// colorsByToken[i]) into tubes with the given per-tube [counts] (same tube
  /// count and fill levels as before). Returns token indices per tube.
  ///
  /// Guarantees: every token appears exactly once, capacity is respected, the
  /// result differs from [current] and is solvable (solver-verified, or
  /// solvable by construction via reverse scramble as a last resort).
  List<List<int>> shuffleSolvable({
    required List<int> colorsByToken,
    required List<List<int>> current,
    required int capacity,
    required int seed,
    int attempts = 30,
  }) {
    final rng = SeededRandom(seed);
    final counts = [for (final t in current) t.length];
    final tokens = [for (var i = 0; i < colorsByToken.length; i++) i];
    final currentKey = canonicalKey(_colorsOf(current, colorsByToken));

    // 1) Same fill levels, random permutation, solver-verified.
    // 2) Then the same with tubes re-packed full from the left.
    final packed = _packedCounts(tokens.length, current.length, capacity);
    for (final layout in [counts, packed]) {
      for (var a = 0; a < attempts; a++) {
        rng.shuffle(tokens);
        final arr = <List<int>>[];
        var k = 0;
        for (final n in layout) {
          arr.add(tokens.sublist(k, k + n));
          k += n;
        }
        final raw = _colorsOf(arr, colorsByToken);
        if (GameRulesService.isSolvedRaw(raw)) continue;
        if (canonicalKey(raw) == currentKey) continue;
        if (solver.solve(raw, capacity, nodeLimit: nodeLimit).solvable) {
          return arr;
        }
      }
    }

    // 3) Reverse scramble from the sorted arrangement: solvable by construction.
    return _reverseScrambleTokens(colorsByToken, current.length, capacity, rng, currentKey);
  }

  List<List<int>> _reverseScrambleTokens(
    List<int> colorsByToken,
    int tubeCount,
    int capacity,
    SeededRandom rng,
    String avoidKey,
  ) {
    final byColor = <int, List<int>>{};
    for (var i = 0; i < colorsByToken.length; i++) {
      byColor.putIfAbsent(colorsByToken[i], () => []).add(i);
    }
    final colorList = byColor.keys.toList()..sort();
    // Sorted layout of colors (one tube per color when it fits).
    final solved = <List<int>>[for (var i = 0; i < tubeCount; i++) <int>[]];
    var ti = 0;
    for (final c in colorList) {
      for (final _ in byColor[c]!) {
        if (solved[ti].length >= capacity) ti++;
        solved[ti].add(c);
      }
      ti++;
      if (ti >= tubeCount) ti = tubeCount - 1;
    }
    RawTubes scrambled = solved;
    for (var tries = 0; tries < 10; tries++) {
      scrambled = reverseScramble(solved, capacity, rng,
          steps: colorsByToken.length * 6);
      if (canonicalKey(scrambled) != avoidKey &&
          !GameRulesService.isSolvedRaw(scrambled)) {
        break;
      }
    }
    // Map colors back to concrete tokens.
    final pools = {for (final c in colorList) c: List<int>.of(byColor[c]!)};
    return [
      for (final t in scrambled) [for (final c in t) pools[c]!.removeLast()],
    ];
  }

  static List<int> _packedCounts(int balls, int tubes, int capacity) {
    final counts = <int>[];
    var left = balls;
    for (var i = 0; i < tubes; i++) {
      final n = math.min(capacity, left);
      counts.add(n);
      left -= n;
    }
    return counts;
  }

  static RawTubes _colorsOf(List<List<int>> arr, List<int> colorsByToken) => [
        for (final t in arr) [for (final i in t) colorsByToken[i]],
      ];
}
