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

class _GameBoardState extends ConsumerState<GameBoard> with SingleTickerProviderStateMixin {
  late final AnimationController _flightCtrl;

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
    var ms = 340.0;
    if (l != null && e.from < l.columns.length && e.to < l.columns.length) {
      final dist = (l.columns[e.from].center - l.columns[e.to].center).distance / l.unit;
      ms = (270 + dist * 22).clamp(270, 450).toDouble();
    }
    _flightCtrl.duration = Duration(milliseconds: ms.round());
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

  Offset? _flightPosition(GameState s, BoardLayout l, double t) {
    final f = _flight;
    if (f == null || f.from >= s.tubes.length || f.to >= s.tubes.length) return null;
    final dest = s.tubes[f.to].balls.indexWhere((b) => b.id == f.ballId);
    if (dest < 0) return null;
    final a = f.fromLifted ? l.liftedCenter(f.from) : l.slotCenter(f.from, s.tubes[f.from].balls.length);
    final b = l.liftedCenter(f.from);
    final c = l.liftedCenter(f.to);
    final d = l.slotCenter(f.to, dest);
    final l1 = (b - a).distance, l2 = (c - b).distance, l3 = (d - c).distance;
    final total = l1 + l2 + l3;
    if (total <= 0) return d;
    var dist = Curves.easeInOutCubic.transform(t) * total;
    if (dist <= l1 && l1 > 0) return Offset.lerp(a, b, dist / l1);
    dist -= l1;
    if (dist <= l2 && l2 > 0) {
      final k = dist / l2;
      final p = Offset.lerp(b, c, k)!;
      return p - Offset(0, math.sin(math.pi * k) * math.min(l.unit * 0.6, l2 * 0.18));
    }
    dist -= l2;
    return l3 > 0 ? Offset.lerp(c, d, (dist / l3).clamp(0, 1)) : d;
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

    return LayoutBuilder(builder: (context, constraints) {
      final size = Size(constraints.maxWidth, constraints.maxHeight);
      final l = BoardLayout.compute(size, s.tubes.length, s.level.tubeCapacity);
      _layout = l;
      const rules = GameRulesService();
      final children = <Widget>[];
      for (var i = 0; i < s.tubes.length; i++) {
        final tube = s.tubes[i];
        final landing = _flight != null && _flight!.to == i;
        final complete = !landing && tube.isFull && rules.isTubeComplete(s.tubes, i);
        children.add(AnimatedPositioned(
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
            hiddenBallId: landing ? _flight!.ballId : null,
            shakeSeq: _shakeSeqs[i] ?? 0,
            popSeq: _popSeq,
            celebrateSeq: _celebrateSeqs[i] ?? 0,
            animateEntrance: tube.id == _enteringTubeId,
            completeColorId: complete ? tube.topColor : null,
            hiddenIds: s.level.mystery
                ? {for (final b in tube.balls) if (s.isHidden(b.id)) b.id}
                : const {},
            onTap: () => _onTubeTap(i),
          ),
        ));
      }
      if (_flight != null) {
        final colorId = _flight!.colorId;
        children.add(AnimatedBuilder(
          animation: _flightCtrl,
          builder: (context, _) {
            final p = _flightPosition(s, l, _flightCtrl.value);
            if (p == null) return const SizedBox.shrink();
            return Positioned(
              left: p.dx - l.unit / 2,
              top: p.dy - l.unit / 2,
              width: l.unit,
              height: l.unit,
              child: IgnorePointer(child: GlossyBallWidget(colorId: colorId, diameter: l.unit)),
            );
          },
        ));
      }
      children.add(Positioned.fill(child: BoardTutorialOverlay(layout: l)));
      return Stack(clipBehavior: Clip.none, children: children);
    });
  }
}
