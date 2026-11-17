import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Tube outline: straight sides, rounded top corners, semicircular bottom.
Path tubePath(Size size) {
  final w = size.width;
  final h = size.height;
  final r = w / 2;
  final top = w * 0.08;
  return Path()
    ..moveTo(0, top)
    ..quadraticBezierTo(0, 0, top, 0)
    ..lineTo(w - top, 0)
    ..quadraticBezierTo(w, 0, w, top)
    ..lineTo(w, h - r)
    ..arcToPoint(Offset(0, h - r), radius: Radius.circular(r))
    ..close();
}

/// Back layer of the glass (drawn behind the balls).
class GlassTubeBackPainter extends CustomPainter {
  GlassTubeBackPainter({this.selected = false, this.glowColor});

  final bool selected;

  /// When set, the tube glows in this color (completed tube).
  final Color? glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final path = tubePath(size);
    final stroke = (size.width * 0.06).clamp(1.2, 3.5);

    if (glowColor != null || selected) {
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke * 4
          ..color = (glowColor ?? AppColors.tubeSelected).withValues(
            alpha: 0.35,
          )
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, stroke * 3),
      );
    }

    // Faint drop shadow under the tube.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height + stroke * 1.5),
        width: size.width * 0.9,
        height: size.width * 0.18,
      ),
      Paint()..color = const Color(0x44000000),
    );

    // Glass body: darker edges (inner shadow), transparent middle.
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          colors: [
            AppColors.tubeInnerShadow.withValues(alpha: 0.55),
            const Color(0x0FFFFFFF),
            const Color(0x08FFFFFF),
            AppColors.tubeInnerShadow.withValues(alpha: 0.6),
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(GlassTubeBackPainter old) =>
      old.selected != selected || old.glowColor != glowColor;
}

/// Front layer (outline + reflections), drawn over the balls.
class GlassTubeFrontPainter extends CustomPainter {
  GlassTubeFrontPainter({this.selected = false, this.glowColor});

  final bool selected;
  final Color? glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = tubePath(size);
    final stroke = (w * 0.06).clamp(1.2, 3.5);

    // Vertical reflection strip on the left.
    final strip = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.14, h * 0.06, w * 0.09, h - w * 0.75),
      Radius.circular(w * 0.05),
    );
    canvas.drawRRect(
      strip,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.tubeHighlight.withValues(alpha: 0.55),
            AppColors.tubeHighlight.withValues(alpha: 0.12),
            AppColors.tubeHighlight.withValues(alpha: 0.0),
          ],
        ).createShader(strip.outerRect),
    );
    // Thin secondary reflection on the right.
    canvas.drawLine(
      Offset(w * 0.8, h * 0.1),
      Offset(w * 0.8, h * 0.45),
      Paint()
        ..strokeWidth = w * 0.035
        ..strokeCap = StrokeCap.round
        ..color = AppColors.tubeHighlight.withValues(alpha: 0.18),
    );

    // Outline.
    final outline =
        glowColor ??
        (selected ? AppColors.tubeSelected : AppColors.tubeOutline);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = selected ? stroke * 1.3 : stroke
        ..color = outline.withValues(
          alpha: glowColor != null || selected ? 1 : 0.85,
        ),
    );

    // Lip at the opening.
    final lip = RRect.fromRectAndRadius(
      Rect.fromLTWH(-stroke, -stroke * 0.6, w + stroke * 2, stroke * 2.2),
      Radius.circular(stroke),
    );
    canvas.drawRRect(lip, Paint()..color = outline.withValues(alpha: 0.95));
    canvas.drawRRect(
      lip.deflate(stroke * 0.45),
      Paint()..color = AppColors.tubeHighlight.withValues(alpha: 0.5),
    );
  }

  @override
  bool shouldRepaint(GlassTubeFrontPainter old) =>
      old.selected != selected || old.glowColor != glowColor;
}

/// Standalone glass tube (used on the home screen and in tests). The game
/// board composes the two painters around the balls for correct layering.
class GlassTubeWidget extends StatelessWidget {
  const GlassTubeWidget({
    super.key,
    required this.width,
    required this.height,
    this.selected = false,
    this.glowColor,
    this.child,
  });

  final double width;
  final double height;
  final bool selected;
  final Color? glowColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: GlassTubeBackPainter(selected: selected, glowColor: glowColor),
        foregroundPainter: GlassTubeFrontPainter(
          selected: selected,
          glowColor: glowColor,
        ),
        child: child,
      ),
    );
  }
}
