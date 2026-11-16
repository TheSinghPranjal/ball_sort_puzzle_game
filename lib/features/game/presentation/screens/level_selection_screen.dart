import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/game_constants.dart';
import '../../../../shared/audio/audio_service.dart';
import '../../../../shared/widgets/glossy_button.dart';
import '../../../../shared/widgets/space_background.dart';
import '../../data/level_repository.dart';
import '../../data/progress_repository.dart';
import '../../domain/models/game_progress.dart';

class _Band {
  const _Band(this.title, this.from, this.to);
  final String title;
  final int from;
  final int to;
}

const _bands = [
  _Band('TUTORIAL', 1, 5),
  _Band('EASY', 6, 20),
  _Band('MEDIUM', 21, 40),
  _Band('HARD', 41, 60),
  _Band('EXPERT', 61, 80),
  _Band('MASTER', 81, 100),
  _Band('CHALLENGE', 101, 500),
  _Band('LEGEND', 501, GameConstants.totalLevelCount),
];

class LevelSelectionScreen extends ConsumerStatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  ConsumerState<LevelSelectionScreen> createState() =>
      _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends ConsumerState<LevelSelectionScreen> {
  ScrollController? _scroll;
  static const _headerExtent = 52.0;
  static const _spacing = 10.0;

  ScrollController _controllerFor(double width, int cols, int current) {
    if (_scroll != null) return _scroll!;
    // Estimate the offset of the current level so it is visible on open.
    final tile = (width - 32 - (cols - 1) * _spacing) / cols;
    var offset = 0.0;
    for (final b in _bands) {
      offset += _headerExtent;
      if (current <= b.to) {
        offset += ((current - b.from) ~/ cols) * (tile + _spacing);
        break;
      }
      offset += ((b.to - b.from + 1) / cols).ceil() * (tile + _spacing);
    }
    return _scroll = ScrollController(
      initialScrollOffset: math.max(0, offset - 160),
    );
  }

  @override
  void dispose() {
    _scroll?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = ref.watch(progressProvider);
    final totalStars = p.completedLevels.values.fold(0, (a, b) => a + b);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/');
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SpaceBackground(
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      GlossyIconButton(
                        icon: Icons.arrow_back_rounded,
                        size: 46,
                        semanticLabel: 'Back',
                        onTap: () => context.go('/'),
                      ),
                      const Expanded(
                        child: Text(
                          'SELECT LEVEL',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const Icon(Icons.star_rounded, color: AppColors.gold),
                      Text(
                        ' $totalStars',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final cols = (c.maxWidth / 78).floor().clamp(4, 9);
                      return CustomScrollView(
                        controller: _controllerFor(
                          c.maxWidth,
                          cols,
                          p.highestUnlockedLevel,
                        ),
                        slivers: [
                          for (final b in _bands) ...[
                            SliverToBoxAdapter(
                              child: SizedBox(
                                height: _headerExtent,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    18,
                                    20,
                                    8,
                                  ),
                                  child: Text(
                                    '${b.title}  ·  ${b.from}-${b.to}',
                                    style: const TextStyle(
                                      color: AppColors.lavender,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              sliver: SliverGrid(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: cols,
                                      mainAxisSpacing: _spacing,
                                      crossAxisSpacing: _spacing,
                                    ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, i) => _LevelTile(
                                    levelId: b.from + i,
                                    progress: p,
                                  ),
                                  childCount: b.to - b.from + 1,
                                ),
                              ),
                            ),
                          ],
                          const SliverToBoxAdapter(child: SizedBox(height: 32)),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LevelTile extends ConsumerWidget {
  const _LevelTile({required this.levelId, required this.progress});
  final int levelId;
  final GameProgress progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlocked = progress.isUnlocked(levelId);
    final completed = progress.isCompleted(levelId);
    final current = levelId == progress.highestUnlockedLevel && !completed;
    final stars = progress.starsFor(levelId);
    final level = ref.read(levelRepositoryProvider).curated(levelId);
    return Semantics(
      excludeSemantics: true,
      button: unlocked,
      label: unlocked
          ? 'Level $levelId${completed ? ', $stars stars' : ''}'
          : 'Level $levelId locked',
      hint: [
        if (level.mystery) 'mystery',
        if (level.isSpecial) 'special',
      ].join(', '),
      child: GestureDetector(
        onTap: () {
          if (!unlocked) {
            ref.read(audioServiceProvider).play(Sfx.invalid);
            return;
          }
          ref.read(audioServiceProvider).play(Sfx.tap);
          context.go('/game/$levelId');
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: unlocked
                  ? (completed
                        ? const [Color(0xFF8C74FF), Color(0xFF5235C9)]
                        : const [AppColors.buttonTop, AppColors.buttonBottom])
                  : const [Color(0xFF2E2756), Color(0xFF1C1640)],
            ),
            border: Border.all(
              color: current
                  ? AppColors.gold
                  : Colors.white.withValues(alpha: unlocked ? 0.35 : 0.1),
              width: current ? 2.5 : 1.2,
            ),
            boxShadow: [
              if (current)
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.55),
                  blurRadius: 14,
                ),
              if (unlocked)
                const BoxShadow(
                  color: Colors.black38,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: unlocked
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: FittedBox(
                              child: Text(
                                '$levelId',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                          if (completed)
                            FittedBox(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  for (var i = 0; i < 3; i++)
                                    Icon(
                                      Icons.star_rounded,
                                      size: 14,
                                      color: i < stars
                                          ? AppColors.gold
                                          : Colors.white.withValues(
                                              alpha: 0.25,
                                            ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      )
                    : Icon(
                        Icons.lock_rounded,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
              ),
              if (level.mystery || level.isSpecial)
                Positioned(
                  right: 4,
                  top: 3,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (level.isSpecial)
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 12,
                          color: AppColors.gold.withValues(
                            alpha: unlocked ? 1 : 0.4,
                          ),
                        ),
                      if (level.mystery)
                        Text(
                          '?',
                          style: TextStyle(
                            color: Colors.white.withValues(
                              alpha: unlocked ? 0.9 : 0.35,
                            ),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
