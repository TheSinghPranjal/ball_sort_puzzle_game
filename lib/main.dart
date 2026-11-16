import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'features/settings/settings_repository.dart';
import 'shared/audio/audio_service.dart';
import 'storage/local_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        localStorageProvider.overrideWithValue(LocalStorageService(prefs)),
        audioServiceProvider.overrideWith((ref) {
          final service = AudioPlayersService(() => ref.read(settingsProvider));
          service.init();
          ref.onDispose(service.dispose);
          return service;
        }),
      ],
      child: const BallSortApp(),
    ),
  );
}
