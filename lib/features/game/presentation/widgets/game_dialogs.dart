import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/game_popup.dart';
import '../../../../shared/widgets/glossy_button.dart';

const _body = TextStyle(color: AppColors.textMuted, fontSize: 16, fontWeight: FontWeight.w600);

/// Restart confirmation. Returns true when the player confirms.
Future<bool> confirmRestart(BuildContext context) async {
  final r = await showGamePopup<bool>(
    context,
    dismissible: true,
    builder: (ctx) => GamePanel(
      title: 'RESTART?',
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Start this level over?\nYour unlocked levels are kept.', textAlign: TextAlign.center, style: _body),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(
            child: PillButton(
              label: 'CANCEL',
              colors: PillButton.purple,
              fontSize: 16,
              height: 48,
              onTap: () => Navigator.of(ctx).pop(false),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PillButton(
              label: 'RESTART',
              colors: PillButton.red,
              fontSize: 16,
              height: 48,
              onTap: () => Navigator.of(ctx).pop(true),
            ),
          ),
        ]),
      ]),
    ),
  );
  return r ?? false;
}

enum StuckAction { undo, shuffle, addTube, restart, dismiss }

Future<StuckAction?> showStuckPopup(
  BuildContext context, {
  required bool canUndo,
  required bool canShuffle,
  required bool canAddTube,
}) =>
    showGamePopup<StuckAction>(
      context,
      dismissible: true,
      builder: (ctx) {
        void pop(StuckAction a) => Navigator.of(ctx).pop(a);
        return GamePanel(
          title: 'NO MOVES LEFT',
          onClose: () => pop(StuckAction.dismiss),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('There are no legal moves. Try a power-up or restart.', textAlign: TextAlign.center, style: _body),
            const SizedBox(height: 18),
            if (canUndo) ...[
              PillButton(label: 'UNDO', icon: Icons.undo_rounded, colors: PillButton.purple, onTap: () => pop(StuckAction.undo)),
              const SizedBox(height: 10),
            ],
            if (canAddTube) ...[
              PillButton(label: 'ADD TUBE', icon: Icons.add_rounded, colors: PillButton.purple, onTap: () => pop(StuckAction.addTube)),
              const SizedBox(height: 10),
            ],
            if (canShuffle) ...[
              PillButton(label: 'SHUFFLE', icon: Icons.shuffle_rounded, colors: PillButton.purple, onTap: () => pop(StuckAction.shuffle)),
              const SizedBox(height: 10),
            ],
            PillButton(label: 'RESTART', icon: Icons.replay_rounded, colors: PillButton.red, onTap: () => pop(StuckAction.restart)),
          ]),
        );
      },
    );

enum TimeUpAction { retry, home }

Future<TimeUpAction?> showTimeUpPopup(BuildContext context) => showGamePopup<TimeUpAction>(
      context,
      builder: (ctx) => GamePanel(
        title: "TIME'S UP!",
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.timer_off_rounded, size: 64, color: AppColors.gold),
          const SizedBox(height: 8),
          const Text('The clock ran out. Give it another go!', textAlign: TextAlign.center, style: _body),
          const SizedBox(height: 18),
          PillButton(label: 'RETRY', icon: Icons.replay_rounded, onTap: () => Navigator.of(ctx).pop(TimeUpAction.retry)),
          const SizedBox(height: 10),
          PillButton(
            label: 'HOME',
            icon: Icons.home_rounded,
            colors: PillButton.purple,
            onTap: () => Navigator.of(ctx).pop(TimeUpAction.home),
          ),
        ]),
      ),
    );

/// Intro shown when a special (tall-tube) level starts.
Future<void> showSpecialLevelPopup(BuildContext context, {required int capacity, required int colors, required bool mystery}) =>
    showGamePopup<void>(
      context,
      dismissible: true,
      builder: (ctx) => GamePanel(
        title: 'SPECIAL LEVEL',
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.auto_awesome_rounded, size: 56, color: AppColors.gold),
          const SizedBox(height: 8),
          Text(
            'Taller tubes hold $capacity balls each.\nSort $colors colors'
            '${mystery ? ' - and watch out for mystery balls!' : '.'}',
            textAlign: TextAlign.center,
            style: _body,
          ),
          const SizedBox(height: 18),
          PillButton(label: 'PLAY', icon: Icons.play_arrow_rounded, onTap: () => Navigator.of(ctx).pop()),
        ]),
      ),
    );
