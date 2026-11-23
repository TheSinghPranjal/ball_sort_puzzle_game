/// Global gameplay constants. Pure Dart: safe to import from tools and tests.
class GameConstants {
  GameConstants._();

  static const int defaultTubeCapacity = 4;

  static const int defaultUndoUses = 5;
  static const int defaultShuffleUses = 2;
  static const int defaultAddTubeUses = 2;

  /// Levels shipped as solver-verified static data (built offline by
  /// tool/generate_levels.dart).
  static const int curatedLevelCount = 2000;

  /// Total playable levels.
  static const int totalLevelCount = curatedLevelCount;

  /// Max snapshots kept for undo (memory bound).
  static const int maxUndoHistory = 200;

  /// Solver node budgets.
  static const int runtimeSolverNodeLimit = 60000;
  static const int devSolverNodeLimit = 400000;

  static const Duration moveAnimation = Duration(milliseconds: 360);
  static const Duration liftAnimation = Duration(milliseconds: 140);
  static const Duration shakeAnimation = Duration(milliseconds: 320);
}
