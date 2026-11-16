import 'ball.dart';
import 'tube.dart';

enum Difficulty { tutorial, easy, medium, hard, expert, master, legend }

extension DifficultyLabel on Difficulty {
  String get label => switch (this) {
        Difficulty.tutorial => 'Tutorial',
        Difficulty.easy => 'Easy',
        Difficulty.medium => 'Medium',
        Difficulty.hard => 'Hard',
        Difficulty.expert => 'Expert',
        Difficulty.master => 'Master',
        Difficulty.legend => 'Legend',
      };
}

enum PowerUpType { undo, shuffle, addTube }

/// Which interactive tutorial (if any) runs on a level.
enum TutorialType { none, basicMove, sameColor, powerUps }

class LevelConfig {
  LevelConfig({
    required this.levelId,
    required this.name,
    required this.tubeCapacity,
    required List<List<int>> initialTubeArrangement,
    required this.difficulty,
    this.parMoves,
    this.moveTarget,
    this.timeLimitSeconds,
    this.availablePowerUps = const {
      PowerUpType.undo,
      PowerUpType.shuffle,
      PowerUpType.addTube,
    },
    this.undoUses = 5,
    this.shuffleUses = 2,
    this.addTubeUses = 2,
    this.newMechanic,
    this.tutorial = TutorialType.none,
    this.mystery = false,
  }) : initialTubeArrangement = List.unmodifiable(
          [for (final t in initialTubeArrangement) List<int>.unmodifiable(t)],
        );

  final int levelId;
  final String name;
  final int tubeCapacity;

  /// Color ids per tube, bottom -> top.
  final List<List<int>> initialTubeArrangement;
  final Difficulty difficulty;

  /// Length of the verified reference solution (single-ball moves).
  final int? parMoves;

  /// Optional challenge objective: finish within this many moves.
  final int? moveTarget;

  /// Optional timed-challenge limit. Null = relaxed, untimed level.
  final int? timeLimitSeconds;

  final Set<PowerUpType> availablePowerUps;
  final int undoUses;
  final int shuffleUses;
  final int addTubeUses;

  /// Short description when this level introduces something new.
  final String? newMechanic;
  final TutorialType tutorial;

  /// Mystery level: every ball below the top of its tube starts hidden ("?")
  /// and is revealed once it reaches the top. Display-only: rules and
  /// solvability are unchanged.
  final bool mystery;

  /// Special levels use taller tubes than the standard four balls.
  bool get isSpecial => tubeCapacity > 4;

  int get tubeCount => initialTubeArrangement.length;

  int get colorCount =>
      {for (final t in initialTubeArrangement) ...t}.length;

  int get emptyTubeCount =>
      initialTubeArrangement.where((t) => t.isEmpty).length;

  int get ballCount =>
      initialTubeArrangement.fold(0, (sum, t) => sum + t.length);

  bool get isTimed => timeLimitSeconds != null;

  /// Builds fresh tubes with stable ball ids (0..n-1) and tube ids (0..m-1).
  List<Tube> buildTubes() {
    var ballId = 0;
    return [
      for (var i = 0; i < initialTubeArrangement.length; i++)
        Tube(
          id: i,
          capacity: tubeCapacity,
          balls: [
            for (final c in initialTubeArrangement[i])
              Ball(id: ballId++, colorId: c),
          ],
        ),
    ];
  }

  int usesFor(PowerUpType type) {
    if (!availablePowerUps.contains(type)) return 0;
    return switch (type) {
      PowerUpType.undo => undoUses,
      PowerUpType.shuffle => shuffleUses,
      PowerUpType.addTube => addTubeUses,
    };
  }

  /// Stars: 3 within target, 2 within 1.5x target, otherwise 1.
  int starsFor(int moves) {
    final target = moveTarget ?? ((parMoves ?? moves) * 1.25).ceil();
    if (moves <= target) return 3;
    if (moves <= (target * 1.5).ceil()) return 2;
    return 1;
  }
}
