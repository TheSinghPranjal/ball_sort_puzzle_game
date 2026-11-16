import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../storage/local_storage_service.dart';

class GameSettings {
  const GameSettings({
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.vibrationEnabled = true,
  });

  final bool soundEnabled;
  final bool musicEnabled;
  final bool vibrationEnabled;

  GameSettings copyWith({bool? soundEnabled, bool? musicEnabled, bool? vibrationEnabled}) =>
      GameSettings(
        soundEnabled: soundEnabled ?? this.soundEnabled,
        musicEnabled: musicEnabled ?? this.musicEnabled,
        vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      );

  Map<String, dynamic> toJson() =>
      {'sound': soundEnabled, 'music': musicEnabled, 'vibration': vibrationEnabled};

  factory GameSettings.fromJson(Map<String, dynamic> j) => GameSettings(
        soundEnabled: j['sound'] as bool? ?? true,
        musicEnabled: j['music'] as bool? ?? true,
        vibrationEnabled: j['vibration'] as bool? ?? true,
      );
}

class SettingsRepository {
  SettingsRepository(this._storage);
  final LocalStorageService _storage;

  GameSettings load() {
    final j = _storage.readJson(LocalStorageService.settingsKey);
    return j == null ? const GameSettings() : GameSettings.fromJson(j);
  }

  Future<void> save(GameSettings s) =>
      _storage.writeJson(LocalStorageService.settingsKey, s.toJson());
}

final settingsRepositoryProvider =
    Provider((ref) => SettingsRepository(ref.watch(localStorageProvider)));

class SettingsController extends Notifier<GameSettings> {
  @override
  GameSettings build() => ref.watch(settingsRepositoryProvider).load();

  void _set(GameSettings s) {
    state = s;
    ref.read(settingsRepositoryProvider).save(s);
  }

  void setSound(bool v) => _set(state.copyWith(soundEnabled: v));
  void setMusic(bool v) => _set(state.copyWith(musicEnabled: v));
  void setVibration(bool v) => _set(state.copyWith(vibrationEnabled: v));
}

final settingsProvider =
    NotifierProvider<SettingsController, GameSettings>(SettingsController.new);
