import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Paints a polished, glossy 3D sphere filling the given square.
class GlossyBallPainter extends CustomPainter {
  GlossyBallPainter(this.spec, {this.glow = 0});

  final BallColorSpec spec;

  /// 0..1 selection glow around the ball.
  final double glow;

  @override
  void paint(Canvas canvas, Size size) {
    final d = size.shortestSide;
    final r = d / 2;
    final c = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: c, radius: r);

    if (glow > 0) {
      canvas.drawCircle(
        c,
        r * (1.0 + 0.18 * glow),
        Paint()
          ..color = spec.highlight.withValues(alpha: 0.55 * glow)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.35),
      );
    }

    // Soft contact shadow (lower right).
    canvas.drawCircle(
      c + Offset(r * 0.06, r * 0.1),
      r * 0.98,
      Paint()..color = const Color(0x55000000),
    );

    // Body: radial gradient lit from the upper left.
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.45),
          radius: 1.05,
          colors: [spec.highlight, spec.primary, spec.shadow],
          stops: const [0.0, 0.48, 1.0],
        ).createShader(rect),
    );

    // Edge darkening for depth.
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0x00000000),
            spec.shadow.withValues(alpha: 0.55),
          ],
          stops: const [0.72, 1.0],
        ).createShader(rect),
    );

    // Inner glow / bounce light along the lower-right rim.
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r * 0.82),
      0.15,
      1.3,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.12
        ..strokeCap = StrokeCap.round
        ..color = spec.highlight.withValues(alpha: 0.35),
    );

    // Main specular highlight (upper left).
    final hl = Rect.fromCenter(
      center: c + Offset(-r * 0.33, -r * 0.42),
      width: r * 0.78,
      height: r * 0.5,
    );
    canvas.save();
    canvas.translate(hl.center.dx, hl.center.dy);
    canvas.rotate(-0.55);
    canvas.translate(-hl.center.dx, -hl.center.dy);
    canvas.drawOval(
      hl,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xF2FFFFFF), Color(0x00FFFFFF)],
        ).createShader(hl),
    );
    canvas.restore();

    // Tiny sharp specular dot.
    canvas.drawCircle(
      c + Offset(-r * 0.42, -r * 0.48),
      r * 0.09,
      Paint()..color = const Color(0xE6FFFFFF),
    );

    // Secondary reflection (lower right).
    canvas.drawCircle(
      c + Offset(r * 0.4, r * 0.45),
      r * 0.1,
      Paint()..color = Colors.white.withValues(alpha: 0.3),
    );
  }

  @override
  bool shouldRepaint(GlossyBallPainter old) =>
      old.spec != spec || old.glow != glow;
}

class GlossyBallWidget extends StatelessWidget {
  const GlossyBallWidget({
    super.key,
    required this.colorId,
    required this.diameter,
    this.glow = 0,
  });

  final int colorId;
  final double diameter;
  final double glow;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: diameter,
      child: CustomPaint(
        painter: GlossyBallPainter(AppColors.ball(colorId), glow: glow),
      ),
    );
  }
}

/// Dark glass sphere with a "?" for hidden (mystery) balls.
class MysteryBallPainter extends CustomPainter {
  const MysteryBallPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide / 2;
    final c = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.35, -0.45),
          colors: [Color(0xFF5A5480), Color(0xFF26214A), Color(0xFF110D2A)],
          stops: [0.0, 0.55, 1.0],
        ).createShader(rect),
    );
    canvas.drawCircle(
      c,
      r * 0.96,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.07
        ..color = const Color(0x66C9C2FF),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: c + Offset(-r * 0.32, -r * 0.45),
        width: r * 0.7,
        height: r * 0.38,
      ),
      Paint()..color = const Color(0x40FFFFFF),
    );
    final tp = TextPainter(
      text: TextSpan(
        text: '?',
        style: TextStyle(
          color: Colors.white,
          fontSize: r * 1.15,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(MysteryBallPainter oldDelegate) => false;
}

class MysteryBallWidget extends StatelessWidget {
  const MysteryBallWidget({super.key, required this.diameter});
  final double diameter;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: diameter,
    child: const CustomPaint(painter: MysteryBallPainter()),
  );
}
