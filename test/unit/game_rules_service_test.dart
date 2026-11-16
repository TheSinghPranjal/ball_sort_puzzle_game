import 'package:ball_sort_puzzle_game/features/game/domain/services/game_rules_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

void main() {
  const rules = GameRulesService();
  const orange = 0, purple = 1, green = 2;

  group('movement', () {
    test('ball into an empty tube is valid', () {
      final t = tubes([[orange], []]);
      expect(rules.validateMove(t, 0, 1), MoveValidation.valid);
      final after = rules.applyMove(t, 0, 1);
      expect(after[0].isEmpty, isTrue);
      expect(after[1].colorIds, [orange]);
    });

    test('ball onto the same color is valid', () {
      final t = tubes([[purple, orange], [orange]]);
      expect(rules.canMove(t, 0, 1), isTrue);
      expect(rules.applyMove(t, 0, 1)[1].colorIds, [orange, orange]);
    });

    test('ball onto a different color is invalid', () {
      final t = tubes([[orange], [purple]]);
      expect(rules.validateMove(t, 0, 1), MoveValidation.colorMismatch);
      expect(() => rules.applyMove(t, 0, 1), throwsStateError);
    });

    test('ball into a full tube is invalid', () {
      final t = tubes([[orange], [orange, orange, orange, orange]]);
      expect(rules.validateMove(t, 0, 1), MoveValidation.destinationFull);
    });

    test('moving from an empty tube is invalid', () {
      final t = tubes([[], [orange]]);
      expect(rules.validateMove(t, 0, 1), MoveValidation.sourceEmpty);
    });

    test('moving onto the same tube is invalid', () {
      final t = tubes([[orange], []]);
      expect(rules.validateMove(t, 0, 0), MoveValidation.sameTube);
    });

    test('out-of-range indices are invalid', () {
      final t = tubes([[orange]]);
      expect(rules.validateMove(t, 0, 3), MoveValidation.invalidIndex);
      expect(rules.validateMove(t, -1, 0), MoveValidation.invalidIndex);
    });

    test('moving the last ball out leaves an empty tube', () {
      final t = tubes([[green], [green, green]]);
      final after = rules.applyMove(t, 0, 1);
      expect(after[0].balls, isEmpty);
      expect(after[1].colorIds, [green, green, green]);
    });

    test('ball into a tube with exactly one free slot', () {
      final t = tubes([[green], [green, green, green]]);
      final after = rules.applyMove(t, 0, 1);
      expect(after[1].isFull, isTrue);
      expect(rules.validateMove(after, 1, 0), MoveValidation.valid);
    });

    test('applyMove keeps ball identity and does not mutate input', () {
      final t = tubes([[orange, purple], [purple]]);
      final moved = t[0].topBall!;
      final after = rules.applyMove(t, 0, 1);
      expect(after[1].topBall, same(moved));
      expect(t[0].colorIds, [orange, purple]);
    });
  });

  group('completion', () {
    test('fully sorted puzzle is complete', () {
      expect(rules.isSolved(tubes([[0, 0, 0, 0], [1, 1, 1, 1], []])), isTrue);
    });

    test('partially sorted puzzle is not complete', () {
      expect(rules.isSolved(tubes([[0, 0, 1, 0], [1, 1, 1, 0], []])), isFalse);
    });

    test('same color split across two tubes is not complete', () {
      expect(rules.isSolved(tubes([[0, 0], [0, 0], [1, 1, 1, 1]])), isFalse);
    });

    test('empty tubes are allowed', () {
      expect(rules.isSolved(tubes([[], [2, 2, 2, 2], [], []])), isTrue);
    });

    test('all balls consolidated correctly', () {
      expect(rules.isSolved(tubes([[0, 0, 0, 0], [1, 1, 1, 1], [2, 2, 2, 2]])), isTrue);
    });

    test('tube completeness requires every ball of its color', () {
      final t = tubes([[0, 0, 0], [0], [1, 1, 1, 1]]);
      expect(rules.isTubeComplete(t, 0), isFalse);
      expect(rules.isTubeComplete(t, 2), isTrue);
    });
  });

  test('detects when no legal move exists', () {
    expect(rules.hasAnyLegalMove(tubes([[0, 1], [1, 0]], capacity: 2)), isFalse);
    expect(rules.hasAnyLegalMove(tubes([[0, 1], [1]], capacity: 2)), isTrue);
  });
}
