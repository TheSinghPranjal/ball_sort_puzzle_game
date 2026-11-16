/// A single ball. [id] is unique within a board and is used to track the ball
/// through moves/animations (and to prove no ball is duplicated or lost).
class Ball {
  const Ball({required this.id, required this.colorId});

  final int id;
  final int colorId;

  Map<String, dynamic> toJson() => {'i': id, 'c': colorId};

  factory Ball.fromJson(Map<String, dynamic> json) =>
      Ball(id: json['i'] as int, colorId: json['c'] as int);

  @override
  bool operator ==(Object other) =>
      other is Ball && other.id == id && other.colorId == colorId;

  @override
  int get hashCode => Object.hash(id, colorId);

  @override
  String toString() => 'Ball($id:c$colorId)';
}
