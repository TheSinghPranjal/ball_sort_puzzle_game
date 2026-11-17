import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Burst of small 4-point stars expanding from [origin]; [t] in 0..1.
class SparklePainter extends CustomPainter {
  SparklePainter({
    required this.t,
    required this.origin,
    required this.color,
    required this.radius,
  });

  final double t;
  final Offset origin;
  final Color color;
  final double radius;

  static Path star(Offset c, double r) {
    final p = Path();
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4 - math.pi / 2;
      final rr = i.isEven ? r : r * 0.32;
      final pt = c + Offset(math.cos(a) * rr, math.sin(a) * rr);
      i == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
    }
    return p..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1) return;
    final fade = 1 - Curves.easeIn.transform(t);
    final dist = Curves.easeOut.transform(t) * radius;
    final paint = Paint()..color = color.withValues(alpha: fade);
    final white = Paint()..color = Colors.white.withValues(alpha: fade);
    for (var i = 0; i < 10; i++) {
      final a = i * 2 * math.pi / 10 + 0.3;
      final c = origin + Offset(math.cos(a), math.sin(a) * 0.8) * dist;
      final r = radius * 0.11 * (i.isEven ? 1 : 0.7) * (1 - t * 0.5);
      canvas.drawPath(star(c, r), i.isEven ? paint : white);
    }
  }

  @override
  bool shouldRepaint(SparklePainter old) => old.t != t || old.origin != origin;
}
