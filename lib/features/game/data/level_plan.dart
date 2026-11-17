import '../domain/models/level_config.dart';
import '../domain/services/level_generator_service.dart';

/// Design blueprint for every level: difficulty band, generator spec and
/// extra features. Used by `tool/generate_levels.dart` to (re)build the curated
/// level data, and at runtime for levels beyond the curated set.
class LevelPlanEntry {
  const LevelPlanEntry({
    required this.id,
    required this.difficulty,
    this.spec,
    this.fallbackSpecs = const [],
    this.fixed,
    this.timed = false,
    this.moveTarget = false,
    this.powerUps = const {
      PowerUpType.undo,
      PowerUpType.shuffle,
      PowerUpType.addTube,
    },
    this.newMechanic,
    this.tutorial = TutorialType.none,
    this.mystery = false,
  });

  final int id;
  final Difficulty difficulty;
  final LevelSpec? spec;
  final List<LevelSpec> fallbackSpecs;
  final List<List<int>>? fixed;
  final bool timed;
  final bool moveTarget;
  final Set<PowerUpType> powerUps;
  final String? newMechanic;
  final TutorialType tutorial;
  final bool mystery;

  int get capacity => spec?.capacity ?? 4;

  int get seed => 0x5EED0000 + id * 7919;
}

class LevelPlan {
  LevelPlan._();

  static const _timedLevels = {30, 50, 70, 90};

  static double _t(int id, int start, int end) =>
      end == start ? 1 : (id - start) / (end - start);

  static const mysteryIntroLevel = 17;
  static const legendStart = 501;

  /// Curated special (tall-tube) levels inside 1-100.
  static const _curatedSpecials = {25: 5, 45: 6, 65: 7, 85: 8, 100: 9};

  static LevelPlanEntry entry(int id) {
    final base = id >= legendStart ? _legend(id) : _base(id);
    final mystery = base.mystery || _mysteryFor(id);
    final mechanic =
        base.newMechanic ??
        (id == mysteryIntroLevel
            ? 'Mystery balls: hidden colors reveal when they reach the top'
            : (base.capacity > 4 && id == 25
                  ? 'Special level: taller tubes'
                  : null));
    if (mystery == base.mystery && mechanic == base.newMechanic) return base;
    return LevelPlanEntry(
      id: base.id,
      difficulty: base.difficulty,
      spec: base.spec,
      fallbackSpecs: base.fallbackSpecs,
      fixed: base.fixed,
      timed: base.timed,
      moveTarget: base.moveTarget,
      powerUps: base.powerUps,
      newMechanic: mechanic,
      tutorial: base.tutorial,
      mystery: mystery,
    );
  }

  /// Mystery levels in 1-500: introduced at 17, then every 5th level in the
  /// curated set and two in five afterwards (never on timed levels).
  static bool _mysteryFor(int id) {
    if (id < mysteryIntroLevel ||
        id >= legendStart ||
        _timedLevels.contains(id))
      return false;
    if (id <= 100) return id % 5 == 2;
    return id % 5 == 2 || id % 5 == 4;
  }

  static LevelPlanEntry _base(int id) {
    if (id < 1) throw RangeError.value(id, 'id');
    final special = _curatedSpecials[id];
    if (special != null) {
      final band = id <= 40
          ? Difficulty.medium
          : id <= 60
          ? Difficulty.hard
          : id <= 80
          ? Difficulty.expert
          : Difficulty.master;
      return LevelPlanEntry(
        id: id,
        difficulty: band,
        spec: LevelSpec(
          colors: special,
          emptyTubes: 2,
          capacity: 6,
          maxRun: 2,
          quantile: 0.6,
        ),
        fallbackSpecs: [
          LevelSpec(colors: special, emptyTubes: 2, capacity: 6, maxRun: 3),
        ],
        moveTarget: id > 40,
      );
    }
    switch (id) {
      case 1:
        return const LevelPlanEntry(
          id: 1,
          difficulty: Difficulty.tutorial,
          fixed: [
            [0, 0, 0],
            [0],
          ],
          powerUps: {},
          newMechanic: 'Tap a tube, then tap another to move a ball',
          tutorial: TutorialType.basicMove,
        );
      case 2:
        return const LevelPlanEntry(
          id: 2,
          difficulty: Difficulty.tutorial,
          fixed: [
            [0, 0, 1, 1],
            [1, 1, 0, 0],
            [],
          ],
          powerUps: {},
          newMechanic: 'Only matching colors stack',
          tutorial: TutorialType.sameColor,
        );
      case 3:
        return const LevelPlanEntry(
          id: 3,
          difficulty: Difficulty.tutorial,
          spec: LevelSpec(colors: 3, emptyTubes: 2, maxRun: 2, quantile: 0.15),
          newMechanic: 'Undo, Shuffle and Add Tube',
          tutorial: TutorialType.powerUps,
        );
      case 4:
        return const LevelPlanEntry(
          id: 4,
          difficulty: Difficulty.tutorial,
          spec: LevelSpec(colors: 2, emptyTubes: 2, maxRun: 1, quantile: 1),
          newMechanic: 'Plan several moves ahead',
        );
      case 5:
        return const LevelPlanEntry(
          id: 5,
          difficulty: Difficulty.tutorial,
          spec: LevelSpec(colors: 3, emptyTubes: 2, maxRun: 2, quantile: 0.8),
        );
    }

    if (id <= 20) {
      // Easy: 3-5 colors, 4-6 tubes.
      const layout = {
        6: [3, 1],
        7: [3, 2],
        8: [3, 1],
        9: [3, 2],
        10: [4, 2],
        11: [4, 2],
        12: [4, 1],
        13: [4, 2],
        14: [4, 2],
        15: [4, 1],
        16: [4, 2],
        17: [5, 1],
        18: [4, 2],
        19: [5, 1],
        20: [4, 1],
      };
      final l = layout[id]!;
      final t = _t(id, 6, 20);
      return LevelPlanEntry(
        id: id,
        difficulty: Difficulty.easy,
        spec: LevelSpec(
          colors: l[0],
          emptyTubes: l[1],
          maxRun: t < 0.4 ? 3 : 2,
          minMoves: 4 + (t * 8).round(),
          quantile: 0.2 + 0.6 * t,
        ),
        fallbackSpecs: [LevelSpec(colors: l[0], emptyTubes: 2, maxRun: 2)],
        newMechanic: id == 6 ? 'Only one spare tube!' : null,
      );
    }

    if (id <= 40) {
      // Medium: 5-7 colors, 6-8 tubes.
      final colors = id <= 27 ? 5 : (id <= 34 ? 6 : 7);
      final empties = colors == 7 ? 1 : ((id % 3 == 0) ? 1 : 2);
      final t = _t(id, 21, 40);
      final spread = id % 5 == 4;
      return LevelPlanEntry(
        id: id,
        difficulty: Difficulty.medium,
        spec: LevelSpec(
          colors: colors,
          emptyTubes: empties,
          maxRun: 2,
          requireSpreadColor: spread,
          minMoves: 14 + (t * 8).round(),
          quantile: 0.3 + 0.5 * t,
        ),
        fallbackSpecs: [
          LevelSpec(
            colors: colors,
            emptyTubes: 2,
            maxRun: 2,
            requireSpreadColor: spread,
          ),
        ],
        timed: _timedLevels.contains(id),
        newMechanic: spread
            ? 'One color is scattered through nearly every tube'
            : (id == 21 ? 'Bigger boards' : null),
      );
    }

    if (id <= 60) {
      // Intermediate/Hard: 6-8 colors, 7-10 tubes.
      final colors = id <= 46 ? 6 : (id <= 53 ? 7 : 8);
      final empties = id % 4 == 0 ? 1 : 2;
      final t = _t(id, 41, 60);
      return LevelPlanEntry(
        id: id,
        difficulty: Difficulty.hard,
        spec: LevelSpec(
          colors: colors,
          emptyTubes: empties,
          maxRun: 2,
          requireSpreadColor: id % 6 == 0,
          minMoves: 18 + (t * 10).round(),
          quantile: 0.35 + 0.5 * t,
        ),
        fallbackSpecs: [LevelSpec(colors: colors, emptyTubes: 2, maxRun: 2)],
        timed: _timedLevels.contains(id),
        moveTarget: true,
        newMechanic: id == 41
            ? 'Move targets: finish within the goal for 3 stars'
            : null,
      );
    }

    if (id <= 80) {
      // Hard: 7-9 colors, 8-11 tubes.
      final colors = id <= 66 ? 7 : (id <= 73 ? 8 : 9);
      final empties = id % 3 == 0 ? 1 : 2;
      final t = _t(id, 61, 80);
      return LevelPlanEntry(
        id: id,
        difficulty: Difficulty.expert,
        spec: LevelSpec(
          colors: colors,
          emptyTubes: empties,
          maxRun: id.isEven ? 1 : 2,
          requireSpreadColor: id % 5 == 0,
          minMoves: 22 + (t * 12).round(),
          quantile: 0.4 + 0.5 * t,
          candidates: 8,
        ),
        fallbackSpecs: [
          LevelSpec(colors: colors, emptyTubes: 2, maxRun: 2, candidates: 8),
        ],
        timed: _timedLevels.contains(id),
        moveTarget: true,
      );
    }

    if (id <= 100) {
      // Expert: 8-10 colors, 9-12 tubes.
      final colors = id <= 86 ? 8 : (id <= 93 ? 9 : 10);
      final t = _t(id, 81, 100);
      return LevelPlanEntry(
        id: id,
        difficulty: Difficulty.master,
        spec: LevelSpec(
          colors: colors,
          emptyTubes: 2,
          maxRun: 1,
          requireSpreadColor: id % 4 == 0,
          minMoves: 28 + (t * 14).round(),
          quantile: 0.5 + 0.45 * t,
          candidates: 8,
        ),
        fallbackSpecs: [
          LevelSpec(colors: colors, emptyTubes: 2, maxRun: 2, candidates: 8),
        ],
        timed: _timedLevels.contains(id),
        moveTarget: true,
      );
    }

    // Challenge pack 101-500. Every 25th level is special: alternating tall
    // tubes (6 balls) and giant tubes (8 balls).
    if (id % 25 == 0) {
      final giant = id % 50 == 0;
      final colors = giant ? 5 : 7 + (id ~/ 25) % 2;
      final cap = giant ? 8 : 6;
      return LevelPlanEntry(
        id: id,
        difficulty: Difficulty.master,
        spec: LevelSpec(
          colors: colors,
          emptyTubes: 2,
          capacity: cap,
          maxRun: 2,
          quantile: 0.6,
          candidates: 4,
        ),
        fallbackSpecs: [
          LevelSpec(
            colors: colors,
            emptyTubes: 2,
            capacity: cap,
            maxRun: 3,
            candidates: 2,
          ),
        ],
        moveTarget: true,
      );
    }
    final colors = 8 + (id % 3);
    return LevelPlanEntry(
      id: id,
      difficulty: Difficulty.master,
      spec: LevelSpec(
        colors: colors,
        emptyTubes: 2,
        maxRun: id.isEven ? 1 : 2,
        minMoves: 26,
        quantile: 0.6,
        candidates: 3,
        maxAttempts: 120,
      ),
      fallbackSpecs: [
        LevelSpec(
          colors: colors,
          emptyTubes: 2,
          maxRun: 2,
          candidates: 1,
          maxAttempts: 400,
        ),
      ],
      moveTarget: true,
    );
  }

  /// Legend pack 501-1000: much tougher than anything before it.
  ///
  /// Toughness comes from tighter boards rather than just more balls:
  /// - dense: 11-12 colors, fully alternating (no two neighbours match);
  /// - tight: 8-10 colors with only ONE spare tube (mistakes are fatal);
  /// - tall / giant special levels (6, 8 or 10 balls per tube);
  /// - mystery balls on a growing share of levels (all but 1 in 5 at the end);
  /// - candidates are ranked by solution length, search effort and trap rate
  ///   (how often a few careless moves make the board unsolvable), and the
  ///   hardest ones are kept.
  static LevelPlanEntry _legend(int id) {
    final t = (id - legendStart) / (1000 - legendStart);
    final quantile = 0.7 + 0.3 * t;
    final mystery = t < 0.33
        ? id % 3 == 0
        : (t < 0.66 ? id.isEven : id % 5 != 0);
    final kind = id % 10;
    LevelSpec spec;
    List<LevelSpec> fallbacks;
    if (kind == 0) {
      final cap = t < 0.5 ? 8 : 10;
      spec = LevelSpec(
        colors: 5,
        emptyTubes: 2,
        capacity: cap,
        maxRun: 2,
        minMoves: cap * 7,
        quantile: quantile,
        candidates: 6,
        trapSamples: 10,
      );
      fallbacks = [
        LevelSpec(
          colors: 5,
          emptyTubes: 2,
          capacity: cap,
          maxRun: 3,
          candidates: 2,
        ),
      ];
    } else if (kind == 5) {
      final colors = t < 0.5 ? 9 : 10;
      spec = LevelSpec(
        colors: colors,
        emptyTubes: 2,
        capacity: 6,
        maxRun: 2,
        minMoves: 90,
        quantile: quantile,
        candidates: 6,
        trapSamples: 10,
      );
      fallbacks = [
        LevelSpec(
          colors: colors,
          emptyTubes: 2,
          capacity: 6,
          maxRun: 2,
          candidates: 2,
        ),
      ];
    } else if (kind == 3 || kind == 7) {
      final colors = 8 + (t * 2.99).floor();
      spec = LevelSpec(
        colors: colors,
        emptyTubes: 1,
        maxRun: 2,
        minMoves: 36,
        quantile: quantile,
        candidates: 5,
        trapSamples: 10,
        maxAttempts: 4000,
      );
      fallbacks = [
        LevelSpec(
          colors: 8,
          emptyTubes: 1,
          maxRun: 2,
          candidates: 3,
          trapSamples: 10,
          maxAttempts: 4000,
        ),
        LevelSpec(colors: colors + 1, emptyTubes: 2, maxRun: 1, candidates: 3),
      ];
    } else if ((kind == 4 || kind == 8) && t > 0.6) {
      spec = LevelSpec(
        colors: 10,
        emptyTubes: 2,
        capacity: 5,
        maxRun: 1,
        minMoves: 75,
        quantile: quantile,
        candidates: 6,
        trapSamples: 10,
      );
      fallbacks = [
        const LevelSpec(
          colors: 10,
          emptyTubes: 2,
          capacity: 5,
          maxRun: 2,
          candidates: 2,
        ),
      ];
    } else {
      final colors = t < 0.4 ? 11 : 12;
      spec = LevelSpec(
        colors: colors,
        emptyTubes: 2,
        maxRun: 1,
        minMoves: 58,
        quantile: quantile,
        candidates: 6,
        trapSamples: 10,
      );
      fallbacks = [
        LevelSpec(colors: colors, emptyTubes: 2, maxRun: 2, candidates: 2),
      ];
    }
    return LevelPlanEntry(
      id: id,
      difficulty: Difficulty.legend,
      spec: spec,
      fallbackSpecs: fallbacks,
      moveTarget: true,
      mystery: mystery,
      newMechanic: id == legendStart
          ? 'Legend levels: brutal boards, little room for mistakes'
          : null,
    );
  }

  static int? timeLimitFor(LevelPlanEntry e, int par) =>
      e.timed ? ((par * 5 + 60) / 10).ceil() * 10 : null;

  static int? moveTargetFor(LevelPlanEntry e, int par) =>
      e.moveTarget ? (par * 1.15).ceil() + 2 : null;

  static const _adjectives = [
    'Violet',
    'Neon',
    'Silent',
    'Cosmic',
    'Velvet',
    'Crystal',
    'Lunar',
    'Amber',
    'Frozen',
    'Twilight',
    'Golden',
    'Hidden',
    'Electric',
    'Misty',
    'Radiant',
    'Shadow',
    'Starlit',
    'Copper',
    'Midnight',
    'Polar',
  ];
  static const _nouns = [
    'Drift',
    'Orbit',
    'Cascade',
    'Prism',
    'Garden',
    'Harbor',
    'Echo',
    'Spiral',
    'Comet',
    'Meadow',
    'Lantern',
    'Tide',
    'Nebula',
    'Quartz',
    'Canyon',
    'Aurora',
    'Ripple',
    'Summit',
    'Glacier',
    'Vortex',
    'Pulse',
  ];

  static String nameFor(int id) {
    switch (id) {
      case 1:
        return 'First Drop';
      case 2:
        return 'Two Tones';
      case 3:
        return 'Toolbox';
    }
    final a = _adjectives[(id * 7) % _adjectives.length];
    final n = _nouns[(id * 11 + id ~/ _adjectives.length) % _nouns.length];
    return '$a $n';
  }
}
