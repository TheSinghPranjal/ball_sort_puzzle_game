import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/game_palette.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../shared/audio/audio_service.dart';
import '../../../../shared/widgets/game_popup.dart';
import '../../../../shared/widgets/glossy_button.dart';
import '../../../settings/presentation/how_to_play_popup.dart';
import '../../../settings/presentation/language_picker_popup.dart';
import '../../../settings/settings_repository.dart';

enum SettingsAction { resume, restart, exitHome }

Future<SettingsAction?> showSettingsPopup(
  BuildContext context, {
  required bool inGame,
}) => showGamePopup<SettingsAction>(
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
    final l10n = context.l10n;
    void close(SettingsAction a) => Navigator.of(context).pop(a);

    return GamePanel(
      title: l10n.settings,
      onClose: () => close(SettingsAction.resume),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionLabel(l10n.sectionAudio),
          _ToggleRow(
            icon: Icons.volume_up_rounded,
            offIcon: Icons.volume_off_rounded,
            label: l10n.soundEffects,
            value: s.soundEnabled,
            onChanged: (v) {
              c.setSound(v);
              if (v) audio.play(Sfx.tap);
            },
          ),
          _ToggleRow(
            icon: Icons.music_note_rounded,
            offIcon: Icons.music_off_rounded,
            label: l10n.music,
            value: s.musicEnabled,
            onChanged: c.setMusic,
          ),
          _ToggleRow(
            icon: Icons.vibration_rounded,
            offIcon: Icons.mobile_off_rounded,
            label: l10n.vibration,
            value: s.vibrationEnabled,
            onChanged: (v) {
              c.setVibration(v);
              if (v) audio.haptic(Haptic.medium);
            },
          ),
          const SizedBox(height: 10),
          _SectionLabel(l10n.sectionGeneral),
          _RowShell(
            icon: Icons.contrast_rounded,
            label: l10n.theme,
            trailing: const SizedBox.shrink(),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 6),
            child: ThemeModeSelector(
              value: s.themeMode,
              onChanged: (m) {
                audio.play(Sfx.tap);
                audio.haptic(Haptic.light);
                c.setThemeMode(m);
              },
            ),
          ),
          _NavRow(
            icon: Icons.language_rounded,
            label: l10n.language,
            value: AppLanguage.byCode(s.languageCode).nativeName,
            onTap: () {
              audio.play(Sfx.tap);
              showLanguagePicker(context);
            },
          ),
          _NavRow(
            icon: Icons.help_outline_rounded,
            label: l10n.howToPlay,
            onTap: () {
              audio.play(Sfx.tap);
              showHowToPlay(context);
            },
          ),
          const SizedBox(height: 18),
          if (inGame) ...[
            PillButton(
              label: l10n.resume,
              icon: Icons.play_arrow_rounded,
              onTap: () => close(SettingsAction.resume),
            ),
            const SizedBox(height: 12),
            PillButton(
              label: l10n.restartLevelButton,
              icon: Icons.replay_rounded,
              colors: PillButton.purple,
              fontSize: 17,
              height: 48,
              onTap: () => close(SettingsAction.restart),
            ),
            const SizedBox(height: 12),
            PillButton(
              label: l10n.exitToHome,
              icon: Icons.home_rounded,
              colors: PillButton.red,
              fontSize: 17,
              height: 48,
              onTap: () => close(SettingsAction.exitHome),
            ),
          ] else
            PillButton(
              label: l10n.done,
              onTap: () => close(SettingsAction.resume),
            ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
      child: Text(
        text,
        style: TextStyle(
          color: context.palette.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

/// Icon + label + trailing widget, with a rounded ink ripple.
class _RowShell extends StatelessWidget {
  const _RowShell({
    required this.icon,
    required this.label,
    required this.trailing,
    this.onTap,
  });

  final Widget trailing;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, a) =>
                    ScaleTransition(scale: a, child: child),
                child: Icon(icon, key: ValueKey(icon), color: palette.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.offIcon,
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final IconData offIcon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    // The whole row is the touch target; screen readers hear one switch.
    return MergeSemantics(
      child: _RowShell(
        icon: value ? icon : offIcon,
        label: label,
        onTap: () => onChanged(!value),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.white,
          activeTrackColor: AppColors.success,
          inactiveThumbColor: palette.textMuted,
          inactiveTrackColor: palette.panelDark,
          trackOutlineColor: WidgetStatePropertyAll(
            palette.panelBorder.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
  });
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      child: _RowShell(
        icon: icon,
        label: label,
        onTap: onTap,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (value != null)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  value!,
                  key: ValueKey(value),
                  style: TextStyle(
                    color: palette.textMuted,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            Icon(Icons.chevron_right_rounded, color: palette.textMuted),
          ],
        ),
      ),
    );
  }
}

/// Three-way Auto / Light / Dark switch with a sliding highlight.
class ThemeModeSelector extends StatelessWidget {
  const ThemeModeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;

  static const _modes = [ThemeMode.system, ThemeMode.light, ThemeMode.dark];

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = context.l10n;
    final index = _modes.indexOf(value);
    final labels = [l10n.themeSystem, l10n.themeLight, l10n.themeDark];
    const icons = [
      Icons.brightness_auto_rounded,
      Icons.light_mode_rounded,
      Icons.dark_mode_rounded,
    ];
    const height = 44.0;
    return Container(
      height: height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: palette.panelDark,
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(color: palette.panelBorder.withValues(alpha: 0.6)),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: Alignment(-1 + index * 1.0, 0),
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            child: FractionallySizedBox(
              widthFactor: 1 / _modes.length,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(height / 2),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: PillButton.purple,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.buttonBottom.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (var i = 0; i < _modes.length; i++)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: i == index,
                    label: labels[i],
                    excludeSemantics: true,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (i != index) onChanged(_modes[i]);
                      },
                      child: TweenAnimationBuilder<Color?>(
                        tween: ColorTween(
                          end: i == index ? Colors.white : palette.textMuted,
                        ),
                        duration: const Duration(milliseconds: 220),
                        builder: (context, color, _) => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(icons[i], size: 18, color: color),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                labels[i],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: color,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
