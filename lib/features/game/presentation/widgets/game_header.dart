import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/game_palette.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../shared/widgets/glossy_button.dart';
import '../../domain/models/level_config.dart';
import '../controllers/game_controller.dart';

class GameHeader extends ConsumerWidget {
  const GameHeader({
    super.key,
    required this.onRestart,
    required this.onSettings,
    required this.buttonSize,
  });

  final VoidCallback onRestart;
  final VoidCallback onSettings;
  final double buttonSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Granular selects: the header only rebuilds when these values change.
    final levelId = ref.watch(
      gameControllerProvider.select((s) => s?.currentLevel ?? 0),
    );
    final difficulty = ref.watch(
      gameControllerProvider.select((s) => s?.level.difficulty),
    );
    final mystery = ref.watch(
      gameControllerProvider.select((s) => s?.level.mystery ?? false),
    );
    final special = ref.watch(
      gameControllerProvider.select((s) => s?.level.isSpecial ?? false),
    );
    final l10n = context.l10n;
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          GlossyIconButton(
            icon: Icons.replay_rounded,
            size: buttonSize,
            semanticLabel: l10n.restartLevel,
            onTap: onRestart,
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: LevelIndicator(levelId: levelId),
                ),
                const SizedBox(height: 6),
                // Wraps onto a second line on narrow screens or with long
                // translations instead of overflowing.
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: 2,
                  children: [
                    if (difficulty != null)
                      Text(
                        l10n.difficulty(difficulty).toUpperCase(),
                        style: TextStyle(
                          color: palette.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    if (special) ...[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 13,
                        color: palette.highlight,
                      ),
                    ],
                    if (mystery) ...[
                      const SizedBox(width: 6),
                      Text(
                        '?',
                        style: TextStyle(
                          color: palette.text,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                    const SizedBox(width: 10),
                    const _MoveCounter(),
                    const _TimerChip(),
                  ],
                ),
              ],
            ),
          ),
          GlossyIconButton(
            icon: Icons.settings_rounded,
            size: buttonSize,
            semanticLabel: l10n.settingsLabel,
            onTap: onSettings,
          ),
        ],
      ),
    );
  }
}

class LevelIndicator extends StatelessWidget {
  const LevelIndicator({super.key, required this.levelId});
  final int levelId;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
      decoration: BoxDecoration(
        color: palette.panel.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: palette.accent.withValues(alpha: 0.7),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: palette.accent.withValues(alpha: 0.3),
            blurRadius: 16,
          ),
        ],
      ),
      child: Text(
        context.l10n.levelHeader(levelId),
        style: TextStyle(
          color: palette.text,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class _MoveCounter extends ConsumerWidget {
  const _MoveCounter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moves = ref.watch(
      gameControllerProvider.select((s) => s?.moveCount ?? 0),
    );
    final target = ref.watch(
      gameControllerProvider.select((s) => s?.level.moveTarget),
    );
    final over = target != null && moves > target;
    final l10n = context.l10n;
    return Text(
      target == null
          ? l10n.movesCounter(moves)
          : l10n.movesCounterTarget(moves, target),
      style: TextStyle(
        color: over ? AppColors.danger : context.palette.textMuted,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1,
      ),
    );
  }
}

class _TimerChip extends ConsumerWidget {
  const _TimerChip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final secs = ref.watch(
      gameControllerProvider.select((s) => s?.remainingSeconds),
    );
    if (secs == null) return const SizedBox.shrink();
    final low = secs <= 15;
    final normal = context.palette.highlight;
    final text = '${secs ~/ 60}:${(secs % 60).toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_rounded,
            size: 14,
            color: low ? AppColors.danger : normal,
          ),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              color: low ? AppColors.danger : normal,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small descriptor shown once when a level introduces a mechanic.
class MechanicBanner extends ConsumerWidget {
  const MechanicBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mechanic = ref.watch(
      gameControllerProvider.select(
        (s) =>
            s != null &&
                s.moveCount == 0 &&
                s.level.tutorial == TutorialType.none
            ? s.level.newMechanic
            : null,
      ),
    );
    final text = mechanic == null ? null : context.l10n.mechanic(mechanic);
    final highlight = context.palette.highlight;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, a) => FadeTransition(
        opacity: a,
        child: SizeTransition(sizeFactor: a, child: child),
      ),
      child: text == null
          ? const SizedBox(height: 0)
          : Container(
              key: ValueKey(text),
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: highlight.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: highlight.withValues(alpha: 0.6)),
              ),
              child: Text(
                context.l10n.newMechanic(text),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: highlight,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
    );
  }
}
