import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/game_palette.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/game_constants.dart';
import '../../../core/l10n/l10n.dart';
import '../../../shared/audio/audio_service.dart';
import '../../../shared/widgets/glossy_button.dart';
import '../../../shared/widgets/space_background.dart';
import '../../../storage/local_storage_service.dart';
import '../../game/data/progress_repository.dart';
import '../../game/presentation/widgets/settings_popup.dart';
import 'widgets/home_logo.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(progressProvider);
    final saved =
        ref
                .read(localStorageProvider)
                .readJson(LocalStorageService.savedGameKey)?['level']
            as int?;
    final resumeLevel = (saved != null && p.isUnlocked(saved))
        ? saved
        : p.lastPlayedLevel
              .clamp(1, p.highestUnlockedLevel)
              .clamp(1, GameConstants.totalLevelCount);
    final stars = p.completedLevels.values.fold(0, (a, b) => a + b);
    final audio = ref.read(audioServiceProvider);
    final l10n = context.l10n;
    final palette = context.palette;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SpaceBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, c) {
              final width = c.maxWidth.clamp(0.0, 420.0) * 0.8;
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: c.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: AppColors.gold,
                            ),
                            Text(
                              ' $stars',
                              style: TextStyle(
                                color: palette.text,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Spacer(),
                            GlossyIconButton(
                              icon: Icons.settings_rounded,
                              size: 46,
                              semanticLabel: l10n.settingsLabel,
                              onTap: () {
                                audio.play(Sfx.tap);
                                showSettingsPopup(context, inGame: false);
                              },
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: HomeLogo(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: SizedBox(
                          width: width,
                          child: Column(
                            children: [
                              PillButton(
                                label: saved == resumeLevel
                                    ? l10n.continueLevel(resumeLevel)
                                    : l10n.playLevel(resumeLevel),
                                icon: Icons.play_arrow_rounded,
                                height: 64,
                                fontSize: 20,
                                onTap: () {
                                  audio.play(Sfx.tap);
                                  context.go('/game/$resumeLevel');
                                },
                              ),
                              const SizedBox(height: 16),
                              PillButton(
                                label: l10n.levels,
                                icon: Icons.grid_view_rounded,
                                colors: PillButton.purple,
                                onTap: () {
                                  audio.play(Sfx.tap);
                                  context.go('/levels');
                                },
                              ),
                              const SizedBox(height: 14),
                              Text(
                                l10n.levelsSolved(
                                  p.completedLevels.length,
                                  GameConstants.totalLevelCount,
                                ),
                                style: TextStyle(
                                  color: palette.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
