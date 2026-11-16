import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/audio/audio_service.dart';
import 'router.dart';
import 'theme.dart';

class BallSortApp extends ConsumerStatefulWidget {
  const BallSortApp({super.key});

  @override
  ConsumerState<BallSortApp> createState() => _BallSortAppState();
}

class _BallSortAppState extends ConsumerState<BallSortApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final audio = ref.read(audioServiceProvider);
    state == AppLifecycleState.resumed ? audio.onAppResumed() : audio.onAppPaused();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(musicSyncProvider);
    return MaterialApp.router(
      title: 'Ball Sort Puzzle',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
