import '../../../../core/utils/game_helpers.dart';
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

  static RawTubes toRaw(List<Tube> tubes) => [for (final t in tubes) t.colorIds];
}
