import 'package:collection/collection.dart';

import '../../../../core/utils/game_helpers.dart';
import 'game_rules_service.dart';

class SolverMove {
  const SolverMove(this.from, this.to);
  final int from;
  final int to;

  @override
  bool operator ==(Object other) =>
      other is SolverMove && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(from, to);

  @override
  String toString() => '$from->$to';
}

class SolverResult {
  const SolverResult({
    required this.solvable,
    required this.moves,
    required this.nodesExpanded,
    required this.exhausted,
  });

  /// True when a solution was found.
  final bool solvable;

  /// Single-ball moves (tube indices) that solve the puzzle. Empty if unsolved.
  final List<SolverMove> moves;
  final int nodesExpanded;

  /// True when search ran out of budget (result inconclusive).
  final bool exhausted;
}

class _Node {
  _Node(this.tubes, this.parent, this.from, this.to, this.count, this.g, this.f);
  final RawTubes tubes;
  final _Node? parent;
  final int from;
  final int to;
  final int count; // balls moved by this macro step
  final int g;
  final int f;
}

/// Weighted A* over macro moves (moving a whole same-color top run as far as
/// it fits, which is always a sequence of legal single moves). Every move is
/// validated by [GameRulesService]. Visited states use an order-independent
/// key so permutations of tubes are explored only once.
class PuzzleSolverService {
  const PuzzleSolverService();

  SolverResult solve(
    RawTubes start,
    int capacity, {
    int nodeLimit = 60000,
    double weight = 2.0,
  }) {
    final colors = colorCounts(start).length;
    if (GameRulesService.isSolvedRaw(start)) {
      return const SolverResult(
          solvable: true, moves: [], nodesExpanded: 0, exhausted: false);
    }

    final open = HeapPriorityQueue<_Node>((a, b) {
      final c = a.f.compareTo(b.f);
      return c != 0 ? c : b.g.compareTo(a.g);
    });
    final visited = <String>{};
    final h0 = _heuristic(start, colors);
    open.add(_Node(cloneRaw(start), null, -1, -1, 0, 0, (weight * h0).round()));
    var expanded = 0;

    while (open.isNotEmpty) {
      final node = open.removeFirst();
      final key = canonicalKey(node.tubes);
      if (!visited.add(key)) continue;
      expanded++;
      if (GameRulesService.isSolvedRaw(node.tubes)) {
        return SolverResult(
          solvable: true,
          moves: _reconstruct(node),
          nodesExpanded: expanded,
          exhausted: false,
        );
      }
      if (expanded >= nodeLimit) {
        return SolverResult(
            solvable: false, moves: const [], nodesExpanded: expanded, exhausted: true);
      }
      for (final child in _expand(node, capacity, colors, weight)) {
        if (!visited.contains(canonicalKey(child.tubes))) open.add(child);
      }
    }
    return SolverResult(
        solvable: false, moves: const [], nodesExpanded: expanded, exhausted: false);
  }

  /// First single-ball move toward a solution (for hints / tutorials).
  SolverMove? nextHint(RawTubes tubes, int capacity, {int nodeLimit = 60000}) {
    final r = solve(tubes, capacity, nodeLimit: nodeLimit);
    return r.moves.isEmpty ? null : r.moves.first;
  }

  Iterable<_Node> _expand(_Node node, int capacity, int colors, double weight) sync* {
    final tubes = node.tubes;
    for (var from = 0; from < tubes.length; from++) {
      final src = tubes[from];
      if (src.isEmpty) continue;
      final srcUniform = src.every((c) => c == src.first);
      // A full uniform tube is finished; never take from it.
      if (srcUniform && src.length == capacity) continue;
      final color = src.last;
      var run = 1;
      while (run < src.length && src[src.length - 1 - run] == color) {
        run++;
      }
      var triedEmpty = false;
      for (var to = 0; to < tubes.length; to++) {
        if (!GameRulesService.canMoveRaw(tubes, from, to, capacity)) continue;
        final dst = tubes[to];
        if (dst.isEmpty) {
          if (srcUniform) continue; // pointless: just relocates a pure tube
          if (triedEmpty) continue; // empty tubes are interchangeable
          triedEmpty = true;
        }
        final count = run < capacity - dst.length ? run : capacity - dst.length;
        final next = cloneRaw(tubes);
        for (var i = 0; i < count; i++) {
          next[to].add(next[from].removeLast());
        }
        final g = node.g + 1;
        final h = _heuristic(next, colors);
        yield _Node(next, node, from, to, count, g, g + (weight * h).round());
      }
    }
  }

  static int _heuristic(RawTubes tubes, int colors) {
    // Each extra segment needs at least one move to merge; buried balls under a
    // different color need their cover removed first.
    var buried = 0;
    for (final t in tubes) {
      if (t.isEmpty) continue;
      final base = t.first;
      var i = 0;
      while (i < t.length && t[i] == base) {
        i++;
      }
      buried += t.length - i;
    }
    return (segmentCount(tubes) - colors) + buried ~/ 2;
  }

  List<SolverMove> _reconstruct(_Node goal) {
    final macro = <_Node>[];
    for (_Node? n = goal; n != null && n.parent != null; n = n.parent) {
      macro.add(n);
    }
    final moves = <SolverMove>[];
    for (final n in macro.reversed) {
      for (var i = 0; i < n.count; i++) {
        moves.add(SolverMove(n.from, n.to));
      }
    }
    return moves;
  }

  /// Replays [moves] with the game rules; true if they legally solve [start].
  static bool verifySolution(RawTubes start, int capacity, List<SolverMove> moves) {
    final t = cloneRaw(start);
    for (final m in moves) {
      if (!GameRulesService.canMoveRaw(t, m.from, m.to, capacity)) return false;
      t[m.to].add(t[m.from].removeLast());
    }
    return GameRulesService.isSolvedRaw(t);
  }
}
