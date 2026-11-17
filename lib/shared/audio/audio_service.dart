import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/settings_repository.dart';

enum Sfx { tap, select, lift, drop, invalid, undo, shuffle, addTube, complete }

enum Haptic { light, medium, success }

/// Audio + haptics facade. Respects the persisted settings; every platform call
/// is guarded so a missing plugin (tests, unsupported platform) never breaks
/// gameplay.
abstract class AudioService {
  void play(Sfx sfx);
  void haptic(Haptic kind);
  void setMusicEnabled(bool enabled);
  void onAppPaused();
  void onAppResumed();
  Future<void> dispose();
}

/// Used in tests and when audio fails to initialize.
class SilentAudioService implements AudioService {
  final played = <Sfx>[];
  @override
  void play(Sfx sfx) => played.add(sfx);
  @override
  void haptic(Haptic kind) {}
  @override
  void setMusicEnabled(bool enabled) {}
  @override
  void onAppPaused() {}
  @override
  void onAppResumed() {}
  @override
  Future<void> dispose() async {}
}

class AudioPlayersService implements AudioService {
  AudioPlayersService(this._settings);

  final GameSettings Function() _settings;
  final _pools = <Sfx, AudioPool>{};
  AudioPlayer? _music;
  bool _musicWanted = false;
  bool _appActive = true;

  static const _files = {
    Sfx.tap: 'audio/tap.wav',
    Sfx.select: 'audio/select.wav',
    Sfx.lift: 'audio/lift.wav',
    Sfx.drop: 'audio/drop.wav',
    Sfx.invalid: 'audio/invalid.wav',
    Sfx.undo: 'audio/undo.wav',
    Sfx.shuffle: 'audio/shuffle.wav',
    Sfx.addTube: 'audio/add_tube.wav',
    Sfx.complete: 'audio/complete.wav',
  };

  Future<void> init() async {
    try {
      // Sound effects must mix with the music instead of stealing focus.
      await AudioPlayer.global.setAudioContext(
        AudioContextConfig(
          focus: AudioContextConfigFocus.mixWithOthers,
        ).build(),
      );
      for (final e in _files.entries) {
        _pools[e.key] = await AudioPool.createFromAsset(
          path: e.value,
          maxPlayers: 3,
        );
      }
      final music = AudioPlayer(playerId: 'music');
      await music.setReleaseMode(ReleaseMode.loop);
      await music.setVolume(0.35);
      await music.setSource(AssetSource('audio/music.wav'));
      _music = music;
      setMusicEnabled(_settings().musicEnabled);
    } catch (e) {
      debugPrint('Audio init failed: $e');
    }
  }

  @override
  void play(Sfx sfx) {
    if (!_settings().soundEnabled) return;
    final pool = _pools[sfx];
    if (pool == null) return;
    unawaited(
      pool
          .start(volume: sfx == Sfx.lift ? 0.6 : 1.0)
          .then((_) {}, onError: (_) {}),
    );
  }

  @override
  void haptic(Haptic kind) {
    if (!_settings().vibrationEnabled) return;
    unawaited(
      switch (kind) {
        Haptic.light => HapticFeedback.lightImpact(),
        Haptic.medium => HapticFeedback.mediumImpact(),
        Haptic.success => HapticFeedback.heavyImpact(),
      }.catchError((_) {}),
    );
  }

  @override
  void setMusicEnabled(bool enabled) {
    _musicWanted = enabled;
    _syncMusic();
  }

  void _syncMusic() {
    final m = _music;
    if (m == null) return;
    final shouldPlay = _musicWanted && _appActive;
    unawaited((shouldPlay ? m.resume() : m.pause()).catchError((_) {}));
  }

  @override
  void onAppPaused() {
    _appActive = false;
    _syncMusic();
  }

  @override
  void onAppResumed() {
    _appActive = true;
    _syncMusic();
  }

  @override
  Future<void> dispose() async {
    for (final p in _pools.values) {
      await p.dispose();
    }
    _pools.clear();
    await _music?.dispose();
    _music = null;
  }
}

/// Overridden in main() with an initialized [AudioPlayersService].
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = SilentAudioService();
  ref.onDispose(service.dispose);
  return service;
});

/// Keeps the music player in sync with the music setting.
final musicSyncProvider = Provider<void>((ref) {
  final enabled = ref.watch(settingsProvider.select((s) => s.musicEnabled));
  ref.read(audioServiceProvider).setMusicEnabled(enabled);
});
