import 'package:flutter/material.dart';

import '../../../../app/game_palette.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../shared/widgets/game_popup.dart';
import '../../../../shared/widgets/glossy_button.dart';

TextStyle _body(BuildContext context) => TextStyle(
  color: context.palette.textMuted,
  fontSize: 16,
  fontWeight: FontWeight.w600,
);

/// Restart confirmation. Returns true when the player confirms.
Future<bool> confirmRestart(BuildContext context) async {
  final r = await showGamePopup<bool>(
    context,
    dismissible: true,
    builder: (ctx) => GamePanel(
      title: ctx.l10n.restartTitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            ctx.l10n.restartBody,
            textAlign: TextAlign.center,
            style: _body(ctx),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: PillButton(
                  label: ctx.l10n.cancel,
                  colors: PillButton.purple,
                  fontSize: 16,
                  height: 48,
                  onTap: () => Navigator.of(ctx).pop(false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PillButton(
                  label: ctx.l10n.restart,
                  colors: PillButton.red,
                  fontSize: 16,
                  height: 48,
                  onTap: () => Navigator.of(ctx).pop(true),
                ),
              ),
            ],
          ),
        ],
      ),
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
}) => showGamePopup<StuckAction>(
  context,
  dismissible: true,
  builder: (ctx) {
    void pop(StuckAction a) => Navigator.of(ctx).pop(a);
    final l10n = ctx.l10n;
    return GamePanel(
      title: l10n.noMovesTitle,
      onClose: () => pop(StuckAction.dismiss),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.noMovesBody,
            textAlign: TextAlign.center,
            style: _body(ctx),
          ),
          const SizedBox(height: 18),
          if (canUndo) ...[
            PillButton(
              label: l10n.undo,
              icon: Icons.undo_rounded,
              colors: PillButton.purple,
              onTap: () => pop(StuckAction.undo),
            ),
            const SizedBox(height: 10),
          ],
          if (canAddTube) ...[
            PillButton(
              label: l10n.addTube,
              icon: Icons.add_rounded,
              colors: PillButton.purple,
              onTap: () => pop(StuckAction.addTube),
            ),
            const SizedBox(height: 10),
          ],
          if (canShuffle) ...[
            PillButton(
              label: l10n.shuffle,
              icon: Icons.shuffle_rounded,
              colors: PillButton.purple,
              onTap: () => pop(StuckAction.shuffle),
            ),
            const SizedBox(height: 10),
          ],
          PillButton(
            label: l10n.restart,
            icon: Icons.replay_rounded,
            colors: PillButton.red,
            onTap: () => pop(StuckAction.restart),
          ),
        ],
      ),
    );
  },
);

enum TimeUpAction { retry, home }

Future<TimeUpAction?> showTimeUpPopup(BuildContext context) =>
    showGamePopup<TimeUpAction>(
      context,
      builder: (ctx) => GamePanel(
        title: ctx.l10n.timeUpTitle,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer_off_rounded,
              size: 64,
              color: ctx.palette.highlight,
            ),
            const SizedBox(height: 8),
            Text(
              ctx.l10n.timeUpBody,
              textAlign: TextAlign.center,
              style: _body(ctx),
            ),
            const SizedBox(height: 18),
            PillButton(
              label: ctx.l10n.retry,
              icon: Icons.replay_rounded,
              onTap: () => Navigator.of(ctx).pop(TimeUpAction.retry),
            ),
            const SizedBox(height: 10),
            PillButton(
              label: ctx.l10n.homeButton,
              icon: Icons.home_rounded,
              colors: PillButton.purple,
              onTap: () => Navigator.of(ctx).pop(TimeUpAction.home),
            ),
          ],
        ),
      ),
    );

/// Intro shown when a special (tall-tube) level starts.
Future<void> showSpecialLevelPopup(
  BuildContext context, {
  required int capacity,
  required int colors,
  required bool mystery,
}) => showGamePopup<void>(
  context,
  dismissible: true,
  builder: (ctx) => GamePanel(
    title: ctx.l10n.specialLevelTitle,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.auto_awesome_rounded,
          size: 56,
          color: ctx.palette.highlight,
        ),
        const SizedBox(height: 8),
        Text(
          mystery
              ? ctx.l10n.specialLevelBodyMystery(capacity, colors)
              : ctx.l10n.specialLevelBody(capacity, colors),
          textAlign: TextAlign.center,
          style: _body(ctx),
        ),
        const SizedBox(height: 18),
        PillButton(
          label: ctx.l10n.play,
          icon: Icons.play_arrow_rounded,
          onTap: () => Navigator.of(ctx).pop(),
        ),
      ],
    ),
  ),
);
