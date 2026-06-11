// lib/game/flow_level.dart
import 'dart:math';

/// A VoltFlow level: the grid is partitioned into colored paths.
/// Only the endpoints are shown to the player; they must redraw the wires.
class FlowLevel {
  final int index;
  final int size;
  final String difficulty;
  final List<List<int>> solutionPaths; // each is a list of cell indices

  FlowLevel({
    required this.index,
    required this.size,
    required this.difficulty,
    required this.solutionPaths,
  });

  int get pairCount => solutionPaths.length;

  /// endpoint cell -> color id (index into solutionPaths)
  Map<int, int> get endpoints {
    final m = <int, int>{};
    for (int c = 0; c < solutionPaths.length; c++) {
      m[solutionPaths[c].first] = c;
      m[solutionPaths[c].last] = c;
    }
    return m;
  }
}

class FlowGenerator {
  static FlowLevel generate(int levelIndex) {
    int size;
    String difficulty;
    if (levelIndex < 50) {
      size = 5;
      difficulty = 'Easy';
    } else if (levelIndex < 100) {
      size = 6;
      difficulty = 'Medium';
    } else {
      size = 7;
      difficulty = 'Hard';
    }

    final rng = Random(levelIndex * 6271 + levelIndex * 17 + 99);

    List<List<int>>? paths;
    for (int attempt = 0; attempt < 600; attempt++) {
      paths = _tryPartition(size, Random(rng.nextInt(1 << 31)));
      if (paths != null) break;
    }

    // Guaranteed fallback: each row is one wire.
    paths ??= List.generate(
        size, (r) => List.generate(size, (c) => r * size + c));

    return FlowLevel(
      index: levelIndex,
      size: size,
      difficulty: difficulty,
      solutionPaths: paths,
    );
  }

  /// Partition the grid into random snaking paths covering every cell.
  static List<List<int>>? _tryPartition(int size, Random rng) {
    final total = size * size;
    final remaining = <int>{for (int i = 0; i < total; i++) i};
    final paths = <List<int>>[];
    final maxPairs = size + 2;

    while (remaining.isNotEmpty) {
      if (paths.length >= maxPairs) return null;

      // Prefer starting from cells with few free neighbours (avoids orphans)
      int start = -1, best = 5;
      for (final cell in remaining) {
        final n = _freeNeighbors(cell, size, remaining).length;
        if (n < best) {
          best = n;
          start = cell;
          if (n <= 1) break;
        }
      }

      final path = <int>[start];
      remaining.remove(start);

      while (true) {
        final nbrs = _freeNeighbors(path.last, size, remaining);
        if (nbrs.isEmpty) break;
        // Stop randomly once long enough, for variety
        if (path.length >= 3 && rng.nextDouble() < 0.22) break;
        final next = nbrs[rng.nextInt(nbrs.length)];
        path.add(next);
        remaining.remove(next);
      }

      if (path.length < 3) return null; // stranded fragment — retry
      paths.add(path);
    }

    if (paths.length < 3) return null;
    return paths;
  }

  static List<int> _freeNeighbors(int idx, int size, Set<int> remaining) {
    final r = idx ~/ size, c = idx % size;
    final out = <int>[];
    if (r > 0 && remaining.contains(idx - size)) out.add(idx - size);
    if (r < size - 1 && remaining.contains(idx + size)) out.add(idx + size);
    if (c > 0 && remaining.contains(idx - 1)) out.add(idx - 1);
    if (c < size - 1 && remaining.contains(idx + 1)) out.add(idx + 1);
    return out;
  }
}
