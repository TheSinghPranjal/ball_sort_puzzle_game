import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n.dart';
import '../../storage/local_storage_service.dart';

class GameSettings {
  const GameSettings({
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.vibrationEnabled = true,
    this.themeMode = ThemeMode.dark,
    this.languageCode = AppLanguage.defaultCode,
  });

  final bool soundEnabled;
  final bool musicEnabled;
  final bool vibrationEnabled;

  /// Dark is the game's signature look, so it is the default; players can
  /// switch to light or follow the device.
  final ThemeMode themeMode;

  /// One of [AppLanguage.supported]. English by default.
  final String languageCode;

  GameSettings copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    bool? vibrationEnabled,
    ThemeMode? themeMode,
    String? languageCode,
  }) => GameSettings(
    soundEnabled: soundEnabled ?? this.soundEnabled,
    musicEnabled: musicEnabled ?? this.musicEnabled,
    vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    themeMode: themeMode ?? this.themeMode,
    languageCode: languageCode ?? this.languageCode,
  );

  Map<String, dynamic> toJson() => {
    'sound': soundEnabled,
    'music': musicEnabled,
    'vibration': vibrationEnabled,
    'theme': themeMode.name,
    'language': languageCode,
  };

  factory GameSettings.fromJson(Map<String, dynamic> j) => GameSettings(
    soundEnabled: j['sound'] as bool? ?? true,
    musicEnabled: j['music'] as bool? ?? true,
    vibrationEnabled: j['vibration'] as bool? ?? true,
    themeMode: ThemeMode.values.firstWhere(
      (m) => m.name == j['theme'],
      orElse: () => ThemeMode.dark,
    ),
    // Unknown codes (e.g. a language removed in a later version) fall back
    // to the default instead of leaving the app untranslated.
    languageCode: AppLanguage.byCode(j['language'] as String?).code,
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

final settingsRepositoryProvider = Provider(
  (ref) => SettingsRepository(ref.watch(localStorageProvider)),
);

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
  void setThemeMode(ThemeMode v) => _set(state.copyWith(themeMode: v));
  void setLanguage(String code) =>
      _set(state.copyWith(languageCode: AppLanguage.byCode(code).code));
}

final settingsProvider = NotifierProvider<SettingsController, GameSettings>(
  SettingsController.new,
);
