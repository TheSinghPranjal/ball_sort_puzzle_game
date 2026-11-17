import 'level_config.dart';
import 'tube.dart';

/// State that undo can restore exactly.
class GameSnapshot {
  GameSnapshot({required List<Tube> tubes, required this.moveCount})
    : tubes = List.unmodifiable(tubes);

  final List<Tube> tubes;
  final int moveCount;

  Map<String, dynamic> toJson() => {
    'm': moveCount,
    't': [for (final t in tubes) t.toJson()],
  };

  factory GameSnapshot.fromJson(Map<String, dynamic> json) => GameSnapshot(
    moveCount: json['m'] as int,
    tubes: [
      for (final t in json['t'] as List)
        Tube.fromJson(Map<String, dynamic>.from(t as Map)),
    ],
  );
}

/// One-shot visual events the board animates. [seq] is unique and increasing
/// so the UI can tell a new event from a rebuild.
sealed class BoardEvent {
  const BoardEvent(this.seq);
  final int seq;
}

/// A ball flew from [from] to [to]. The model is already updated; the UI only
/// animates. [fromLifted] says whether it starts from the "selected" height.
class BallMovedEvent extends BoardEvent {
  const BallMovedEvent(
    super.seq, {
    required this.from,
    required this.to,
    required this.ballId,
    required this.colorId,
    this.fromLifted = true,
    List<int>? ballIds,
  }) : ballIds = ballIds ?? const [];
  final int from;
  final int to;
  final int ballId;

  /// Every ball that travelled, top-most first (empty means just [ballId]).
  final List<int> ballIds;
  List<int> get allBallIds => ballIds.isEmpty ? [ballId] : ballIds;
  final int colorId;
  final bool fromLifted;
}

class InvalidMoveEvent extends BoardEvent {
  const InvalidMoveEvent(super.seq, {required this.tubeIndex});
  final int tubeIndex;
}

class ShuffledEvent extends BoardEvent {
  const ShuffledEvent(super.seq);
}

class TubeAddedEvent extends BoardEvent {
  const TubeAddedEvent(super.seq, {required this.tubeId});
  final int tubeId;
}

/// A non-move board reset (undo of shuffle/add-tube, restart, level load).
class BoardResetEvent extends BoardEvent {
  const BoardResetEvent(super.seq);
}

class TubeCompletedEvent extends BoardEvent {
  const TubeCompletedEvent(super.seq, {required this.tubeIndex});
  final int tubeIndex;
}

class GameState {
  GameState({
    required this.level,
    required List<Tube> tubes,
    this.selectedTubeIndex,
    this.moveCount = 0,
    List<GameSnapshot> undoHistory = const [],
    required this.undoRemaining,
    required this.shuffleRemaining,
    required this.addTubeRemaining,
    this.isLevelCompleted = false,
    this.isAnimating = false,
    this.isPaused = false,
    this.isBusy = false,
    this.isStuck = false,
    this.remainingSeconds,
    this.isTimeUp = false,
    this.stars = 0,
    this.events = const [],
    this.sessionId = 0,
    Set<int> revealedBallIds = const {},
  }) : tubes = List.unmodifiable(tubes),
       undoHistory = List.unmodifiable(undoHistory),
       revealedBallIds = Set.unmodifiable(revealedBallIds);

  final LevelConfig level;
  final List<Tube> tubes;
  final int? selectedTubeIndex;
  final int moveCount;
  final List<GameSnapshot> undoHistory;
  final int undoRemaining;
  final int shuffleRemaining;
  final int addTubeRemaining;
  final bool isLevelCompleted;

  /// True while a ball flight is playing; input is gated on this.
  final bool isAnimating;

  /// Settings open / app backgrounded: timer stops, input blocked.
  final bool isPaused;

  /// A background computation (e.g. solvable shuffle) is running.
  final bool isBusy;

  /// No legal move exists.
  final bool isStuck;
  final int? remainingSeconds;
  final bool isTimeUp;
  final int stars;

  /// Recent board events (latest last) for the UI to animate.
  final List<BoardEvent> events;

  /// Changes on every level load / restart so the UI can rebuild the board.
  final int sessionId;

  /// Mystery levels: ids of balls the player has seen. Once seen, a ball
  /// stays visible (undo/shuffle never re-hide it).
  final Set<int> revealedBallIds;

  /// True when [ballId] should be drawn as a "?" ball.
  bool isHidden(int ballId) =>
      level.mystery && !revealedBallIds.contains(ballId);

  int get currentLevel => level.levelId;
  bool get canInteract =>
      !isLevelCompleted && !isPaused && !isBusy && !isTimeUp;
  BoardEvent? get lastEvent => events.isEmpty ? null : events.last;
  int get extraTubeCount => tubes.where((t) => t.isExtraTube).length;

  static const _unset = Object();

  GameState copyWith({
    List<Tube>? tubes,
    Object? selectedTubeIndex = _unset,
    int? moveCount,
    List<GameSnapshot>? undoHistory,
    int? undoRemaining,
    int? shuffleRemaining,
    int? addTubeRemaining,
    bool? isLevelCompleted,
    bool? isAnimating,
    bool? isPaused,
    bool? isBusy,
    bool? isStuck,
    Object? remainingSeconds = _unset,
    bool? isTimeUp,
    int? stars,
    List<BoardEvent>? events,
    int? sessionId,
    Set<int>? revealedBallIds,
  }) {
    return GameState(
      level: level,
      tubes: tubes ?? this.tubes,
      selectedTubeIndex: identical(selectedTubeIndex, _unset)
          ? this.selectedTubeIndex
          : selectedTubeIndex as int?,
      moveCount: moveCount ?? this.moveCount,
      undoHistory: undoHistory ?? this.undoHistory,
      undoRemaining: undoRemaining ?? this.undoRemaining,
      shuffleRemaining: shuffleRemaining ?? this.shuffleRemaining,
      addTubeRemaining: addTubeRemaining ?? this.addTubeRemaining,
      isLevelCompleted: isLevelCompleted ?? this.isLevelCompleted,
      isAnimating: isAnimating ?? this.isAnimating,
      isPaused: isPaused ?? this.isPaused,
      isBusy: isBusy ?? this.isBusy,
      isStuck: isStuck ?? this.isStuck,
      remainingSeconds: identical(remainingSeconds, _unset)
          ? this.remainingSeconds
          : remainingSeconds as int?,
      isTimeUp: isTimeUp ?? this.isTimeUp,
      stars: stars ?? this.stars,
      events: events ?? this.events,
      sessionId: sessionId ?? this.sessionId,
      revealedBallIds: revealedBallIds ?? this.revealedBallIds,
    );
  }

  /// Persisted form (animation/session flags are intentionally dropped).
  Map<String, dynamic> toSaveJson() => {
    'level': level.levelId,
    'tubes': [for (final t in tubes) t.toJson()],
    'moves': moveCount,
    'history': [for (final s in undoHistory) s.toJson()],
    'undo': undoRemaining,
    'shuffle': shuffleRemaining,
    'add': addTubeRemaining,
    'time': remainingSeconds,
    'rev': revealedBallIds.toList(),
  };
}
