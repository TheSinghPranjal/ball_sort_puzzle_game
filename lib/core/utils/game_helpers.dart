/// Helpers for the raw puzzle representation used by the solver and generator:
/// a list of tubes, each a list of color ids ordered bottom -> top.
typedef RawTubes = List<List<int>>;

RawTubes cloneRaw(RawTubes tubes) => [for (final t in tubes) List<int>.of(t)];

/// Order-independent key: two boards that differ only in tube order are
/// equivalent for solvability.
String canonicalKey(RawTubes tubes) {
  final parts = [for (final t in tubes) t.join(',')]..sort();
  return parts.join('|');
}

/// Map colorId -> ball count.
Map<int, int> colorCounts(RawTubes tubes) {
  final counts = <int, int>{};
  for (final t in tubes) {
    for (final c in t) {
      counts[c] = (counts[c] ?? 0) + 1;
    }
  }
  return counts;
}

/// Number of contiguous same-color runs across all tubes.
int segmentCount(RawTubes tubes) {
  var segments = 0;
  for (final t in tubes) {
    for (var i = 0; i < t.length; i++) {
      if (i == 0 || t[i] != t[i - 1]) segments++;
    }
  }
  return segments;
}
