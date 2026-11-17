import '../../../../core/constants/game_constants.dart';
import '../models/game_progress.dart';

/// Pure progression rules (unlocking, best stars, tutorials). Persistence is
/// done by the provider layer, keeping this logic trivially testable.
class LevelProgressService {
  const LevelProgressService({
    this.totalLevels = GameConstants.totalLevelCount,
  });

  final int totalLevels;

  GameProgress completeLevel(GameProgress p, int levelId, int stars) {
    final best = stars > p.starsFor(levelId) ? stars : p.starsFor(levelId);
    final next = (levelId + 1).clamp(1, totalLevels);
    return p.copyWith(
      completedLevels: {...p.completedLevels, levelId: best},
      highestUnlockedLevel: next > p.highestUnlockedLevel
          ? next
          : p.highestUnlockedLevel,
      lastPlayedLevel: next,
    );
  }

  GameProgress markPlayed(GameProgress p, int levelId) {
    if (!p.isUnlocked(levelId)) return p;
    return p.copyWith(lastPlayedLevel: levelId);
  }

  GameProgress completeTutorial(GameProgress p, String key) =>
      p.copyWith(tutorialsCompleted: {...p.tutorialsCompleted, key});

  bool canPlay(GameProgress p, int levelId) =>
      levelId >= 1 && levelId <= totalLevels && p.isUnlocked(levelId);
}
