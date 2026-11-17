import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  void _feedback(BuildContext context, PowerUpResult r, String name) {
    final msg = switch (r) {
      PowerUpResult.noUsesLeft =>
        'No $name left - restart the level to refill power-ups.',
      PowerUpResult.nothingToUndo => 'Nothing to undo yet.',
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
    if (available.isEmpty) return const SizedBox.shrink();
    final c = ref.read(gameControllerProvider.notifier);

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
          semanticLabel: '$label, $count left',
          badge: count,
          enabled: enabled && !busy,
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
          'UNDO',
          undo,
          undo > 0 && hasHistory,
          () {
            _feedback(context, c.undo(), 'undos');
          },
        ),
        button(
          PowerUpType.shuffle,
          Icons.shuffle_rounded,
          'SHUFFLE',
          shuffle,
          shuffle > 0,
          () async {
            final r = await c.shuffle();
            if (context.mounted) _feedback(context, r, 'shuffles');
          },
        ),
        button(
          PowerUpType.addTube,
          Icons.add_rounded,
          'ADD TUBE',
          add,
          add > 0,
          () {
            final r = c.addTube();
            if (r != PowerUpResult.applied)
              ref.read(audioServiceProvider).play(Sfx.invalid);
            _feedback(context, r, 'extra tubes');
          },
        ),
      ],
    );
  }
}
