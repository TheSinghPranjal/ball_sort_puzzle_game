import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/game_palette.dart';
import '../animations/sparkle_painter.dart';

/// Radial "sky" background with static stars and a few sparkles. Midnight
/// purple in dark mode, soft lavender in light mode.
class SpaceBackground extends StatelessWidget {
  const SpaceBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(color: palette.background),
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(child: CustomPaint(painter: _SpacePainter(palette))),
          child,
        ],
      ),
    );
  }
}

class _SpacePainter extends CustomPainter {
  const _SpacePainter(this.palette);
  final GamePalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.1),
          radius: 0.95,
          colors: [
            palette.backgroundCenter,
            palette.background,
            palette.backgroundEdge,
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(rect),
    );
    final rng = math.Random(42); // fixed layout: no flicker between frames
    final star = Paint();
    for (var i = 0; i < 90; i++) {
      final p = Offset(
        rng.nextDouble() * size.width,
        rng.nextDouble() * size.height,
      );
      star.color = palette.star.withValues(
        alpha: 0.15 + rng.nextDouble() * 0.45,
      );
      canvas.drawCircle(p, 0.5 + rng.nextDouble() * 1.1, star);
    }
    const tints = [Color(0xFF8FA8FF), Color(0xFFC59BFF), Color(0xFF7FD3FF)];
    for (var i = 0; i < 9; i++) {
      final p = Offset(
        rng.nextDouble() * size.width,
        rng.nextDouble() * size.height,
      );
      final r = 3.0 + rng.nextDouble() * 4;
      canvas.drawPath(
        SparklePainter.star(p, r),
        Paint()
          ..color = tints[i % 3].withValues(
            alpha: 0.35 + rng.nextDouble() * 0.25,
          ),
      );
    }
  }

  @override
  bool shouldRepaint(_SpacePainter oldDelegate) =>
      oldDelegate.palette != palette;
}
