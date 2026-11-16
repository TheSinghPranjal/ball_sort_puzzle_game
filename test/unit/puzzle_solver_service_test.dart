import 'package:ball_sort_puzzle_game/features/game/domain/services/puzzle_solver_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const solver = PuzzleSolverService();

  test('already solved puzzle needs no moves', () {
    final r = solver.solve([[0, 0, 0, 0], []], 4);
    expect(r.solvable, isTrue);
    expect(r.moves, isEmpty);
  });

  test('solves a simple two-color puzzle with a valid path', () {
    final start = [[0, 0, 1, 1], [1, 1, 0, 0], <int>[]];
    final r = solver.solve(start, 4);
    expect(r.solvable, isTrue);
    expect(PuzzleSolverService.verifySolution(start, 4, r.moves), isTrue);
  });

  test('solves a mixed four-color puzzle', () {
    final start = [
      [0, 1, 2, 3],
      [3, 2, 1, 0],
      [1, 3, 0, 2],
      [2, 0, 3, 1],
      <int>[],
      <int>[],
    ];
    final r = solver.solve(start, 4);
    expect(r.solvable, isTrue);
    expect(PuzzleSolverService.verifySolution(start, 4, r.moves), isTrue);
  });

  test('reports a deadlocked puzzle as unsolvable without looping', () {
    final r = solver.solve([[0, 1], [1, 0]], 2);
    expect(r.solvable, isFalse);
    expect(r.exhausted, isFalse);
  });

  test('respects the node budget', () {
    final r = solver.solve([
      [0, 1, 2, 3], [4, 5, 6, 7], [1, 0, 3, 2], [5, 4, 7, 6],
      [2, 3, 0, 1], [6, 7, 4, 5], [3, 2, 1, 0], [7, 6, 5, 4], <int>[],
    ], 4, nodeLimit: 5);
    expect(r.nodesExpanded, lessThanOrEqualTo(5));
  });

  test('hint is the first move of a valid solution', () {
    final start = [[0, 0, 0], [0]];
    final hint = solver.nextHint(start, 4);
    expect(hint, isNotNull);
    expect(PuzzleSolverService.verifySolution(start, 4, [hint!]), isTrue);
  });

  test('verifySolution rejects illegal sequences', () {
    expect(PuzzleSolverService.verifySolution([[0], [1]], 4, const [SolverMove(0, 1)]), isFalse);
  });
}
