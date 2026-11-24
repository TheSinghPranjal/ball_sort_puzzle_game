import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../shared/audio/audio_service.dart';
import '../../../../shared/widgets/glossy_button.dart';
import '../../domain/models/level_config.dart';
import '../controllers/game_controller.dart';

class PowerUpBar extends ConsumerWidget {
  const PowerUpBar({
    super.key,
    required this.buttonKeys,
    required this.buttonSize,
  });

  final Map<PowerUpType, GlobalKey> buttonKeys;
  final double buttonSize;

  void _feedback(BuildContext context, PowerUpResult r, PowerUpType type) {
    final l10n = context.l10n;
    final msg = switch (r) {
      PowerUpResult.noUsesLeft => switch (type) {
        PowerUpType.undo => l10n.noUndosLeft,
        PowerUpType.shuffle => l10n.noShufflesLeft,
        PowerUpType.addTube => l10n.noTubesLeft,
      },
      PowerUpResult.nothingToUndo => l10n.nothingToUndo,
      _ => null,
    };
    if (msg == null) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final available = ref.watch(
      gameControllerProvider.select(
        (s) => s?.level.availablePowerUps ?? const {},
      ),
    );
    final undo = ref.watch(
      gameControllerProvider.select((s) => s?.undoRemaining ?? 0),
    );
    final hasHistory = ref.watch(
      gameControllerProvider.select(
        (s) => (s?.undoHistory.isNotEmpty) ?? false,
      ),
    );
    final shuffle = ref.watch(
      gameControllerProvider.select((s) => s?.shuffleRemaining ?? 0),
    );
    final add = ref.watch(
      gameControllerProvider.select((s) => s?.addTubeRemaining ?? 0),
    );
    final busy = ref.watch(
      gameControllerProvider.select((s) => s?.isBusy ?? false),
    );
    final solving = ref.watch(autoSolveProvider);
    if (available.isEmpty && !kDebugMode) return const SizedBox.shrink();
    final c = ref.read(gameControllerProvider.notifier);
    final l10n = context.l10n;

    Widget button(
      PowerUpType type,
      IconData icon,
      String label,
      int count,
      bool enabled,
      VoidCallback onTap,
    ) {
      if (!available.contains(type)) return const SizedBox.shrink();
      return KeyedSubtree(
        key: buttonKeys[type],
        child: GlossyIconButton(
          icon: icon,
          size: buttonSize,
          label: label,
          semanticLabel: l10n.powerUpSemantics(label, count),
          badge: count,
          enabled: enabled && !busy && !solving,
          onTap: onTap,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        button(
          PowerUpType.undo,
          Icons.undo_rounded,
          l10n.undo,
          undo,
          undo > 0 && hasHistory,
          () {
            _feedback(context, c.undo(), PowerUpType.undo);
          },
        ),
        if (kDebugMode)
          GlossyIconButton(
            icon: solving ? Icons.stop_rounded : Icons.auto_fix_high_rounded,
            size: buttonSize,
            label: solving ? 'STOP' : 'SOLVE',
            semanticLabel: solving ? 'Stop auto-solve' : 'Auto-solve (dev)',
            enabled: solving || !busy,
            onTap: () async {
              if (solving) {
                c.stopAutoSolve();
                return;
              }
              final r = await c.autoSolve();
              if (!context.mounted) return;
              final msg = switch (r) {
                AutoSolveResult.unsolvable =>
                  'No solution from this position - undo some moves.',
                AutoSolveResult.tooHard =>
                  'Solver gave up (search limit) - try undoing a few moves.',
                _ => null,
              };
              if (msg != null) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(msg)));
              }
            },
          ),
        button(
          PowerUpType.shuffle,
          Icons.shuffle_rounded,
          l10n.shuffle,
          shuffle,
          shuffle > 0,
          () async {
            final r = await c.shuffle();
            if (context.mounted) _feedback(context, r, PowerUpType.shuffle);
          },
        ),
        button(
          PowerUpType.addTube,
          Icons.add_rounded,
          l10n.addTube,
          add,
          add > 0,
          () {
            final r = c.addTube();
            if (r != PowerUpResult.applied)
              ref.read(audioServiceProvider).play(Sfx.invalid);
            _feedback(context, r, PowerUpType.addTube);
          },
        ),
      ],
    );
  }
}
