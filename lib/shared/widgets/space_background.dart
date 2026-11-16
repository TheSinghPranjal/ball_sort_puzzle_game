import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../animations/sparkle_painter.dart';

/// Midnight-purple radial background with static stars and a few sparkles.
class SpaceBackground extends StatelessWidget {
  const SpaceBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.background),
      child: Stack(fit: StackFit.expand, children: [
        const RepaintBoundary(child: CustomPaint(painter: _SpacePainter())),
        child,
      ]),
    );
  }
}

class _SpacePainter extends CustomPainter {
  const _SpacePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0, -0.1),
          radius: 0.95,
          colors: [AppColors.backgroundCenter, AppColors.background, AppColors.backgroundEdge],
          stops: [0.0, 0.55, 1.0],
        ).createShader(rect),
    );
    final rng = math.Random(42); // fixed layout: no flicker between frames
    final star = Paint();
    for (var i = 0; i < 90; i++) {
      final p = Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height);
      star.color = Colors.white.withValues(alpha: 0.15 + rng.nextDouble() * 0.45);
      canvas.drawCircle(p, 0.5 + rng.nextDouble() * 1.1, star);
    }
    const tints = [Color(0xFF8FA8FF), Color(0xFFC59BFF), Color(0xFF7FD3FF)];
    for (var i = 0; i < 9; i++) {
      final p = Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height);
      final r = 3.0 + rng.nextDouble() * 4;
      canvas.drawPath(
        SparklePainter.star(p, r),
        Paint()..color = tints[i % 3].withValues(alpha: 0.35 + rng.nextDouble() * 0.25),
      );
    }
  }

  @override
  bool shouldRepaint(_SpacePainter oldDelegate) => false;
}
