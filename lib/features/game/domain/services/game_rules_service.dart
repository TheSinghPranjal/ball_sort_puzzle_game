import 'dart:math' as math;

import '../../../../core/utils/game_helpers.dart';
import '../models/ball.dart';
import '../models/tube.dart';

enum MoveValidation {
  valid,
  invalidIndex,
  sameTube,
  sourceEmpty,
  destinationFull,
  colorMismatch,
}

/// Single source of truth for Ball Sort movement and completion rules.
/// Used by the game controller, the solver, the generator and the shuffler.
class GameRulesService {
  const GameRulesService();

  // ---------------------------------------------------------------------------
  // Raw (color-id list) rules - shared by solver/generator.
  // ---------------------------------------------------------------------------

  static MoveValidation validateRaw(
    RawTubes tubes,
    int from,
    int to,
    int capacity,
  ) {
    if (from < 0 || to < 0 || from >= tubes.length || to >= tubes.length) {
      return MoveValidation.invalidIndex;
    }
    if (from == to) return MoveValidation.sameTube;
    final src = tubes[from];
    final dst = tubes[to];
    if (src.isEmpty) return MoveValidation.sourceEmpty;
    if (dst.length >= capacity) return MoveValidation.destinationFull;
    if (dst.isNotEmpty && dst.last != src.last) {
      return MoveValidation.colorMismatch;
    }
    return MoveValidation.valid;
  }

  static bool canMoveRaw(RawTubes tubes, int from, int to, int capacity) =>
      validateRaw(tubes, from, to, capacity) == MoveValidation.valid;

  /// Solved when every color sits in exactly one tube and no tube is mixed.
  static bool isSolvedRaw(RawTubes tubes) {
    final seen = <int>{};
    for (final t in tubes) {
      if (t.isEmpty) continue;
      final c = t.first;
      for (final b in t) {
        if (b != c) return false;
      }
      if (!seen.add(c)) return false; // same color split across tubes
    }
    return true;
  }

  static bool hasAnyLegalMoveRaw(RawTubes tubes, int capacity) {
    for (var f = 0; f < tubes.length; f++) {
      if (tubes[f].isEmpty) continue;
      for (var t = 0; t < tubes.length; t++) {
        if (canMoveRaw(tubes, f, t, capacity)) return true;
      }
    }
    return false;
  }

  // ---------------------------------------------------------------------------
  // Tube-model rules - used by the game.
  // ---------------------------------------------------------------------------

  MoveValidation validateMove(List<Tube> tubes, int from, int to) {
    if (from < 0 || to < 0 || from >= tubes.length || to >= tubes.length) {
      return MoveValidation.invalidIndex;
    }
    if (from == to) return MoveValidation.sameTube;
    final src = tubes[from];
    final dst = tubes[to];
    if (src.isEmpty) return MoveValidation.sourceEmpty;
    if (dst.isFull) return MoveValidation.destinationFull;
    if (!dst.isEmpty && dst.topColor != src.topColor) {
      return MoveValidation.colorMismatch;
    }
    return MoveValidation.valid;
  }

  bool canMove(List<Tube> tubes, int from, int to) =>
      validateMove(tubes, from, to) == MoveValidation.valid;

  /// Returns a new tube list with the top ball of [from] moved onto [to].
  /// Throws [StateError] for an illegal move - callers must validate first.
  List<Tube> applyMove(List<Tube> tubes, int from, int to) {
    final v = validateMove(tubes, from, to);
    if (v != MoveValidation.valid) {
      throw StateError('Illegal move $from -> $to: $v');
    }
    final ball = tubes[from].topBall!;
    final next = List<Tube>.of(tubes);
    next[from] = tubes[from].pop();
    next[to] = tubes[to].push(ball);
    return next;
  }

  /// How many balls a move from [from] to [to] carries: the run of
  /// same-coloured balls on top of [from], limited by the free space in [to].
  /// [canTake] can further restrict which balls may travel (e.g. hidden ones).
  /// Returns 0 for an illegal move.
  int movableCount(
    List<Tube> tubes,
    int from,
    int to, {
    bool Function(Ball)? canTake,
  }) {
    if (!canMove(tubes, from, to)) return 0;
    final src = tubes[from].balls;
    final color = src.last.colorId;
    var run = 0;
    for (var i = src.length - 1; i >= 0; i--) {
      if (src[i].colorId != color) break;
      if (run > 0 && canTake != null && !canTake(src[i])) break;
      run++;
    }
    return math.min(run, tubes[to].freeSlots);
  }

  /// Moves up to [count] top balls from [from] to [to] (the whole same-colour
  /// run by default). Returns the new tubes and the balls moved, top first.
  ({List<Tube> tubes, List<Ball> moved}) applyBulkMove(
    List<Tube> tubes,
    int from,
    int to, {
    int? count,
  }) {
    final n = count ?? movableCount(tubes, from, to);
    if (n < 1 || !canMove(tubes, from, to)) {
      throw StateError('Illegal move $from -> $to');
    }
    final src = tubes[from].balls;
    final taken = src.sublist(src.length - n);
    final next = List<Tube>.of(tubes);
    next[from] = tubes[from].copyWith(balls: src.sublist(0, src.length - n));
    next[to] = tubes[to].copyWith(
      balls: [...tubes[to].balls, ...taken.reversed],
    );
    return (tubes: next, moved: taken.reversed.toList());
  }

  bool isSolved(List<Tube> tubes) => isSolvedRaw(toRaw(tubes));

  bool hasAnyLegalMove(List<Tube> tubes) {
    for (var f = 0; f < tubes.length; f++) {
      for (var t = 0; t < tubes.length; t++) {
        if (canMove(tubes, f, t)) return true;
      }
    }
    return false;
  }

  /// A tube is "complete" when it is uniform and holds every ball of its color.
  bool isTubeComplete(List<Tube> tubes, int index) {
    final tube = tubes[index];
    if (!tube.isUniform) return false;
    final color = tube.topColor;
    var total = 0;
    for (final t in tubes) {
      for (final b in t.balls) {
        if (b.colorId == color) total++;
      }
    }
    return total == tube.balls.length;
  }

  static RawTubes toRaw(List<Tube> tubes) => [
    for (final t in tubes) t.colorIds,
  ];
}
