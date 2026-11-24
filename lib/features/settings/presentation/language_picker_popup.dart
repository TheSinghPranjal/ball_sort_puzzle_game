import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/game_palette.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/l10n.dart';
import '../../../shared/audio/audio_service.dart';
import '../../../shared/widgets/game_popup.dart';
import '../settings_repository.dart';

Future<void> showLanguagePicker(BuildContext context) => showGamePopup<void>(
  context,
  dismissible: true,
  builder: (_) => const LanguagePickerPopup(),
);

class LanguagePickerPopup extends ConsumerWidget {
  const LanguagePickerPopup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(settingsProvider.select((s) => s.languageCode));
    return GamePanel(
      title: context.l10n.chooseLanguage,
      onClose: () => Navigator.of(context).pop(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final lang in AppLanguage.supported)
            _LanguageTile(
              language: lang,
              selected: lang.code == current,
              onTap: () async {
                final audio = ref.read(audioServiceProvider)
                  ..play(Sfx.tap)
                  ..haptic(Haptic.light);
                if (lang.code == current) {
                  Navigator.of(context).pop();
                  return;
                }
                ref.read(settingsProvider.notifier).setLanguage(lang.code);
                audio.play(Sfx.select);
                // Let the selection animate before the popup closes.
                await Future<void>.delayed(const Duration(milliseconds: 260));
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  final AppLanguage language;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final radius = BorderRadius.circular(16);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Semantics(
        button: true,
        selected: selected,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: radius,
            color: selected
                ? AppColors.buttonBottom.withValues(alpha: 0.22)
                : palette.panelDark.withValues(alpha: 0.6),
            border: Border.all(
              color: selected
                  ? palette.accent
                  : palette.panelBorder.withValues(alpha: 0.35),
              width: selected ? 2 : 1,
            ),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: radius,
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            language.nativeName,
                            style: TextStyle(
                              color: palette.text,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (language.nativeName != language.englishName)
                            Text(
                              language.englishName,
                              style: TextStyle(
                                color: palette.textMuted,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    AnimatedScale(
                      scale: selected ? 1 : 0,
                      duration: const Duration(milliseconds: 280),
                      curve: selected ? Curves.easeOutBack : Curves.easeIn,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.success,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
