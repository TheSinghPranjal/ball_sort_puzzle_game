import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../storage/local_storage_service.dart';
import '../domain/models/game_progress.dart';
import '../domain/services/level_progress_service.dart';

class ProgressController extends Notifier<GameProgress> {
  static const service = LevelProgressService();

  LocalStorageService get _storage => ref.read(localStorageProvider);

  @override
  GameProgress build() {
    final j = ref.watch(localStorageProvider).readJson(LocalStorageService.progressKey);
    return j == null ? GameProgress() : GameProgress.fromJson(j);
  }

  Future<void> _save(GameProgress p) {
    state = p;
    return _storage.writeJson(LocalStorageService.progressKey, p.toJson());
  }

  Future<void> completeLevel(int levelId, int stars) =>
      _save(service.completeLevel(state, levelId, stars));

  Future<void> markPlayed(int levelId) => _save(service.markPlayed(state, levelId));

  Future<void> completeTutorial(String key) =>
      _save(service.completeTutorial(state, key));
}

final progressProvider =
    NotifierProvider<ProgressController, GameProgress>(ProgressController.new);
