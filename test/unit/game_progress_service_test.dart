import 'package:ball_sort_puzzle_game/features/game/domain/models/game_progress.dart';
import 'package:ball_sort_puzzle_game/features/game/domain/services/level_progress_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = LevelProgressService(totalLevels: 100);

  test('only level 1 is unlocked by default', () {
    final p = GameProgress();
    expect(p.isUnlocked(1), isTrue);
    expect(p.isUnlocked(2), isFalse);
    expect(service.canPlay(p, 2), isFalse);
  });

  test('completing a level unlocks the next one and records stars', () {
    var p = service.completeLevel(GameProgress(), 1, 3);
    expect(p.highestUnlockedLevel, 2);
    expect(p.isCompleted(1), isTrue);
    expect(p.starsFor(1), 3);
    expect(p.lastPlayedLevel, 2);
    p = service.completeLevel(p, 2, 1);
    expect(p.highestUnlockedLevel, 3);
  });

  test('replaying an earlier level never lowers progress or best stars', () {
    var p = GameProgress(highestUnlockedLevel: 10, completedLevels: {3: 3});
    p = service.completeLevel(p, 3, 1);
    expect(p.highestUnlockedLevel, 10);
    expect(p.starsFor(3), 3);
  });

  test('last level does not unlock beyond the total', () {
    final p = service.completeLevel(
      GameProgress(highestUnlockedLevel: 100),
      100,
      2,
    );
    expect(p.highestUnlockedLevel, 100);
  });

  test('locked levels cannot be marked as played', () {
    final p = service.markPlayed(GameProgress(), 7);
    expect(p.lastPlayedLevel, 1);
  });

  test('tutorial completion and json round-trip', () {
    var p = service.completeTutorial(GameProgress(), 'basicMove');
    p = service.completeLevel(p, 1, 2);
    final back = GameProgress.fromJson(p.toJson());
    expect(back.tutorialCompleted('basicMove'), isTrue);
    expect(back.highestUnlockedLevel, 2);
    expect(back.starsFor(1), 2);
  });
}
