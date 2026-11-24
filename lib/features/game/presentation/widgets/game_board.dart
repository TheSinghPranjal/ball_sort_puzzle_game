import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/game_state.dart';
import '../../domain/services/game_rules_service.dart';
import '../controllers/game_controller.dart';
import 'board_layout.dart';
import 'glossy_ball_widget.dart';
import 'tube_view.dart';
import 'tutorial_overlay.dart';

/// Lays out the tubes responsively and plays board animations driven by
/// [GameState.events]. The model is already final when an event arrives, so
/// interrupting or skipping an animation can never corrupt game state.
class GameBoard extends ConsumerStatefulWidget {
  const GameBoard({super.key});

  @override
  ConsumerState<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends ConsumerState<GameBoard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flightCtrl;

  static const _staggerMs = 95.0;
  double _flightBaseMs = 460;
  BallMovedEvent? _flight;
  int _handledSeq = 0;
  int _popSeq = 0;
  int? _enteringTubeId;
  final _shakeSeqs = <int, int>{};
  final _celebrateSeqs = <int, int>{};
  final _pendingCelebrations = <int, int>{};
  BoardLayout? _layout;

  GameController get _controller => ref.read(gameControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    _flightCtrl = AnimationController(vsync: this)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _finishFlight();
      });
    final s = ref.read(gameControllerProvider);
    if (s != null) {
      _handledSeq = s.lastEvent?.seq ?? 0;
      final reset = s.events.whereType<BoardResetEvent>().lastOrNull;
      _popSeq = reset?.seq ?? 0;
      if (s.isAnimating) {
        // A flight was in progress when this board was (re)built: settle it.
        final last = s.events.whereType<BallMovedEvent>().lastOrNull;
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _controller.onAnimationComplete(last?.seq ?? -1),
        );
      }
    }
  }

  @override
  void dispose() {
    _flightCtrl.dispose();
    super.dispose();
  }

  void _onEvents(List<BoardEvent> events) {
    final fresh = events.where((e) => e.seq > _handledSeq).toList();
    if (fresh.isEmpty) return;
    _handledSeq = fresh.last.seq;
    {
      for (final e in fresh) {
        switch (e) {
          case BallMovedEvent():
            _startFlight(e);
          case InvalidMoveEvent(:final tubeIndex):
            _shakeSeqs[tubeIndex] = e.seq;
          case ShuffledEvent():
          case BoardResetEvent():
            _finishFlight(notify: false);
            _popSeq = e.seq;
          case TubeAddedEvent(:final tubeId):
            _enteringTubeId = tubeId;
          case TubeCompletedEvent(:final tubeIndex):
            if (_flight != null) {
              _pendingCelebrations[tubeIndex] = e.seq;
            } else {
              _celebrateSeqs[tubeIndex] = e.seq;
            }
        }
      }
    }
    if (mounted) setState(() {});
  }

  void _startFlight(BallMovedEvent e) {
    if (_flight != null) _finishFlight();
    _flight = e;
    final l = _layout;
    final st = ref.read(gameControllerProvider);
    var ms = 460.0;
    if (l != null &&
        st != null &&
        e.from < l.columns.length &&
        e.to < l.columns.length) {
      // Duration follows the real path length (rise + arc + drop), so short
      // hops stay snappy and long ones don't look rushed.
      final srcSlot = st.tubes[e.from].balls.length + e.allBallIds.length - 1;
      final destSlot = math.max(0, st.tubes[e.to].balls.length - 1);
      final path = _FlightPath.build(
        l,
        e.from,
        e.to,
        e.fromLifted ? l.liftedCenter(e.from) : l.slotCenter(e.from, srcSlot),
        l.slotCenter(e.to, destSlot),
      );
      ms = (300 + path.length / l.unit * 26).clamp(380, 760).toDouble();
    }
    _flightBaseMs = ms;
    final extra = (e.allBallIds.length - 1) * _staggerMs;
    _flightCtrl.duration = Duration(milliseconds: (ms + extra).round());
    _flightCtrl.forward(from: 0);
  }

  void _finishFlight({bool notify = true}) {
    final f = _flight;
    if (f == null) return;
    _flight = null;
    _flightCtrl.stop();
    if (mounted) {
      setState(() {
        _celebrateSeqs.addAll(_pendingCelebrations);
        _pendingCelebrations.clear();
      });
    }
    if (notify) _controller.onAnimationComplete(f.seq);
  }

  void _onTubeTap(int index) {
    // Fast players: land the current ball instantly, then handle the tap.
    if (_flight != null) _finishFlight();
    _controller.tapTube(index);
  }

  /// Position of the [k]-th travelling ball (0 = top-most) at overall
  /// animation progress [t]; later balls start a little after earlier ones.
  Offset? _flightPosition(GameState s, BoardLayout l, double t, int k) {
    final f = _flight;
    if (f == null || f.from >= s.tubes.length || f.to >= s.tubes.length)
      return null;
    final ids = f.allBallIds;
    final dest = s.tubes[f.to].balls.indexWhere((b) => b.id == ids[k]);
    if (dest < 0) return null;
    final total0 = _flightBaseMs + (ids.length - 1) * _staggerMs;
    final local = ((t * total0 - k * _staggerMs) / _flightBaseMs).clamp(
      0.0,
      1.0,
    );
    final srcIndex = s.tubes[f.from].balls.length + (ids.length - 1 - k);
    final a = (f.fromLifted && k == 0)
        ? l.liftedCenter(f.from)
        : l.slotCenter(f.from, srcIndex);
    final d = l.slotCenter(f.to, dest);
    final path = _FlightPath.build(l, f.from, f.to, a, d);
    return path.at(Curves.easeInOutCubic.transform(local));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<List<BoardEvent>?>(
      gameControllerProvider.select((s) => s?.events),
      (_, next) {
        if (next != null) _onEvents(next);
      },
    );
    final s = ref.watch(gameControllerProvider);
    if (s == null) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final l = BoardLayout.compute(
          size,
          s.tubes.length,
          s.level.tubeCapacity,
        );
        _layout = l;
        const rules = GameRulesService();
        final children = <Widget>[];
        for (var i = 0; i < s.tubes.length; i++) {
          final tube = s.tubes[i];
          final landing = _flight != null && _flight!.to == i;
          final complete =
              !landing && tube.isFull && rules.isTubeComplete(s.tubes, i);
          children.add(
            AnimatedPositioned(
              key: ValueKey('tube-${tube.id}'),
              duration: const Duration(milliseconds: 380),
              curve: Curves.easeOutCubic,
              left: l.columns[i].left,
              top: l.columns[i].top,
              width: l.columns[i].width,
              height: l.columns[i].height,
              child: TubeView(
                tube: tube,
                layout: l,
                selected: s.selectedTubeIndex == i,
                hiddenBallIds: landing ? _flight!.allBallIds.toSet() : const {},
                shakeSeq: _shakeSeqs[i] ?? 0,
                popSeq: _popSeq,
                celebrateSeq: _celebrateSeqs[i] ?? 0,
                animateEntrance: tube.id == _enteringTubeId,
                completeColorId: complete ? tube.topColor : null,
                hiddenIds: s.level.mystery
                    ? {
                        for (final b in tube.balls)
                          if (s.isHidden(b.id)) b.id,
                      }
                    : const {},
                onTap: () => _onTubeTap(i),
              ),
            ),
          );
        }
        if (_flight != null) {
          final colorId = _flight!.colorId;
          children.add(
            AnimatedBuilder(
              animation: _flightCtrl,
              builder: (context, _) {
                final widgets = <Widget>[];
                // Draw later balls first so the top-most ball stays in front.
                for (var k = _flight!.allBallIds.length - 1; k >= 0; k--) {
                  final p = _flightPosition(s, l, _flightCtrl.value, k);
                  if (p == null) continue;
                  widgets.add(
                    Positioned(
                      left: p.dx - l.unit / 2,
                      top: p.dy - l.unit / 2,
                      width: l.unit,
                      height: l.unit,
                      child: IgnorePointer(
                        child: GlossyBallWidget(
                          colorId: colorId,
                          diameter: l.unit,
                        ),
                      ),
                    ),
                  );
                }
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Positioned children need a bounded stack: fill the board.
                    const Positioned.fill(child: SizedBox.shrink()),
                    ...widgets,
                  ],
                );
              },
            ),
          );
        }
        children.add(Positioned.fill(child: BoardTutorialOverlay(layout: l)));
        return Stack(clipBehavior: Clip.none, children: children);
      },
    );
  }
}

/// Flight path of one ball: straight up until it is fully out of the source
/// flask's mouth, a smooth arc over to the point above the target mouth, then
/// straight down into its slot. The joins share a vertical tangent, and
/// [at] is parameterised by distance, so the ball moves at an even speed with
/// no kinks - and never cuts through a flask wall.
class _FlightPath {
  _FlightPath._(this._a, this._e1, this._c1, this._c2, this._e2, this._d) {
    _rise = (_e1 - _a).distance;
    _drop = (_d - _e2).distance;
    // Arc-length table for the cubic so speed is uniform along it.
    _arcLen = [0];
    var prev = _e1;
    for (var i = 1; i <= _samples; i++) {
      final p = _cubic(i / _samples);
      _arcLen.add(_arcLen.last + (p - prev).distance);
      prev = p;
    }
    length = _rise + _arcLen.last + _drop;
  }

  factory _FlightPath.build(
    BoardLayout l,
    int from,
    int to,
    Offset start,
    Offset end,
  ) {
    final e1 = l.liftedCenter(from);
    final e2 = l.liftedCenter(to);
    // Arc height: keep it inside the clear band above a row of flasks (rows
    // below the top one only have a short gap before the next row up).
    final topRow =
        l.columns[from].top <= l.columns.first.top + 0.5 &&
        l.columns[to].top <= l.columns.first.top + 0.5;
    final dx = (e2.dx - e1.dx).abs() / l.unit;
    final h = from == to
        ? 0.0
        : l.unit *
              (topRow ? (0.7 + dx * 0.12).clamp(0.7, 1.6) : 0.75).toDouble();
    // Never start below/end above the mouth (e.g. an already-lifted ball).
    final a = Offset(e1.dx, math.max(start.dy, e1.dy));
    final d = Offset(e2.dx, math.max(end.dy, e2.dy));
    return _FlightPath._(a, e1, e1 - Offset(0, h), e2 - Offset(0, h), e2, d);
  }

  static const _samples = 24;
  final Offset _a, _e1, _c1, _c2, _e2, _d;
  late final double _rise, _drop;
  late final List<double> _arcLen;
  late final double length;

  Offset _cubic(double t) {
    final u = 1 - t;
    return _e1 * (u * u * u) +
        _c1 * (3 * u * u * t) +
        _c2 * (3 * u * t * t) +
        _e2 * (t * t * t);
  }

  /// Position at fraction [s] (0..1) of the total distance.
  Offset at(double s) {
    if (length <= 0) return _d;
    var dist = s.clamp(0.0, 1.0) * length;
    if (dist <= _rise) {
      return _rise == 0 ? _e1 : Offset.lerp(_a, _e1, dist / _rise)!;
    }
    dist -= _rise;
    final arc = _arcLen.last;
    if (dist <= arc) {
      if (arc == 0) return _e1;
      var i = 1;
      while (i < _samples && _arcLen[i] < dist) {
        i++;
      }
      final l0 = _arcLen[i - 1], l1 = _arcLen[i];
      final f = l1 > l0 ? (dist - l0) / (l1 - l0) : 0.0;
      return _cubic((i - 1 + f) / _samples);
    }
    dist -= arc;
    return _drop == 0 ? _e2 : Offset.lerp(_e2, _d, dist / _drop)!;
  }
}
