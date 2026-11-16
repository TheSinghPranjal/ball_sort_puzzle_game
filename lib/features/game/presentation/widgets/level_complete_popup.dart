import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/game_popup.dart';
import '../../../../shared/widgets/glossy_button.dart';

enum LevelCompleteAction { next, replay, home }

Future<LevelCompleteAction?> showLevelCompletePopup(
  BuildContext context, {
  required int levelId,
  required int moves,
  required int stars,
  int? moveTarget,
  required bool hasNext,
}) =>
    showGamePopup<LevelCompleteAction>(
      context,
      builder: (_) => LevelCompletePopup(
        levelId: levelId,
        moves: moves,
        stars: stars,
        moveTarget: moveTarget,
        hasNext: hasNext,
      ),
    );

class LevelCompletePopup extends StatelessWidget {
  const LevelCompletePopup({
    super.key,
    required this.levelId,
    required this.moves,
    required this.stars,
    required this.moveTarget,
    required this.hasNext,
  });

  final int levelId;
  final int moves;
  final int stars;
  final int? moveTarget;
  final bool hasNext;

  @override
  Widget build(BuildContext context) {
    void close(LevelCompleteAction a) => Navigator.of(context).pop(a);
    return GamePanel(
      title: 'LEVEL COMPLETE!',
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < 3; i++)
              Padding(
                padding: EdgeInsets.only(bottom: i == 1 ? 14 : 0, left: 4, right: 4),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 450 + i * 220),
                  curve: Interval(i * 0.3, 1, curve: Curves.elasticOut),
                  builder: (context, v, child) => Transform.scale(scale: v, child: child),
                  child: Icon(
                    Icons.star_rounded,
                    size: i == 1 ? 72 : 58,
                    color: i < stars ? AppColors.gold : Colors.white.withValues(alpha: 0.15),
                    shadows: i < stars ? const [Shadow(color: Color(0x99FFB300), blurRadius: 18)] : null,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text('Level $levelId solved in',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 15, fontWeight: FontWeight.w600)),
        Text('$moves MOVES',
            style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 1)),
        if (moveTarget != null)
          Text(
            moves <= moveTarget! ? 'Goal of $moveTarget reached!' : 'Goal: $moveTarget moves',
            style: TextStyle(
              color: moves <= moveTarget! ? AppColors.success : AppColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        const SizedBox(height: 20),
        PillButton(
          label: hasNext ? 'CONTINUE' : 'ALL LEVELS DONE!',
          icon: Icons.arrow_forward_rounded,
          onTap: () => close(hasNext ? LevelCompleteAction.next : LevelCompleteAction.home),
        ),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          GlossyIconButton(
            icon: Icons.home_rounded,
            size: 48,
            semanticLabel: 'Home',
            onTap: () => close(LevelCompleteAction.home),
          ),
          const SizedBox(width: 24),
          GlossyIconButton(
            icon: Icons.replay_rounded,
            size: 48,
            semanticLabel: 'Replay level',
            onTap: () => close(LevelCompleteAction.replay),
          ),
        ]),
      ]),
    );
  }
}
