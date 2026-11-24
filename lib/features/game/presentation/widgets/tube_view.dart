import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/game_palette.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/game_constants.dart';
import '../../../../shared/animations/sparkle_painter.dart';
import '../../domain/models/tube.dart';
import 'board_layout.dart';
import 'glass_tube_widget.dart';
import 'glossy_ball_widget.dart';

/// One tube column: glass, stacked balls, lifted selection, shake, pop-in
/// (shuffle/undo), entrance (add tube) and completion sparkle animations.
class TubeView extends StatefulWidget {
  const TubeView({
    super.key,
    required this.tube,
    required this.layout,
    required this.onTap,
    this.selected = false,
    this.hiddenBallId,
    this.hiddenBallIds = const {},
    this.shakeSeq = 0,
    this.popSeq = 0,
    this.celebrateSeq = 0,
    this.animateEntrance = false,
    this.completeColorId,
    this.hiddenIds = const {},
  });

  final Tube tube;
  final BoardLayout layout;
  final VoidCallback onTap;
  final bool selected;

  /// Ball that is currently in flight towards this tube (not drawn yet).
  final int? hiddenBallId;
  final Set<int> hiddenBallIds;
  final int shakeSeq;
  final int popSeq;
  final int celebrateSeq;
  final bool animateEntrance;

  /// Color of a completed tube (draws a soft glow), or null.
  final int? completeColorId;

  /// Mystery balls in this tube that are still drawn as "?".
  final Set<int> hiddenIds;

  @override
  State<TubeView> createState() => _TubeViewState();
}

class _TubeViewState extends State<TubeView> with TickerProviderStateMixin {
  late final AnimationController _lift;
  late final AnimationController _shake;
  late final AnimationController _pop;
  late final AnimationController _enter;
  late final AnimationController _sparkle;

  @override
  void initState() {
    super.initState();
    _lift = AnimationController(
      vsync: this,
      duration: GameConstants.liftAnimation,
      value: widget.selected ? 1 : 0,
    );
    _shake = AnimationController(
      vsync: this,
      duration: GameConstants.shakeAnimation,
      value: 1,
    );
    _pop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
      value: 1,
    );
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
      value: 1,
    );
    _sparkle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      value: 1,
    );
    if (widget.animateEntrance) _enter.forward(from: 0);
    if (widget.popSeq != 0) _pop.forward(from: 0);
  }

  @override
  void didUpdateWidget(TubeView old) {
    super.didUpdateWidget(old);
    if (widget.selected != old.selected) {
      if (widget.selected) {
        _lift.forward();
      } else if (old.tube.topBall?.id != widget.tube.topBall?.id) {
        _lift.value = 0; // the lifted ball left in flight: no drop-back
      } else {
        _lift.reverse();
      }
    }
    if (widget.shakeSeq != old.shakeSeq) _shake.forward(from: 0);
    if (widget.popSeq != old.popSeq) _pop.forward(from: 0);
    if (widget.celebrateSeq != old.celebrateSeq) _sparkle.forward(from: 0);
  }

  @override
  void dispose() {
    _lift.dispose();
    _shake.dispose();
    _pop.dispose();
    _enter.dispose();
    _sparkle.dispose();
    super.dispose();
  }

  double _popScale(int slot) {
    if (_pop.value >= 1) return 1;
    final local = ((_pop.value - slot * 0.08) / 0.6).clamp(0.0, 1.0);
    return Curves.easeOutBack.transform(local);
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.layout;
    final u = l.unit;
    final tubeRect = l.tubeRectInColumn;
    final glow = widget.completeColorId == null
        ? null
        : AppColors.ball(widget.completeColorId!).highlight;
    final palette = context.palette;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_shake, _enter]),
        builder: (context, child) {
          final s = _shake.value;
          final dx = s >= 1
              ? 0.0
              : math.sin(s * math.pi * 6) * (1 - s) * u * 0.22;
          final e = Curves.easeOutBack.transform(_enter.value);
          return Opacity(
            opacity: _enter.value.clamp(0.0, 1.0),
            child: Transform(
              alignment: Alignment.bottomCenter,
              transform: Matrix4.translationValues(dx, (1 - e) * u, 0)
                ..multiply(
                  Matrix4.diagonal3Values(0.6 + 0.4 * e, 0.6 + 0.4 * e, 1),
                ),
              child: child,
            ),
          );
        },
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: Listenable.merge([_lift, _pop, _sparkle]),
            builder: (context, _) {
              final balls = widget.tube.balls;
              final liftT = Curves.easeOut.transform(_lift.value);
              final topLifted = liftT > 0 && balls.isNotEmpty;
              final children = <Widget>[
                Positioned.fromRect(
                  rect: tubeRect,
                  child: CustomPaint(
                    painter: GlassTubeBackPainter(
                      selected: widget.selected,
                      glowColor: glow,
                      palette: palette,
                    ),
                  ),
                ),
              ];
              Widget? lifted;
              for (var i = 0; i < balls.length; i++) {
                final b = balls[i];
                if (b.id == widget.hiddenBallId ||
                    widget.hiddenBallIds.contains(b.id))
                  continue;
                var c = l.slotCenterInColumn(i);
                final isTop = i == balls.length - 1;
                if (isTop && topLifted) {
                  c = Offset.lerp(c, l.liftedCenterInColumn, liftT)!;
                }
                final scale = _popScale(i);
                final ball = Positioned(
                  key: ValueKey(b.id),
                  left: c.dx - u / 2,
                  top: c.dy - u / 2,
                  width: u,
                  height: u,
                  child: Transform.scale(
                    scale: scale,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 320),
                      // Reveal: the "?" ball flips over into the real color.
                      transitionBuilder: (child, anim) => AnimatedBuilder(
                        animation: anim,
                        child: child,
                        builder: (context, child) => Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.diagonal3Values(
                            Curves.easeOutBack.transform(anim.value),
                            1,
                            1,
                          ),
                          child: child,
                        ),
                      ),
                      child: widget.hiddenIds.contains(b.id)
                          ? MysteryBallWidget(
                              key: const ValueKey('hidden'),
                              diameter: u,
                            )
                          : GlossyBallWidget(
                              key: const ValueKey('shown'),
                              colorId: b.colorId,
                              diameter: u,
                              glow: isTop && topLifted ? liftT : 0,
                            ),
                    ),
                  ),
                );
                if (isTop && topLifted) {
                  lifted = ball;
                } else {
                  children.add(ball);
                }
              }
              children.add(
                Positioned.fromRect(
                  rect: tubeRect,
                  child: CustomPaint(
                    painter: GlassTubeFrontPainter(
                      selected: widget.selected,
                      glowColor: glow,
                      palette: palette,
                    ),
                  ),
                ),
              );
              if (lifted != null) children.add(lifted);
              if (_sparkle.value < 1) {
                children.add(
                  Positioned.fill(
                    child: CustomPaint(
                      painter: SparklePainter(
                        t: _sparkle.value,
                        origin: Offset(l.columnWidth / 2, l.liftSpace),
                        color: glow ?? AppColors.gold,
                        radius: u * 1.4,
                      ),
                    ),
                  ),
                );
              }
              return Stack(clipBehavior: Clip.none, children: children);
            },
          ),
        ),
      ),
    );
  }
}
