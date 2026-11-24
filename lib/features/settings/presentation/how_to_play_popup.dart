import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/game_palette.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/l10n.dart';
import '../../../shared/widgets/game_popup.dart';
import '../../../shared/widgets/glossy_button.dart';
import '../../game/presentation/widgets/glass_tube_widget.dart';
import '../../game/presentation/widgets/glossy_ball_widget.dart';

Future<void> showHowToPlay(BuildContext context) => showGamePopup<void>(
  context,
  dismissible: true,
  builder: (_) => const HowToPlayPopup(),
);

/// Swipeable, illustrated rules. Each page has a small looping demo built
/// from the same tube and ball widgets the game uses.
class HowToPlayPopup extends StatefulWidget {
  const HowToPlayPopup({super.key});

  @override
  State<HowToPlayPopup> createState() => _HowToPlayPopupState();
}

class _HowToPlayPopupState extends State<HowToPlayPopup> {
  final _pages = PageController();
  int _index = 0;

  static const _count = 5;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _go(int i) => _pages.animateToPage(
    i,
    duration: const Duration(milliseconds: 380),
    curve: Curves.easeOutCubic,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final pages = [
      (const _SortDemo(), l10n.howGoalTitle, l10n.howGoalBody),
      (const _MoveDemo(), l10n.howMoveTitle, l10n.howMoveBody),
      (const _RuleDemo(), l10n.howRuleTitle, l10n.howRuleBody),
      (const _PowerUpDemo(), l10n.howPowerUpsTitle, l10n.howPowerUpsBody),
      (const _StarsDemo(), l10n.howStarsTitle, l10n.howStarsBody),
    ];
    final last = _index == _count - 1;

    return GamePanel(
      title: l10n.howToPlayTitle,
      onClose: () => Navigator.of(context).pop(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 330,
            child: PageView.builder(
              controller: _pages,
              itemCount: _count,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) {
                final (demo, title, body) = pages[i];
                // Neighbouring pages fade and shrink slightly while swiping.
                return AnimatedBuilder(
                  animation: _pages,
                  builder: (context, child) {
                    final page =
                        _pages.hasClients && _pages.position.haveDimensions
                        ? _pages.page ?? _index.toDouble()
                        : _index.toDouble();
                    final d = (page - i).abs().clamp(0.0, 1.0);
                    return Opacity(
                      opacity: 1 - d * 0.6,
                      child: Transform.scale(scale: 1 - d * 0.08, child: child),
                    );
                  },
                  child: Semantics(
                    label: l10n.pageIndicator(i + 1, _count),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 170,
                            child: Center(child: ExcludeSemantics(child: demo)),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: palette.highlight,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            body,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: palette.text,
                              fontSize: 15,
                              height: 1.35,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          _Dots(count: _count, index: _index, onTap: _go),
          const SizedBox(height: 16),
          Row(
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                child: _index == 0
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GlossyIconButton(
                          icon: Icons.arrow_back_rounded,
                          size: 48,
                          semanticLabel: l10n.back,
                          onTap: () => _go(_index - 1),
                        ),
                      ),
              ),
              Expanded(
                child: PillButton(
                  label: last ? l10n.gotIt : l10n.next,
                  icon: last
                      ? Icons.check_rounded
                      : Icons.arrow_forward_rounded,
                  height: 48,
                  fontSize: 17,
                  onTap: () =>
                      last ? Navigator.of(context).pop() : _go(_index + 1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index, required this.onTap});
  final int count;
  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ExcludeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(i),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  width: i == index ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: i == index
                        ? palette.accent
                        : palette.textMuted.withValues(alpha: 0.35),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Demo illustrations
// ---------------------------------------------------------------------------

const double _ball = 26;
const double _tubeW = _ball * 1.32;
const double _tubeH = _ball * 4.6;

/// Bottom-left offset of ball slot [j] inside a tube.
double _slotBottom(int j) => _ball * 0.14 + j * _ball * 1.02;

/// A looping animation that stays still when the OS asks for reduced motion.
mixin _LoopingDemo<T extends StatefulWidget>
    on State<T>, SingleTickerProviderStateMixin<T> {
  late final AnimationController loop;

  Duration get period;

  /// Frame shown when animations are disabled.
  double get restingValue => 1;

  @override
  void initState() {
    super.initState();
    loop = AnimationController(vsync: this, duration: period);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      loop
        ..stop()
        ..value = restingValue;
    } else if (!loop.isAnimating) {
      loop.repeat();
    }
  }

  @override
  void dispose() {
    loop.dispose();
    super.dispose();
  }
}

class _Tube extends StatelessWidget {
  const _Tube(this.colors, {this.glow});
  final List<int> colors;
  final Color? glow;

  @override
  Widget build(BuildContext context) {
    return GlassTubeWidget(
      width: _tubeW,
      height: _tubeH,
      glowColor: glow,
      child: Stack(
        children: [
          for (var j = 0; j < colors.length; j++)
            Positioned(
              left: _ball * 0.16,
              bottom: _slotBottom(j),
              child: GlossyBallWidget(colorId: colors[j], diameter: _ball),
            ),
        ],
      ),
    );
  }
}

/// Page 1: a mixed board settles into sorted, glowing tubes.
class _SortDemo extends StatefulWidget {
  const _SortDemo();

  @override
  State<_SortDemo> createState() => _SortDemoState();
}

class _SortDemoState extends State<_SortDemo>
    with SingleTickerProviderStateMixin, _LoopingDemo {
  @override
  Duration get period => const Duration(milliseconds: 3200);

  static const _mixed = [
    [0, 1, 2, 0],
    [1, 2, 0, 1],
    [2, 0, 1, 2],
  ];
  static const _sorted = [
    [0, 0, 0, 0],
    [1, 1, 1, 1],
    [2, 2, 2, 2],
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: loop,
      builder: (context, _) {
        final sorted = loop.value >= 0.45;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, a) => FadeTransition(
            opacity: a,
            child: ScaleTransition(
              scale: Tween(begin: 0.94, end: 1.0).animate(a),
              child: child,
            ),
          ),
          child: Row(
            key: ValueKey(sorted),
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < 3; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: _Tube(
                    sorted ? _sorted[i] : _mixed[i],
                    glow: sorted ? AppColors.ball(i).highlight : null,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Page 2: tap, lift, arc over and drop into the other tube.
class _MoveDemo extends StatefulWidget {
  const _MoveDemo();

  @override
  State<_MoveDemo> createState() => _MoveDemoState();
}

class _MoveDemoState extends State<_MoveDemo>
    with SingleTickerProviderStateMixin, _LoopingDemo {
  @override
  Duration get period => const Duration(milliseconds: 2800);

  @override
  double get restingValue => 0.15;

  static const _w = 210.0;
  static const _h = 170.0;
  static const _aLeft = 36.0;
  static const _bLeft = _w - 36 - _tubeW;

  Offset _slot(double tubeLeft, int j) =>
      Offset(tubeLeft + _tubeW / 2, _h - _slotBottom(j) - _ball / 2);

  @override
  Widget build(BuildContext context) {
    final start = _slot(_aLeft, 2);
    final end = _slot(_bLeft, 1);
    final upA = Offset(start.dx, _h - _tubeH - _ball * 0.75);
    final upB = Offset(end.dx, upA.dy);
    return SizedBox(
      width: _w,
      height: _h,
      child: AnimatedBuilder(
        animation: loop,
        builder: (context, _) {
          final t = loop.value;
          Offset pos;
          int? tapTube;
          if (t < 0.12) {
            pos = start;
            tapTube = 0;
          } else if (t < 0.3) {
            final k = Curves.easeOutCubic.transform((t - 0.12) / 0.18);
            pos = Offset.lerp(start, upA, k)!;
          } else if (t < 0.42) {
            pos = upA;
            tapTube = 1;
          } else if (t < 0.62) {
            final k = Curves.easeInOutCubic.transform((t - 0.42) / 0.2);
            final mid = Offset((upA.dx + upB.dx) / 2, upA.dy - 26);
            final u = 1 - k;
            pos = upA * (u * u) + mid * (2 * u * k) + upB * (k * k);
          } else if (t < 0.78) {
            final k = Curves.easeInCubic.transform((t - 0.62) / 0.16);
            pos = Offset.lerp(upB, end, k)!;
          } else {
            pos = end;
          }
          final handX = tapTube == 0
              ? _aLeft + _tubeW / 2
              : (tapTube == 1 ? _bLeft + _tubeW / 2 : null);
          return Stack(
            clipBehavior: Clip.none,
            children: [
              const Positioned(left: _aLeft, bottom: 0, child: _Tube([0, 1])),
              const Positioned(left: _bLeft, bottom: 0, child: _Tube([2])),
              Positioned(
                left: pos.dx - _ball / 2,
                top: pos.dy - _ball / 2,
                child: GlossyBallWidget(
                  colorId: 2,
                  diameter: _ball,
                  glow: t > 0.12 && t < 0.78 ? 0.6 : 0,
                ),
              ),
              if (handX != null)
                Positioned(
                  left: handX - 10,
                  top: _h - _tubeH * 0.45,
                  child: const _TapHand(),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _TapHand extends StatelessWidget {
  const _TapHand();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.25, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutBack,
      builder: (context, s, child) => Transform.scale(scale: s, child: child),
      child: Icon(
        Icons.touch_app_rounded,
        size: 40,
        color: context.palette.text,
        shadows: const [Shadow(color: Colors.black38, blurRadius: 6)],
      ),
    );
  }
}

/// Page 3: same color or empty tube is OK, a different color is not.
class _RuleDemo extends StatefulWidget {
  const _RuleDemo();

  @override
  State<_RuleDemo> createState() => _RuleDemoState();
}

class _RuleDemoState extends State<_RuleDemo>
    with SingleTickerProviderStateMixin, _LoopingDemo {
  @override
  Duration get period => const Duration(milliseconds: 1800);

  @override
  double get restingValue => 0;

  @override
  Widget build(BuildContext context) {
    Widget column(List<int> tube, bool ok, int delayIndex) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Badge(ok: ok, delay: delayIndex),
        const SizedBox(height: 8),
        _Tube(tube),
      ],
    );
    final demo = AnimatedBuilder(
      animation: loop,
      builder: (context, child) {
        final bob = math.sin(loop.value * 2 * math.pi) * 4;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.translate(
              offset: Offset(0, bob),
              child: const GlossyBallWidget(
                colorId: 3,
                diameter: _ball,
                glow: 0.6,
              ),
            ),
            const SizedBox(height: 4),
            child!,
          ],
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          column(const [0, 3], true, 0),
          const SizedBox(width: 18),
          column(const [3, 4], false, 1),
          const SizedBox(width: 18),
          column(const [], true, 2),
        ],
      ),
    );
    return FittedBox(fit: BoxFit.scaleDown, child: demo);
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.ok, required this.delay});
  final bool ok;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + delay * 160),
      curve: Interval(delay * 0.25, 1, curve: Curves.easeOutBack),
      builder: (context, v, child) => Transform.scale(scale: v, child: child),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ok ? AppColors.success : AppColors.danger,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Icon(
          ok ? Icons.check_rounded : Icons.close_rounded,
          size: 15,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Page 4: the three power-ups pop in one after another.
class _PowerUpDemo extends StatelessWidget {
  const _PowerUpDemo();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      (Icons.undo_rounded, l10n.undo),
      (Icons.shuffle_rounded, l10n.shuffle),
      (Icons.add_rounded, l10n.addTube),
    ];
    return IgnorePointer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (var i = 0; i < items.length; i++)
            Flexible(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 500 + i * 180),
                curve: Interval(i * 0.3, 1, curve: Curves.easeOutBack),
                builder: (context, v, child) => Opacity(
                  opacity: v.clamp(0, 1),
                  child: Transform.scale(scale: v, child: child),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: GlossyIconButton(
                    icon: items[i].$1,
                    label: items[i].$2,
                    size: 58,
                    onTap: () {},
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Page 5: stars, plus the twists that appear in later levels.
class _StarsDemo extends StatelessWidget {
  const _StarsDemo();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < 3; i++)
              Padding(
                padding: EdgeInsets.only(bottom: i == 1 ? 12 : 0),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 450 + i * 220),
                  curve: Interval(i * 0.3, 1, curve: Curves.elasticOut),
                  builder: (context, v, child) =>
                      Transform.scale(scale: v, child: child),
                  child: Icon(
                    Icons.star_rounded,
                    size: i == 1 ? 64 : 50,
                    color: AppColors.gold,
                    shadows: const [
                      Shadow(color: Color(0x99FFB300), blurRadius: 16),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MysteryBallWidget(diameter: 30),
            const SizedBox(width: 22),
            Icon(Icons.timer_rounded, size: 32, color: palette.highlight),
            const SizedBox(width: 22),
            Icon(
              Icons.auto_awesome_rounded,
              size: 30,
              color: palette.highlight,
            ),
          ],
        ),
      ],
    );
  }
}
