import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/game_constants.dart';
import '../../../../shared/animations/confetti_overlay.dart';
import '../../../../shared/audio/audio_service.dart';
import '../../../../shared/widgets/space_background.dart';
import '../../data/progress_repository.dart';
import '../../domain/models/level_config.dart';
import '../controllers/game_controller.dart';
import '../widgets/game_board.dart';
import '../widgets/game_dialogs.dart';
import '../widgets/game_header.dart';
import '../widgets/level_complete_popup.dart';
import '../widgets/power_up_bar.dart';
import '../widgets/settings_popup.dart';
import '../widgets/tutorial_overlay.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key, required this.levelId});
  final int levelId;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with WidgetsBindingObserver {
  final _buttonKeys = {for (final t in PowerUpType.values) t: GlobalKey()};
  bool _loading = true;
  bool _popupOpen = false;

  GameController get _c => ref.read(gameControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load(widget.levelId));
  }

  @override
  void didUpdateWidget(GameScreen old) {
    super.didUpdateWidget(old);
    if (old.levelId != widget.levelId) _load(widget.levelId);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pausing also persists the current board.
    _c.setPaused('lifecycle', state != AppLifecycleState.resumed);
  }

  Future<void> _load(int id, {bool resume = true}) async {
    setState(() => _loading = true);
    await _c.startLevel(id, resume: resume);
    if (mounted) setState(() => _loading = false);
    await _maybeSpecialIntro();
  }

  /// Special levels open with a short intro, like a level-start card.
  Future<void> _maybeSpecialIntro() async {
    final s = ref.read(gameControllerProvider);
    if (!mounted ||
        s == null ||
        !s.level.isSpecial ||
        s.moveCount > 0 ||
        s.undoHistory.isNotEmpty)
      return;
    _c.setPaused('dialog', true);
    await _guardPopup(
      () => showSpecialLevelPopup(
        context,
        capacity: s.level.tubeCapacity,
        colors: s.level.colorCount,
        mystery: s.level.mystery,
      ),
    );
    _c.setPaused('dialog', false);
  }

  Future<T?> _guardPopup<T>(Future<T?> Function() show) async {
    if (_popupOpen) return null;
    _popupOpen = true;
    try {
      return await show();
    } finally {
      _popupOpen = false;
    }
  }

  Future<void> _restart() async {
    ref.read(audioServiceProvider).play(Sfx.tap);
    _c.setPaused('dialog', true);
    final ok = await _guardPopup(() => confirmRestart(context)) ?? false;
    _c.setPaused('dialog', false);
    if (ok) _c.restart();
  }

  Future<void> _settings() async {
    ref.read(audioServiceProvider).play(Sfx.tap);
    _c.setPaused('settings', true);
    final action = await _guardPopup(
      () => showSettingsPopup(context, inGame: true),
    );
    _c.setPaused('settings', false);
    if (!mounted) return;
    switch (action) {
      case SettingsAction.restart:
        await _restart();
      case SettingsAction.exitHome:
        context.go('/');
      case SettingsAction.resume || null:
        break;
    }
  }

  Future<void> _onCompleted(int session) async {
    final s = ref.read(gameControllerProvider);
    if (s == null) return;
    if (s.level.tutorial != TutorialType.none) {
      unawaited(
        ref
            .read(progressProvider.notifier)
            .completeTutorial(s.level.tutorial.name),
      );
    }
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    final now = ref.read(gameControllerProvider);
    if (!mounted || now == null || now.sessionId != session) return;
    final hasNext = s.currentLevel < GameConstants.totalLevelCount;
    final action = await _guardPopup(
      () => showLevelCompletePopup(
        context,
        levelId: s.currentLevel,
        moves: s.moveCount,
        stars: s.stars,
        moveTarget: s.level.moveTarget,
        hasNext: hasNext,
      ),
    );
    if (!mounted) return;
    ref.read(audioServiceProvider).play(Sfx.tap);
    switch (action) {
      case LevelCompleteAction.next:
        setState(() => _loading = true);
        await _c.nextLevel();
        if (mounted) setState(() => _loading = false);
        await _maybeSpecialIntro();
      case LevelCompleteAction.replay:
        await _load(s.currentLevel, resume: false);
      case LevelCompleteAction.home || null:
        if (mounted) context.go('/');
    }
  }

  Future<void> _onTimeUp() async {
    final action = await _guardPopup(() => showTimeUpPopup(context));
    if (!mounted) return;
    if (action == TimeUpAction.home) {
      context.go('/');
    } else {
      _c.restart();
    }
  }

  Future<void> _onStuck() async {
    final s = ref.read(gameControllerProvider);
    if (s == null) return;
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    final p = s.level.availablePowerUps;
    final action = await _guardPopup(
      () => showStuckPopup(
        context,
        canUndo:
            p.contains(PowerUpType.undo) &&
            s.undoRemaining > 0 &&
            s.undoHistory.isNotEmpty,
        canShuffle: p.contains(PowerUpType.shuffle) && s.shuffleRemaining > 0,
        canAddTube: p.contains(PowerUpType.addTube) && s.addTubeRemaining > 0,
      ),
    );
    switch (action) {
      case StuckAction.undo:
        _c.undo();
      case StuckAction.shuffle:
        await _c.shuffle();
      case StuckAction.addTube:
        _c.addTube();
      case StuckAction.restart:
        _c.restart();
      case StuckAction.dismiss || null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int?>(
      gameControllerProvider.select(
        (s) => s != null && s.isLevelCompleted && !s.isAnimating
            ? s.sessionId
            : null,
      ),
      (prev, next) {
        if (next != null && prev != next) _onCompleted(next);
      },
    );
    ref.listen<int?>(
      gameControllerProvider.select(
        (s) => s != null && s.isTimeUp ? s.sessionId : null,
      ),
      (prev, next) {
        if (next != null && prev != next) _onTimeUp();
      },
    );
    ref.listen<(int, int)?>(
      gameControllerProvider.select(
        (s) => s != null && s.isStuck && !s.isAnimating && !s.isLevelCompleted
            ? (s.sessionId, s.moveCount)
            : null,
      ),
      (prev, next) {
        if (next != null && prev != next) _onStuck();
      },
    );

    final session = ref.watch(
      gameControllerProvider.select((s) => s?.sessionId),
    );
    final hasState = session != null;
    final celebrate = ref.watch(
      gameControllerProvider.select(
        (s) => s != null && s.isLevelCompleted && !s.isAnimating,
      ),
    );
    final busy = ref.watch(
      gameControllerProvider.select((s) => s?.isBusy ?? false),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_popupOpen) context.go('/');
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SpaceBackground(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, c) {
                final shortest = math.min(c.maxWidth, c.maxHeight);
                final buttonSize = (shortest * 0.14).clamp(44.0, 72.0);
                final headerSize = (buttonSize * 0.75).clamp(40.0, 56.0);
                return Stack(
                  children: [
                    Column(
                      children: [
                        GameHeader(
                          onRestart: _restart,
                          onSettings: _settings,
                          buttonSize: headerSize,
                        ),
                        const MechanicBanner(),
                        Expanded(
                          child: !hasState || _loading
                              ? const Center(child: CircularProgressIndicator())
                              : KeyedSubtree(
                                  key: ValueKey('board-$session'),
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0, end: 1),
                                    duration: const Duration(milliseconds: 420),
                                    curve: Curves.easeOutCubic,
                                    builder: (context, v, child) => Opacity(
                                      opacity: v,
                                      child: Transform.scale(
                                        scale: 0.92 + 0.08 * v,
                                        child: child,
                                      ),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.fromLTRB(4, 40, 4, 8),
                                      child: GameBoard(),
                                    ),
                                  ),
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16, top: 8),
                          child: SizedBox(
                            height: buttonSize + 26,
                            child: hasState
                                ? PowerUpBar(
                                    buttonKeys: _buttonKeys,
                                    buttonSize: buttonSize,
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ),
                    Positioned.fill(child: ConfettiOverlay(play: celebrate)),
                    if (busy)
                      const Positioned.fill(
                        child: ColoredBox(
                          color: Color(0x33000000),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                    if (hasState && !_loading)
                      Positioned.fill(
                        child: PowerUpTutorialOverlay(buttonKeys: _buttonKeys),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
