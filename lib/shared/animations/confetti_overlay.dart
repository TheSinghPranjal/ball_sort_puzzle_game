import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Lightweight one-shot confetti burst (fixed particle count, one painter).
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key, required this.play});

  /// Starts a burst whenever this flips to true.
  final bool play;

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _Particle {
  _Particle(math.Random r)
    : x = 0.15 + r.nextDouble() * 0.7,
      vx = (r.nextDouble() - 0.5) * 0.9,
      vy = -(0.9 + r.nextDouble() * 0.9),
      spin = (r.nextDouble() - 0.5) * 14,
      size = 5 + r.nextDouble() * 6,
      color = AppColors.balls[r.nextInt(8)].primary,
      round = r.nextBool();
  final double x, vx, vy, spin, size;
  final Color color;
  final bool round;
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  List<_Particle> _particles = const [];

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
  }

  @override
  void didUpdateWidget(ConfettiOverlay old) {
    super.didUpdateWidget(old);
    if (widget.play && !old.play) {
      final r = math.Random();
      _particles = List.generate(80, (_) => _Particle(r));
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => _c.isAnimating
              ? CustomPaint(
                  size: Size.infinite,
                  painter: _ConfettiPainter(_particles, _c.value),
                )
              : const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.particles, this.t);
  final List<_Particle> particles;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final fade = t > 0.75 ? (1 - t) / 0.25 : 1.0;
    for (final p in particles) {
      final time = t * 2.4;
      final x = (p.x + p.vx * time * 0.35) * size.width;
      final y =
          size.height *
          (0.55 + p.vy * time * 0.55 + 0.5 * 1.1 * time * time * 0.55);
      paint.color = p.color.withValues(alpha: fade.clamp(0, 1));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.spin * time);
      if (p.round) {
        canvas.drawCircle(Offset.zero, p.size * 0.45, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.5,
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
