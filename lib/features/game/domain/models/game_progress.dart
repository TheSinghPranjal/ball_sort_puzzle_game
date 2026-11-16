/// Persistent player progress. Settings live in their own model
/// (see settings_repository.dart) and are persisted alongside.
class GameProgress {
  GameProgress({
    this.highestUnlockedLevel = 1,
    Map<int, int> completedLevels = const {},
    this.lastPlayedLevel = 1,
    Set<String> tutorialsCompleted = const {},
  })  : completedLevels = Map.unmodifiable(completedLevels),
        tutorialsCompleted = Set.unmodifiable(tutorialsCompleted);

  final int highestUnlockedLevel;

  /// levelId -> best stars (1..3).
  final Map<int, int> completedLevels;
  final int lastPlayedLevel;
  final Set<String> tutorialsCompleted;

  bool isUnlocked(int levelId) => levelId >= 1 && levelId <= highestUnlockedLevel;
  bool isCompleted(int levelId) => completedLevels.containsKey(levelId);
  int starsFor(int levelId) => completedLevels[levelId] ?? 0;
  bool tutorialCompleted(String key) => tutorialsCompleted.contains(key);

  GameProgress copyWith({
    int? highestUnlockedLevel,
    Map<int, int>? completedLevels,
    int? lastPlayedLevel,
    Set<String>? tutorialsCompleted,
  }) =>
      GameProgress(
        highestUnlockedLevel: highestUnlockedLevel ?? this.highestUnlockedLevel,
        completedLevels: completedLevels ?? this.completedLevels,
        lastPlayedLevel: lastPlayedLevel ?? this.lastPlayedLevel,
        tutorialsCompleted: tutorialsCompleted ?? this.tutorialsCompleted,
      );

  Map<String, dynamic> toJson() => {
        'highest': highestUnlockedLevel,
        'completed': {
          for (final e in completedLevels.entries) '${e.key}': e.value,
        },
        'last': lastPlayedLevel,
        'tutorials': tutorialsCompleted.toList(),
      };

  factory GameProgress.fromJson(Map<String, dynamic> json) => GameProgress(
        highestUnlockedLevel: (json['highest'] as int?) ?? 1,
        completedLevels: {
          for (final e in (json['completed'] as Map? ?? {}).entries)
            int.parse(e.key as String): e.value as int,
        },
        lastPlayedLevel: (json['last'] as int?) ?? 1,
        tutorialsCompleted: {
          for (final t in (json['tutorials'] as List? ?? [])) t as String,
        },
      );
}
