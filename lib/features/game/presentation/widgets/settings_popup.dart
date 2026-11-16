import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/audio/audio_service.dart';
import '../../../../shared/widgets/game_popup.dart';
import '../../../../shared/widgets/glossy_button.dart';
import '../../../settings/settings_repository.dart';

enum SettingsAction { resume, restart, exitHome }

Future<SettingsAction?> showSettingsPopup(BuildContext context, {required bool inGame}) =>
    showGamePopup<SettingsAction>(
      context,
      dismissible: true,
      builder: (_) => SettingsPopup(inGame: inGame),
    );

class SettingsPopup extends ConsumerWidget {
  const SettingsPopup({super.key, required this.inGame});
  final bool inGame;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final c = ref.read(settingsProvider.notifier);
    final audio = ref.read(audioServiceProvider);
    void close(SettingsAction a) => Navigator.of(context).pop(a);

    return GamePanel(
      title: 'SETTINGS',
      onClose: () => close(SettingsAction.resume),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _ToggleRow(
          icon: Icons.volume_up_rounded,
          label: 'Sound Effects',
          value: s.soundEnabled,
          onChanged: (v) {
            c.setSound(v);
            if (v) audio.play(Sfx.tap);
          },
        ),
        _ToggleRow(icon: Icons.music_note_rounded, label: 'Music', value: s.musicEnabled, onChanged: c.setMusic),
        _ToggleRow(
          icon: Icons.vibration_rounded,
          label: 'Vibration',
          value: s.vibrationEnabled,
          onChanged: (v) {
            c.setVibration(v);
            if (v) audio.haptic(Haptic.medium);
          },
        ),
        const SizedBox(height: 18),
        if (inGame) ...[
          PillButton(label: 'RESUME', icon: Icons.play_arrow_rounded, onTap: () => close(SettingsAction.resume)),
          const SizedBox(height: 12),
          PillButton(
            label: 'RESTART LEVEL',
            icon: Icons.replay_rounded,
            colors: PillButton.purple,
            fontSize: 17,
            height: 48,
            onTap: () => close(SettingsAction.restart),
          ),
          const SizedBox(height: 12),
          PillButton(
            label: 'EXIT TO HOME',
            icon: Icons.home_rounded,
            colors: PillButton.red,
            fontSize: 17,
            height: 48,
            onTap: () => close(SettingsAction.exitHome),
          ),
        ] else
          PillButton(label: 'DONE', onTap: () => close(SettingsAction.resume)),
      ]),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({required this.icon, required this.label, required this.value, required this.onChanged});
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Icon(icon, color: AppColors.lavender),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.white,
          activeTrackColor: AppColors.success,
          inactiveTrackColor: AppColors.panelDark,
        ),
      ]),
    );
  }
}
