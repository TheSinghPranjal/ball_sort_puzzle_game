import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glossy_button.dart';
import '../../domain/models/level_config.dart';
import '../controllers/game_controller.dart';

class GameHeader extends ConsumerWidget {
  const GameHeader({super.key, required this.onRestart, required this.onSettings, required this.buttonSize});

  final VoidCallback onRestart;
  final VoidCallback onSettings;
  final double buttonSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Granular selects: the header only rebuilds when these values change.
    final levelId = ref.watch(gameControllerProvider.select((s) => s?.currentLevel ?? 0));
    final difficulty = ref.watch(gameControllerProvider.select((s) => s?.level.difficulty));
    final mystery = ref.watch(gameControllerProvider.select((s) => s?.level.mystery ?? false));
    final special = ref.watch(gameControllerProvider.select((s) => s?.level.isSpecial ?? false));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(children: [
        GlossyIconButton(
          icon: Icons.replay_rounded,
          size: buttonSize,
          semanticLabel: 'Restart level',
          onTap: onRestart,
        ),
        Expanded(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            LevelIndicator(levelId: levelId),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              if (difficulty != null)
                Text(difficulty.label.toUpperCase(),
                    style: const TextStyle(color: AppColors.lavender, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
              if (special) ...[
                const SizedBox(width: 6),
                const Icon(Icons.auto_awesome_rounded, size: 13, color: AppColors.gold),
              ],
              if (mystery) ...[
                const SizedBox(width: 6),
                const Text('?', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
              ],
              const SizedBox(width: 10),
              const _MoveCounter(),
              const _TimerChip(),
            ]),
          ]),
        ),
        GlossyIconButton(
          icon: Icons.settings_rounded,
          size: buttonSize,
          semanticLabel: 'Settings',
          onTap: onSettings,
        ),
      ]),
    );
  }
}

class LevelIndicator extends StatelessWidget {
  const LevelIndicator({super.key, required this.levelId});
  final int levelId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.panel.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lavender.withValues(alpha: 0.7), width: 1.5),
        boxShadow: [BoxShadow(color: AppColors.lavender.withValues(alpha: 0.3), blurRadius: 16)],
      ),
      child: Text(
        'LEVEL $levelId',
        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2),
      ),
    );
  }
}

class _MoveCounter extends ConsumerWidget {
  const _MoveCounter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moves = ref.watch(gameControllerProvider.select((s) => s?.moveCount ?? 0));
    final target = ref.watch(gameControllerProvider.select((s) => s?.level.moveTarget));
    final over = target != null && moves > target;
    return Text(
      target == null ? 'MOVES $moves' : 'MOVES $moves / $target',
      style: TextStyle(
        color: over ? AppColors.danger : AppColors.textMuted,
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
    final secs = ref.watch(gameControllerProvider.select((s) => s?.remainingSeconds));
    if (secs == null) return const SizedBox.shrink();
    final low = secs <= 15;
    final text = '${secs ~/ 60}:${(secs % 60).toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.timer_rounded, size: 14, color: low ? AppColors.danger : AppColors.gold),
        const SizedBox(width: 3),
        Text(text,
            style: TextStyle(
                color: low ? AppColors.danger : AppColors.gold, fontSize: 12, fontWeight: FontWeight.w900)),
      ]),
    );
  }
}

/// Small descriptor shown once when a level introduces a mechanic.
class MechanicBanner extends ConsumerWidget {
  const MechanicBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(gameControllerProvider.select((s) =>
        s != null && s.moveCount == 0 && s.level.tutorial == TutorialType.none ? s.level.newMechanic : null));
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: text == null
          ? const SizedBox(height: 0)
          : Container(
              key: ValueKey(text),
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.6)),
              ),
              child: Text('NEW: $text',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w800)),
            ),
    );
  }
}
