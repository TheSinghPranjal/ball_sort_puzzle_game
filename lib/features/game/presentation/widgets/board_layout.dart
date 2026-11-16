import 'dart:math' as math;
import 'dart:ui';

/// Pure, responsive geometry for the board. Everything is derived from the
/// available size, tube count and capacity - no hard-coded coordinates.
class BoardLayout {
  BoardLayout._({
    required this.unit,
    required this.tubeWidth,
    required this.tubeHeight,
    required this.liftSpace,
    required this.columns,
    required this.rows,
    required this.capacity,
  });

  /// Ball diameter.
  final double unit;
  final double tubeWidth;
  final double tubeHeight;

  /// Space above each tube for the lifted (selected) ball.
  final double liftSpace;

  /// Hit/paint area per tube (lift space + tube), in board coordinates.
  final List<Rect> columns;
  final int rows;
  final int capacity;

  static const _tubeW = 1.32; // tube width / unit
  static const _spacing = 1.02; // vertical distance between ball centers / unit
  static const _topPad = 0.32;
  static const _bottomPad = 0.14;
  static const _lift = 1.45;
  static const _rowGap = 0.35;
  static const _minGap = 0.62;

  double get columnWidth => columns.isEmpty ? 0 : columns.first.width;
  double get ballSpacing => unit * _spacing;

  static double _tubeHeightUnits(int capacity) => _topPad + capacity * _spacing + _bottomPad;

  static BoardLayout compute(Size size, int tubeCount, int capacity) {
    final n = math.max(1, tubeCount);
    final w = math.max(1.0, size.width);
    final h = math.max(1.0, size.height);
    final margin = w * 0.04;
    final maxUnit = math.min(64.0, math.min(w, h) * 0.17);
    final colUnits = _lift + _tubeHeightUnits(capacity);

    var bestRows = 1;
    var bestUnit = 0.0;
    for (var r = 1; r <= math.min(n, 4); r++) {
      final perRow = (n / r).ceil();
      final uw = (w - 2 * margin) / (perRow * _tubeW + (perRow - 1) * _minGap);
      final uh = h / (r * colUnits + (r - 1) * _rowGap);
      final u = math.min(math.min(uw, uh), maxUnit);
      if (u > bestUnit * 1.04) {
        bestUnit = u;
        bestRows = r;
      }
    }

    final u = bestUnit;
    final tw = u * _tubeW;
    final th = u * _tubeHeightUnits(capacity);
    final lift = u * _lift;
    final colH = lift + th;
    final colW = tw * 1.35;

    // Balanced rows: earlier rows take the extra tube.
    final base = n ~/ bestRows;
    final extra = n % bestRows;
    final rowCounts = [for (var r = 0; r < bestRows; r++) base + (r < extra ? 1 : 0)];
    final maxPerRow = rowCounts.reduce(math.max);

    // Spread tubes out when there is room, but not absurdly far.
    final gap = maxPerRow <= 1
        ? 0.0
        : math.min(u * 1.6, (w - 2 * margin - maxPerRow * tw) / (maxPerRow - 1));
    final rowGap = u * _rowGap;
    final blockH = bestRows * colH + (bestRows - 1) * rowGap;
    final top0 = (h - blockH) / 2;

    final columns = <Rect>[];
    for (var r = 0; r < bestRows; r++) {
      final count = rowCounts[r];
      final rowW = count * tw + (count - 1) * gap;
      final left0 = (w - rowW) / 2;
      final top = top0 + r * (colH + rowGap);
      for (var i = 0; i < count; i++) {
        final cx = left0 + i * (tw + gap) + tw / 2;
        columns.add(Rect.fromLTWH(cx - colW / 2, top, colW, colH));
      }
    }

    return BoardLayout._(
      unit: u,
      tubeWidth: tw,
      tubeHeight: th,
      liftSpace: lift,
      columns: columns,
      rows: bestRows,
      capacity: capacity,
    );
  }

  /// Tube body rect relative to its column.
  Rect get tubeRectInColumn =>
      Rect.fromLTWH((columnWidth - tubeWidth) / 2, liftSpace, tubeWidth, tubeHeight);

  /// Ball center for [slot] (0 = bottom) relative to its column.
  Offset slotCenterInColumn(int slot) => Offset(
        columnWidth / 2,
        liftSpace + tubeHeight - unit * _bottomPad - unit / 2 - slot * ballSpacing,
      );

  /// Center of a lifted (selected) ball, relative to its column.
  Offset get liftedCenterInColumn => Offset(columnWidth / 2, liftSpace - unit * 0.62);

  Offset slotCenter(int tube, int slot) => columns[tube].topLeft + slotCenterInColumn(slot);
  Offset liftedCenter(int tube) => columns[tube].topLeft + liftedCenterInColumn;
  Rect tubeRect(int tube) => tubeRectInColumn.shift(columns[tube].topLeft);
}
