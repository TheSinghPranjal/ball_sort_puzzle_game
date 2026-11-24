import 'package:ball_sort_puzzle_game/features/game/data/level_repository.dart';
import 'package:ball_sort_puzzle_game/features/game/domain/models/ball.dart';
import 'package:ball_sort_puzzle_game/features/game/domain/models/tube.dart';
import 'package:ball_sort_puzzle_game/shared/audio/audio_service.dart';
import 'package:ball_sort_puzzle_game/storage/local_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Builds tubes from color lists (bottom -> top) with unique ball ids.
List<Tube> tubes(List<List<int>> colors, {int capacity = 4}) {
  var id = 0;
  return [
    for (var i = 0; i < colors.length; i++)
      Tube(
        id: i,
        capacity: capacity,
        balls: [for (final c in colors[i]) Ball(id: id++, colorId: c)],
      ),
  ];
}

Future<List<Override>> testOverrides({
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final p = await SharedPreferences.getInstance();
  return [
    localStorageProvider.overrideWithValue(LocalStorageService(p)),
    audioServiceProvider.overrideWithValue(SilentAudioService()),
    backgroundRunnerProvider.overrideWithValue(const SyncRunner()),
  ];
}

Future<ProviderContainer> testContainer({
  Map<String, Object> prefs = const {},
}) async {
  final c = ProviderContainer(overrides: await testOverrides(prefs: prefs));
  return c;
}
