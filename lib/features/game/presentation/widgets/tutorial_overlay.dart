import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/progress_repository.dart';
import '../../domain/models/level_config.dart';
import '../../domain/services/game_rules_service.dart';
import '../../domain/services/puzzle_solver_service.dart';
import '../controllers/game_controller.dart';
import 'board_layout.dart';

/// Dims everything except [holes].
class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter(this.holes, {this.opacity = 0.32});
  final List<RRect> holes;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    var path = Path()..addRect(Offset.zero & size);
    for (final h in holes) {
      path = Path.combine(PathOperation.difference, path, Path()..addRRect(h));
    }
    canvas.drawPath(path, Paint()..color = Colors.black.withValues(alpha: opacity));
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AppColors.lavender.withValues(alpha: 0.8);
    for (final h in holes) {
      canvas.drawRRect(h, ring);
    }
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) => old.holes != holes || old.opacity != opacity;
}

/// Animated dashed arc with an arrowhead from [a] to [b].
class _ArrowPainter extends CustomPainter {
  _ArrowPainter(this.a, this.b, this.phase);
  final Offset a;
  final Offset b;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final mid = Offset((a.dx + b.dx) / 2, math.min(a.dy, b.dy) - (b - a).distance * 0.35 - 20);
    final path = Path()
      ..moveTo(a.dx, a.dy)
      ..quadraticBezierTo(mid.dx, mid.dy, b.dx, b.dy);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..color = Colors.white;
    for (final m in path.computeMetrics()) {
      const dash = 10.0, gap = 8.0;
      var d = -phase * (dash + gap);
      while (d < m.length - 14) {
        final s = math.max(0.0, d);
        final e = math.min(m.length - 14, d + dash);
        if (e > s) canvas.drawPath(m.extractPath(s, e), paint);
        d += dash + gap;
      }
      final tan = m.getTangentForOffset(m.length)!;
      final dir = tan.vector / tan.vector.distance;
      final normal = Offset(-dir.dy, dir.dx);
      final tip = tan.position;
      canvas.drawPath(
        Path()
          ..moveTo(tip.dx, tip.dy)
          ..lineTo((tip - dir * 16 + normal * 9).dx, (tip - dir * 16 + normal * 9).dy)
          ..lineTo((tip - dir * 16 - normal * 9).dx, (tip - dir * 16 - normal * 9).dy)
          ..close(),
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(_ArrowPainter old) => old.phase != phase || old.a != a || old.b != b;
}

class _Hand extends StatelessWidget {
  const _Hand({required this.bob});
  final double bob;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, bob * 10),
      child: Transform.scale(
        scale: 1 - bob * 0.08,
        child: const Icon(
          Icons.touch_app_rounded,
          size: 54,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 3))],
        ),
      ),
    );
  }
}

class _Caption extends StatelessWidget {
  const _Caption(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.panelDark.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.panelBorder, width: 1.5),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 12)],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: Colors.white70,
        backgroundColor: Colors.black26,
        shape: const StadiumBorder(),
      ),
      child: const Text('Skip tutorial'),
    );
  }
}

/// Board-level guided tutorial for levels 1 (basic move) and 2 (same color).
/// Non-blocking: taps pass through to the tubes.
class BoardTutorialOverlay extends ConsumerStatefulWidget {
  const BoardTutorialOverlay({super.key, required this.layout});
  final BoardLayout layout;

  @override
  ConsumerState<BoardTutorialOverlay> createState() => _BoardTutorialOverlayState();
}

class _BoardTutorialOverlayState extends ConsumerState<BoardTutorialOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(gameControllerProvider);
    final type = s?.level.tutorial;
    final done = ref.watch(progressProvider.select((p) => type != null && p.tutorialCompleted(type.name)));
    if (s == null ||
        done ||
        s.isLevelCompleted ||
        (type != TutorialType.basicMove && type != TutorialType.sameColor)) {
      return const SizedBox.shrink();
    }
    final l = widget.layout;
    if (l.columns.length < s.tubes.length) return const SizedBox.shrink();
    const rules = GameRulesService();
    final raw = GameRulesService.toRaw(s.tubes);
    final hint = const PuzzleSolverService().nextHint(raw, s.level.tubeCapacity, nodeLimit: 2000);
    final selected = s.selectedTubeIndex;

    int? target;
    String text;
    if (selected == null) {
      target = hint?.from ?? s.tubes.indexWhere((t) => t.balls.isNotEmpty);
      text = 'Tap to Select Ball';
    } else {
      target = (hint != null && hint.from == selected)
          ? hint.to
          : List.generate(s.tubes.length, (i) => i).cast<int?>().firstWhere(
                (i) => rules.canMove(s.tubes, selected, i!),
                orElse: () => null,
              );
      text = type == TutorialType.sameColor
          ? 'Only balls of the same color can be stacked together.'
          : 'Tap another tube to move the ball';
    }
    if (type == TutorialType.sameColor && selected == null && s.moveCount == 0) {
      text = 'Tap to Select Ball\nOnly matching colors can stack!';
    }

    RRect hole(int i) => RRect.fromRectAndRadius(l.columns[i].inflate(4), const Radius.circular(18));
    final holes = <RRect>[
      if (selected != null) hole(selected),
      if (target != null && target >= 0 && target != selected) hole(target),
    ];
    void skip() => ref.read(progressProvider.notifier).completeTutorial(type!.name);

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final bob = Curves.easeInOut.transform(_anim.value);
        final children = <Widget>[
          Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _SpotlightPainter(holes)))),
        ];
        if (target != null && target >= 0) {
          final col = l.columns[target];
          if (selected != null && selected != target) {
            children.add(Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _ArrowPainter(
                    l.liftedCenter(selected) - Offset(0, l.unit * 0.7),
                    Offset(col.center.dx, col.top + l.liftSpace * 0.4),
                    _anim.value,
                  ),
                ),
              ),
            ));
          }
          children.add(Positioned(
            left: col.center.dx - 18,
            top: col.top + l.liftSpace + l.tubeHeight * 0.45,
            child: IgnorePointer(child: _Hand(bob: bob)),
          ));
        }
        if (type == TutorialType.sameColor && selected != null) {
          for (var i = 0; i < s.tubes.length; i++) {
            if (i == selected) continue;
            final ok = rules.canMove(s.tubes, selected, i);
            final col = l.columns[i];
            children.add(Positioned(
              left: col.center.dx - 15,
              top: col.top + l.liftSpace * 0.15,
              child: IgnorePointer(
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ok ? AppColors.success : AppColors.danger,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(ok ? Icons.check_rounded : Icons.close_rounded, color: Colors.white, size: 20),
                ),
              ),
            ));
          }
        }
        final topY = l.columns.map((c) => c.top).reduce(math.min);
        children.add(Positioned(
          left: 16,
          right: 16,
          top: math.max(0, topY - 64),
          child: IgnorePointer(child: Center(child: _Caption(text))),
        ));
        children.add(Positioned(right: 8, bottom: 0, child: _SkipButton(onTap: skip)));
        return Stack(clipBehavior: Clip.none, children: children);
      },
    );
  }
}

/// Screen-level tutorial for level 3: spotlights each power-up button in turn.
class PowerUpTutorialOverlay extends ConsumerStatefulWidget {
  const PowerUpTutorialOverlay({super.key, required this.buttonKeys});

  final Map<PowerUpType, GlobalKey> buttonKeys;

  @override
  ConsumerState<PowerUpTutorialOverlay> createState() => _PowerUpTutorialOverlayState();
}

class _PowerUpTutorialOverlayState extends ConsumerState<PowerUpTutorialOverlay> {
  static const _steps = [
    (PowerUpType.undo, 'Undo', 'Take back your last move.'),
    (PowerUpType.shuffle, 'Shuffle', 'Remix the balls into a new, still-solvable puzzle.'),
    (PowerUpType.addTube, 'Add Tube', 'Get an extra empty tube for this level.'),
  ];
  int _step = 0;
  Rect? _rect;

  void _measure() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final key = widget.buttonKeys[_steps[_step].$1];
      final box = key?.currentContext?.findRenderObject() as RenderBox?;
      final me = context.findRenderObject() as RenderBox?;
      if (box == null || me == null || !box.hasSize || !me.hasSize) return;
      final r = box.localToGlobal(Offset.zero, ancestor: me) & box.size;
      if (r != _rect) setState(() => _rect = r);
    });
  }

  void _finish() =>
      ref.read(progressProvider.notifier).completeTutorial(TutorialType.powerUps.name);

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(gameControllerProvider);
    final done = ref.watch(progressProvider.select((p) => p.tutorialCompleted(TutorialType.powerUps.name)));
    if (s == null || done || s.level.tutorial != TutorialType.powerUps || s.isLevelCompleted) {
      return const SizedBox.shrink();
    }
    _measure();
    final step = _steps[_step];
    final rect = _rect;
    final last = _step == _steps.length - 1;
    return LayoutBuilder(builder: (context, c) {
      return Stack(children: [
        // Modal: blocks gameplay taps while the tooltips are shown.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            child: CustomPaint(
              painter: _SpotlightPainter(
                rect == null ? const [] : [RRect.fromRectAndRadius(rect.inflate(8), const Radius.circular(22))],
                opacity: 0.65,
              ),
            ),
          ),
        ),
        if (rect != null)
          Positioned(
            left: 24,
            right: 24,
            bottom: c.maxHeight - rect.top + 22,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                decoration: BoxDecoration(
                  color: AppColors.panelDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.panelBorder, width: 1.5),
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(step.$2.toUpperCase(),
                      style: const TextStyle(
                          color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  const SizedBox(height: 6),
                  Text(step.$3,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('${_step + 1} / ${_steps.length}', style: const TextStyle(color: Colors.white54)),
                  const SizedBox(height: 6),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    TextButton(
                      onPressed: _finish,
                      child: const Text('Skip', style: TextStyle(color: Colors.white60)),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: AppColors.buttonBottom),
                      onPressed: () => last ? _finish() : setState(() => _step++),
                      child: Text(last ? 'Got it!' : 'Next'),
                    ),
                  ]),
                ]),
              ),
              Icon(Icons.arrow_drop_down_rounded, size: 44, color: AppColors.panelBorder),
            ]),
          ),
      ]);
    });
  }
}
