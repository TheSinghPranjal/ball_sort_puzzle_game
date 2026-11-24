import 'package:ball_sort_puzzle_game/features/game/domain/models/ball.dart';
import 'package:ball_sort_puzzle_game/features/game/domain/models/tube.dart';
import 'package:ball_sort_puzzle_game/features/game/presentation/widgets/board_layout.dart';
import 'package:ball_sort_puzzle_game/features/game/presentation/widgets/glass_tube_widget.dart';
import 'package:ball_sort_puzzle_game/features/game/presentation/widgets/glossy_ball_widget.dart';
import 'package:ball_sort_puzzle_game/features/game/presentation/widgets/tube_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('glass tube and glossy ball render', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: GlassTubeWidget(
            width: 40,
            height: 150,
            child: Center(child: GlossyBallWidget(colorId: 3, diameter: 30)),
          ),
        ),
      ),
    );
    expect(find.byType(GlassTubeWidget), findsOneWidget);
    expect(tester.getSize(find.byType(GlossyBallWidget)), const Size(30, 30));
  });

  testWidgets('TubeView draws its balls and lifts the top ball when selected', (
    tester,
  ) async {
    final layout = BoardLayout.compute(const Size(360, 500), 4, 4);
    final tube = Tube(
      id: 0,
      capacity: 4,
      balls: const [Ball(id: 1, colorId: 0), Ball(id: 2, colorId: 1)],
    );
    var taps = 0;
    Widget build(bool selected) => Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: SizedBox.fromSize(
          size: layout.columns.first.size,
          child: TubeView(
            tube: tube,
            layout: layout,
            selected: selected,
            onTap: () => taps++,
          ),
        ),
      ),
    );
    await tester.pumpWidget(build(false));
    expect(find.byType(GlossyBallWidget), findsNWidgets(2));
    final restingY = tester.getCenter(find.byKey(const ValueKey(2))).dy;

    await tester.pumpWidget(build(true));
    await tester.pump(const Duration(milliseconds: 300));
    final liftedY = tester.getCenter(find.byKey(const ValueKey(2))).dy;
    expect(liftedY, lessThan(restingY - layout.unit * 2));
    // Bottom ball unchanged.
    await tester.tap(find.byType(TubeView));
    expect(taps, 1);
  });

  testWidgets('hidden (in-flight) ball is not drawn', (tester) async {
    final layout = BoardLayout.compute(const Size(360, 500), 4, 4);
    final tube = Tube(
      id: 0,
      capacity: 4,
      balls: const [Ball(id: 1, colorId: 0), Ball(id: 2, colorId: 1)],
    );
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox.fromSize(
          size: layout.columns.first.size,
          child: TubeView(
            tube: tube,
            layout: layout,
            hiddenBallId: 2,
            onTap: () {},
          ),
        ),
      ),
    );
    expect(find.byType(GlossyBallWidget), findsOneWidget);
  });

  group('responsive layout', () {
    const sizes = {
      '9:16 phone': Size(360, 520),
      '9:19.5 phone': Size(390, 640),
      '9:21 phone': Size(360, 660),
      'small phone': Size(320, 380),
      'tablet': Size(800, 900),
      'landscape': Size(780, 260),
    };
    for (final e in sizes.entries) {
      test('fits all tube counts on ${e.key}', () {
        for (var n = 2; n <= 14; n++) {
          final l = BoardLayout.compute(e.value, n, 4);
          expect(l.columns.length, n);
          for (final c in l.columns) {
            expect(c.left, greaterThanOrEqualTo(-0.01), reason: '$n tubes');
            expect(
              c.right,
              lessThanOrEqualTo(e.value.width + 0.01),
              reason: '$n tubes',
            );
            expect(c.top, greaterThanOrEqualTo(-0.01));
            expect(c.bottom, lessThanOrEqualTo(e.value.height + 0.01));
          }
          for (var i = 0; i < n; i++) {
            for (var j = i + 1; j < n; j++) {
              expect(
                l.columns[i].overlaps(l.columns[j]),
                isFalse,
                reason: '$n tubes: $i/$j',
              );
            }
          }
          // Balls stay inside their tube and never overlap each other.
          final tube = l.tubeRectInColumn;
          final top = l.slotCenterInColumn(3);
          final bottom = l.slotCenterInColumn(0);
          expect(top.dy - l.unit / 2, greaterThan(tube.top));
          expect(bottom.dy + l.unit / 2, lessThan(tube.bottom));
          expect(l.ballSpacing, greaterThanOrEqualTo(l.unit));
          expect(
            l.unit,
            greaterThan(12),
            reason: 'balls too small for $n tubes',
          );
        }
      });
    }

    test('uses multiple balanced rows for large boards on phones', () {
      final l = BoardLayout.compute(const Size(360, 560), 12, 4);
      expect(l.rows, greaterThan(1));
    });
  });
}
