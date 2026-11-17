import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/game/data/progress_repository.dart';
import '../features/game/presentation/screens/game_screen.dart';
import '../features/game/presentation/screens/level_selection_screen.dart';
import '../features/home/presentation/home_screen.dart';

CustomTransitionPage<void> _fade(GoRouterState state, Widget child) =>
    CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, anim, _, child) =>
          FadeTransition(opacity: anim, child: child),
    );

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => _fade(state, const HomeScreen()),
      ),
      GoRoute(
        path: '/levels',
        pageBuilder: (context, state) =>
            _fade(state, const LevelSelectionScreen()),
      ),
      GoRoute(
        path: '/game/:level',
        // Locked or malformed levels can never be opened directly.
        redirect: (context, state) {
          final id = int.tryParse(state.pathParameters['level'] ?? '');
          if (id == null || !ref.read(progressProvider).isUnlocked(id))
            return '/levels';
          return null;
        },
        pageBuilder: (context, state) => _fade(
          state,
          GameScreen(levelId: int.parse(state.pathParameters['level']!)),
        ),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
