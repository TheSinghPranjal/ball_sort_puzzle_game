import 'ball.dart';

/// Immutable tube. [balls] are ordered bottom -> top.
class Tube {
  Tube({
    required this.id,
    required List<Ball> balls,
    required this.capacity,
    this.isExtraTube = false,
  }) : balls = List.unmodifiable(balls);

  final int id;
  final List<Ball> balls;
  final int capacity;
  final bool isExtraTube;

  bool get isEmpty => balls.isEmpty;
  bool get isFull => balls.length >= capacity;
  int get freeSlots => capacity - balls.length;
  Ball? get topBall => balls.isEmpty ? null : balls.last;
  int? get topColor => balls.isEmpty ? null : balls.last.colorId;

  bool get isUniform =>
      balls.isNotEmpty && balls.every((b) => b.colorId == balls.first.colorId);

  List<int> get colorIds => [for (final b in balls) b.colorId];

  Tube copyWith({List<Ball>? balls, bool? isExtraTube}) => Tube(
    id: id,
    balls: balls ?? this.balls,
    capacity: capacity,
    isExtraTube: isExtraTube ?? this.isExtraTube,
  );

  Tube push(Ball ball) => copyWith(balls: [...balls, ball]);
  Tube pop() => copyWith(balls: balls.sublist(0, balls.length - 1));

  Map<String, dynamic> toJson() => {
    'id': id,
    'cap': capacity,
    'x': isExtraTube,
    'b': [for (final b in balls) b.toJson()],
  };

  factory Tube.fromJson(Map<String, dynamic> json) => Tube(
    id: json['id'] as int,
    capacity: json['cap'] as int,
    isExtraTube: json['x'] as bool? ?? false,
    balls: [
      for (final b in json['b'] as List)
        Ball.fromJson(Map<String, dynamic>.from(b as Map)),
    ],
  );

  @override
  String toString() => 'Tube#$id$colorIds${isExtraTube ? '+' : ''}';
}
