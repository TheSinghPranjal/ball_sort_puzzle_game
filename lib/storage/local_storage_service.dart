import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin JSON wrapper over SharedPreferences. All reads are synchronous (the
/// instance is loaded once at startup); writes are fire-and-forget async.
class LocalStorageService {
  LocalStorageService(this._prefs);

  final SharedPreferences _prefs;

  static const progressKey = 'progress.v1';
  static const settingsKey = 'settings.v1';
  static const savedGameKey = 'saved_game.v1';

  Map<String, dynamic>? readJson(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } on FormatException {
      return null; // corrupted entry: behave as if absent
    }
  }

  Future<void> writeJson(String key, Map<String, dynamic> value) =>
      _prefs.setString(key, jsonEncode(value));

  Future<void> remove(String key) => _prefs.remove(key);
}

/// Overridden in main() with the loaded instance.
final localStorageProvider = Provider<LocalStorageService>(
  (ref) => throw UnimplementedError('localStorageProvider must be overridden'),
);
