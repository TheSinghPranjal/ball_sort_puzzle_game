import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/game_constants.dart';
import '../../../../shared/audio/audio_service.dart';
import '../../../../storage/local_storage_service.dart';
import '../../data/level_repository.dart';
import '../../data/progress_repository.dart';
import '../../domain/models/ball.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/level_config.dart';
import '../../domain/models/tube.dart';
import '../../domain/services/game_rules_service.dart';
import '../../domain/services/level_generator_service.dart';

/// Why a power-up request was refused (lets the UI explain it).
enum PowerUpResult { applied, unavailable, noUsesLeft, nothingToUndo, busy }

/// Owns every game state transition. Each transition produces a complete,
/// consistent [GameState] in one assignment, so animations (which only read
/// [GameState.events]) can never corrupt the model.
class GameController extends Notifier<GameState?> {
  static const rules = GameRulesService();

  int _seq = 0;
  int _session = 0;
  int _loadToken = 0;
  Timer? _timer;
  final _pauseReasons = <String>{};

  @override
  GameState? build() {
    ref.onDispose(() => _timer?.cancel());
    return null;
  }

  AudioService get _audio => ref.read(audioServiceProvider);
  LocalStorageService get _storage => ref.read(localStorageProvider);

  // ---------------------------------------------------------------------------
  // Level lifecycle
  // ---------------------------------------------------------------------------

  /// Loads [levelId]. When [resume] is true and a saved in-progress game for
  /// this level exists, it is restored exactly.
  Future<void> startLevel(int levelId, {bool resume = true}) async {
    final token = ++_loadToken;
    final level = await ref.read(levelRepositoryProvider).getLevel(levelId);
    if (token != _loadToken) return; // superseded by a newer load
    _timer?.cancel();
    _pauseReasons.clear();
    state = (resume ? _restore(level) : null) ?? _fresh(level);
    if (!resume) _clearSave();
    unawaited(ref.read(progressProvider.notifier).markPlayed(levelId));
    _startTimer();
    _persist();
  }

  Future<void> nextLevel() async {
    final s = state;
    if (s == null) return;
    final next = s.currentLevel + 1;
    if (next > GameConstants.totalLevelCount) return;
    await startLevel(next, resume: false);
  }

  /// Restores the original arrangement, move count, tube count, timer and
  /// power-ups for this level. Player progress is untouched.
  void restart() {
    final s = state;
    if (s == null) return;
    _timer?.cancel();
    state = _fresh(s.level).copyWith(isPaused: _pauseReasons.isNotEmpty);
    _audio.play(Sfx.tap);
    _startTimer();
    _persist();
  }

  GameState _fresh(LevelConfig level) {
    final tubes = level.buildTubes();
    return GameState(
      level: level,
      tubes: tubes,
      revealedBallIds: _reveal(level, const {}, tubes),
      undoRemaining: level.usesFor(PowerUpType.undo),
      shuffleRemaining: level.usesFor(PowerUpType.shuffle),
      addTubeRemaining: level.usesFor(PowerUpType.addTube),
      remainingSeconds: level.timeLimitSeconds,
      sessionId: ++_session,
      events: [BoardResetEvent(++_seq)],
    );
  }

  /// Mystery levels: reveals the top ball of every tube, every ball of a
  /// completed tube, or everything when [all] is set.
  static Set<int> _reveal(
    LevelConfig level,
    Set<int> revealed,
    List<Tube> tubes, {
    bool all = false,
  }) {
    if (!level.mystery) return const {};
    final out = {...revealed};
    for (var i = 0; i < tubes.length; i++) {
      final t = tubes[i];
      if (t.isEmpty) continue;
      if (all || rules.isTubeComplete(tubes, i)) {
        out.addAll(t.balls.map((b) => b.id));
      } else {
        out.add(t.topBall!.id);
      }
    }
    return out;
  }

  // ---------------------------------------------------------------------------
  // Input
  // ---------------------------------------------------------------------------

  void tapTube(int index) {
    final s = state;
    if (s == null || !s.canInteract || s.isAnimating) return;
    if (index < 0 || index >= s.tubes.length) return;
    final selected = s.selectedTubeIndex;

    if (selected == null) {
      if (s.tubes[index].isEmpty) return; // nothing to pick up
      state = s.copyWith(selectedTubeIndex: index);
      _audio.play(Sfx.select);
      return;
    }

    if (selected == index) {
      state = s.copyWith(selectedTubeIndex: null); // put the ball back
      _audio.play(Sfx.tap);
      return;
    }

    if (rules.canMove(s.tubes, selected, index)) {
      _commitMove(selected, index);
      return;
    }

    // Invalid destination: shake it. If it holds balls, the selection switches
    // to it so the player can continue from there.
    _audio.play(Sfx.invalid);
    _audio.haptic(Haptic.light);
    state = s.copyWith(
      selectedTubeIndex: s.tubes[index].isEmpty ? selected : index,
      events: _withEvent(s, InvalidMoveEvent(++_seq, tubeIndex: index)),
    );
  }

  void _commitMove(int from, int to) {
    final s = state!;
    final count = rules.movableCount(
      s.tubes,
      from,
      to,
      canTake: s.level.mystery ? (b) => !s.isHidden(b.id) : null,
    );
    final res = rules.applyBulkMove(s.tubes, from, to, count: count);
    final tubes = res.tubes;
    // Top-most ball first, so the flight starts with the one the player lifted.
    final moved = res.moved;
    final ball = moved.first;
    final moves = s.moveCount + 1;
    final solved = rules.isSolved(tubes);
    var events = _withEvent(
      s,
      BallMovedEvent(
        ++_seq,
        from: from,
        to: to,
        ballId: ball.id,
        colorId: ball.colorId,
        ballIds: [for (final b in moved) b.id],
      ),
    );
    if (rules.isTubeComplete(tubes, to) && tubes[to].isFull) {
      events = [...events, TubeCompletedEvent(++_seq, tubeIndex: to)];
    }
    final stars = solved ? s.level.starsFor(moves) : 0;
    state = s.copyWith(
      tubes: tubes,
      selectedTubeIndex: null,
      moveCount: moves,
      undoHistory: _pushHistory(s),
      isAnimating: true,
      isLevelCompleted: solved,
      isStuck: !solved && !rules.hasAnyLegalMove(tubes),
      stars: stars,
      events: events,
      revealedBallIds: _reveal(s.level, s.revealedBallIds, tubes, all: solved),
    );
    _audio.play(Sfx.lift);
    _audio.haptic(Haptic.light);
    if (solved) {
      _timer?.cancel();
      _clearSave();
      unawaited(
        ref
            .read(progressProvider.notifier)
            .completeLevel(s.currentLevel, stars),
      );
    } else {
      _persist();
    }
  }

  /// Called by the board when the flight animation for [seq] ends (or when it
  /// is skipped). Safe to call repeatedly.
  void onAnimationComplete(int seq) {
    final s = state;
    if (s == null || !s.isAnimating) return;
    final last = s.events.whereType<BallMovedEvent>().lastOrNull;
    if (last != null && last.seq != seq) return;
    state = s.copyWith(isAnimating: false);
    _audio.play(Sfx.drop);
    if (s.isLevelCompleted) {
      _audio.play(Sfx.complete);
      _audio.haptic(Haptic.success);
    }
  }

  // ---------------------------------------------------------------------------
  // Power-ups
  // ---------------------------------------------------------------------------

  PowerUpResult undo() {
    final s = state;
    if (s == null || !s.canInteract) return PowerUpResult.busy;
    if (!s.level.availablePowerUps.contains(PowerUpType.undo)) {
      return PowerUpResult.unavailable;
    }
    if (s.undoHistory.isEmpty) return PowerUpResult.nothingToUndo;
    if (s.undoRemaining <= 0) return PowerUpResult.noUsesLeft;
    final snap = s.undoHistory.last;
    final flight = _singleBallDiff(s.tubes, snap.tubes);
    state = s.copyWith(
      tubes: snap.tubes,
      moveCount: snap.moveCount,
      undoHistory: s.undoHistory.sublist(0, s.undoHistory.length - 1),
      undoRemaining: s.undoRemaining - 1,
      selectedTubeIndex: null,
      isStuck: false,
      isAnimating: flight != null,
      events: _withEvent(s, flight ?? BoardResetEvent(++_seq)),
      revealedBallIds: _reveal(s.level, s.revealedBallIds, snap.tubes),
    );
    _audio.play(Sfx.undo);
    _persist();
    return PowerUpResult.applied;
  }

  /// Detects "one ball moved from A to B" between [now] and [before] so undo
  /// can animate the ball flying back.
  BoardEvent? _singleBallDiff(List<Tube> now, List<Tube> before) {
    if (now.length != before.length) return null;
    int? from, to;
    for (var i = 0; i < now.length; i++) {
      final d = now[i].balls.length - before[i].balls.length;
      if (d == 0) continue;
      if (d == 1 && from == null) {
        from = i;
      } else if (d == -1 && to == null) {
        to = i;
      } else {
        return null;
      }
    }
    if (from == null || to == null) return null;
    final ball = now[from].topBall!;
    if (before[to].topBall?.id != ball.id) return null;
    return BallMovedEvent(
      ++_seq,
      from: from,
      to: to,
      ballId: ball.id,
      colorId: ball.colorId,
      fromLifted: false,
    );
  }

  Future<PowerUpResult> shuffle({int? seed}) async {
    final s = state;
    if (s == null || !s.canInteract || s.isAnimating) return PowerUpResult.busy;
    if (!s.level.availablePowerUps.contains(PowerUpType.shuffle)) {
      return PowerUpResult.unavailable;
    }
    if (s.shuffleRemaining <= 0) return PowerUpResult.noUsesLeft;

    final balls = <Ball>[for (final t in s.tubes) ...t.balls];
    final colors = [for (final b in balls) b.colorId];
    final current = <List<int>>[];
    var k = 0;
    for (final t in s.tubes) {
      current.add([for (var i = 0; i < t.balls.length; i++) k++]);
    }
    final capacity = s.level.tubeCapacity;
    final useSeed = seed ?? math.Random().nextInt(1 << 31);

    state = s.copyWith(isBusy: true, selectedTubeIndex: null);
    final arrangement = await _runShuffle(
      ref.read(backgroundRunnerProvider),
      colors,
      current,
      capacity,
      useSeed,
    );
    final now = state;
    if (now == null || now.sessionId != s.sessionId || !now.isBusy)
      return PowerUpResult.busy;

    final tubes = [
      for (var i = 0; i < s.tubes.length; i++)
        s.tubes[i].copyWith(
          balls: [for (final idx in arrangement[i]) balls[idx]],
        ),
    ];
    state = now.copyWith(
      tubes: tubes,
      undoHistory: _pushHistory(s),
      shuffleRemaining: s.shuffleRemaining - 1,
      isBusy: false,
      isStuck: !rules.hasAnyLegalMove(tubes),
      events: _withEvent(now, ShuffledEvent(++_seq)),
      revealedBallIds: _reveal(s.level, now.revealedBallIds, tubes),
    );
    _audio.play(Sfx.shuffle);
    _persist();
    return PowerUpResult.applied;
  }

  PowerUpResult addTube() {
    final s = state;
    if (s == null || !s.canInteract || s.isAnimating) return PowerUpResult.busy;
    if (!s.level.availablePowerUps.contains(PowerUpType.addTube)) {
      return PowerUpResult.unavailable;
    }
    if (s.addTubeRemaining <= 0) return PowerUpResult.noUsesLeft;
    final id = s.tubes.map((t) => t.id).reduce(math.max) + 1;
    final tube = Tube(
      id: id,
      balls: const [],
      capacity: s.level.tubeCapacity,
      isExtraTube: true,
    );
    state = s.copyWith(
      tubes: [...s.tubes, tube],
      undoHistory: _pushHistory(s),
      addTubeRemaining: s.addTubeRemaining - 1,
      isStuck: false,
      events: _withEvent(s, TubeAddedEvent(++_seq, tubeId: id)),
    );
    _audio.play(Sfx.addTube);
    _persist();
    return PowerUpResult.applied;
  }

  // ---------------------------------------------------------------------------
  // Pause / timer
  // ---------------------------------------------------------------------------

  /// Pauses for [reason] ('settings', 'lifecycle', ...). The game resumes only
  /// when every reason has been cleared.
  void setPaused(String reason, bool paused) {
    paused ? _pauseReasons.add(reason) : _pauseReasons.remove(reason);
    final s = state;
    if (s == null) return;
    final p = _pauseReasons.isNotEmpty;
    if (s.isPaused != p) state = s.copyWith(isPaused: p);
    if (p) _persist();
  }

  void _startTimer() {
    _timer?.cancel();
    final s = state;
    if (s == null ||
        s.remainingSeconds == null ||
        s.isLevelCompleted ||
        s.isTimeUp)
      return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  /// Advances the countdown by one second (public for tests).
  void tick() {
    final s = state;
    if (s == null || s.remainingSeconds == null) return;
    if (s.isPaused || s.isLevelCompleted || s.isTimeUp) return;
    final left = s.remainingSeconds! - 1;
    if (left <= 0) {
      _timer?.cancel();
      state = s.copyWith(
        remainingSeconds: 0,
        isTimeUp: true,
        selectedTubeIndex: null,
      );
      _audio.play(Sfx.invalid);
      _clearSave();
    } else {
      state = s.copyWith(remainingSeconds: left);
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers / persistence
  // ---------------------------------------------------------------------------

  List<GameSnapshot> _pushHistory(GameState s) {
    final h = [
      ...s.undoHistory,
      GameSnapshot(tubes: s.tubes, moveCount: s.moveCount),
    ];
    return h.length > GameConstants.maxUndoHistory
        ? h.sublist(h.length - GameConstants.maxUndoHistory)
        : h;
  }

  List<BoardEvent> _withEvent(GameState s, BoardEvent e) {
    final list = [...s.events, e];
    return list.length > 6 ? list.sublist(list.length - 6) : list;
  }

  void _persist() {
    final s = state;
    if (s == null || s.isLevelCompleted || s.isTimeUp) return;
    final json = s.toSaveJson();
    final history = json['history'] as List;
    if (history.length > 60)
      json['history'] = history.sublist(history.length - 60);
    unawaited(_storage.writeJson(LocalStorageService.savedGameKey, json));
  }

  void _clearSave() =>
      unawaited(_storage.remove(LocalStorageService.savedGameKey));

  /// Saved level id, if an in-progress game exists.
  int? savedLevelId() =>
      _storage.readJson(LocalStorageService.savedGameKey)?['level'] as int?;

  GameState? _restore(LevelConfig level) {
    final j = _storage.readJson(LocalStorageService.savedGameKey);
    if (j == null || j['level'] != level.levelId) return null;
    try {
      final tubes = [
        for (final t in j['tubes'] as List)
          Tube.fromJson(Map<String, dynamic>.from(t as Map)),
      ];
      final history = [
        for (final h in j['history'] as List)
          GameSnapshot.fromJson(Map<String, dynamic>.from(h as Map)),
      ];
      if (!_isValidBoard(level, tubes) ||
          !history.every((h) => _isValidBoard(level, h.tubes))) {
        return null;
      }
      return GameState(
        level: level,
        tubes: tubes,
        moveCount: j['moves'] as int,
        undoHistory: history,
        undoRemaining: j['undo'] as int,
        shuffleRemaining: j['shuffle'] as int,
        addTubeRemaining: j['add'] as int,
        remainingSeconds: level.timeLimitSeconds == null
            ? null
            : j['time'] as int?,
        isStuck: !rules.isSolved(tubes) && !rules.hasAnyLegalMove(tubes),
        sessionId: ++_session,
        events: [BoardResetEvent(++_seq)],
        revealedBallIds: _reveal(level, {
          for (final id in (j['rev'] as List? ?? const [])) id as int,
        }, tubes),
      );
    } catch (_) {
      return null; // corrupted save: start fresh rather than crash
    }
  }

  /// A restored board must contain exactly the level's balls and respect
  /// capacity, or it is discarded.
  static bool _isValidBoard(LevelConfig level, List<Tube> tubes) {
    if (tubes.length < level.tubeCount ||
        tubes.length > level.tubeCount + level.addTubeUses) {
      return false;
    }
    final expected = <int, int>{};
    for (final t in level.initialTubeArrangement) {
      for (final c in t) {
        expected[c] = (expected[c] ?? 0) + 1;
      }
    }
    final actual = <int, int>{};
    final ids = <int>{};
    for (final t in tubes) {
      if (t.capacity != level.tubeCapacity || t.balls.length > t.capacity)
        return false;
      for (final b in t.balls) {
        if (!ids.add(b.id)) return false;
        actual[b.colorId] = (actual[b.colorId] ?? 0) + 1;
      }
    }
    if (actual.length != expected.length) return false;
    for (final e in expected.entries) {
      if (actual[e.key] != e.value) return false;
    }
    return true;
  }
}

/// Static scope so the closure sent to the isolate captures only plain data.
Future<List<List<int>>> _runShuffle(
  BackgroundRunner runner,
  List<int> colors,
  List<List<int>> current,
  int capacity,
  int seed,
) => runner.run(() => computeShuffle(colors, current, capacity, seed));

/// Top-level so it can run inside an isolate.
List<List<int>> computeShuffle(
  List<int> colorsByToken,
  List<List<int>> current,
  int capacity,
  int seed,
) => const LevelGeneratorService().shuffleSolvable(
  colorsByToken: colorsByToken,
  current: current,
  capacity: capacity,
  seed: seed,
);

final gameControllerProvider = NotifierProvider<GameController, GameState?>(
  GameController.new,
);
