// lib/game/flow_state.dart
import 'package:flutter/material.dart';
import 'flow_level.dart';
import '../utils/constants.dart';
import '../utils/preferences.dart';
import '../utils/audio_manager.dart';

class FlowState extends ChangeNotifier {
  late FlowLevel level;
  late Map<int, int> endpoints; // cell -> color
  final Map<int, List<int>> paths = {}; // color -> drawn cells
  int? activeColor;
  int moves = 0;
  bool isComplete = false;
  int stars = 0;
  int currentLevelIndex = 0;
  bool initialized = false;

  void loadLevel(int index) {
    currentLevelIndex = index;
    level = FlowGenerator.generate(index);
    endpoints = level.endpoints;
    paths.clear();
    activeColor = null;
    moves = 0;
    isComplete = false;
    stars = 0;
    initialized = true;
    notifyListeners();
  }

  /// color of the wire occupying [cell], or null
  int? colorAt(int cell) {
    for (final e in paths.entries) {
      if (e.value.contains(cell)) return e.key;
    }
    return null;
  }

  bool isColorConnected(int color) {
    final p = paths[color];
    if (p == null || p.length < 2) return false;
    final eps = level.solutionPaths[color];
    return (p.first == eps.first && p.last == eps.last) ||
        (p.first == eps.last && p.last == eps.first);
  }

  int get coveredCells {
    int n = 0;
    for (final p in paths.values) n += p.length;
    return n;
  }

  // ── Drag handling ──────────────────────────────────────
  void startDrag(int cell) {
    if (isComplete) return;
    final ep = endpoints[cell];
    if (ep != null) {
      // Begin a fresh wire from this endpoint
      activeColor = ep;
      paths[ep] = [cell];
      notifyListeners();
      return;
    }
    final col = colorAt(cell);
    if (col != null) {
      // Resume editing an existing wire — truncate after this cell
      activeColor = col;
      final p = paths[col]!;
      final i = p.indexOf(cell);
      paths[col] = p.sublist(0, i + 1);
      notifyListeners();
    }
  }

  void dragTo(int cell) {
    final col = activeColor;
    if (col == null || isComplete) return;
    final p = paths[col]!;
    if (p.isEmpty) return;
    final last = p.last;
    if (cell == last) return;

    // Backtrack along own wire
    final selfIdx = p.indexOf(cell);
    if (selfIdx != -1) {
      paths[col] = p.sublist(0, selfIdx + 1);
      notifyListeners();
      return;
    }

    // Must be orthogonally adjacent
    final s = level.size;
    final dr = (cell ~/ s - last ~/ s).abs();
    final dc = (cell % s - last % s).abs();
    if (dr + dc != 1) return;

    // If wire already connected, don't extend past the endpoint
    if (isColorConnected(col)) return;

    // Endpoint rules
    final ep = endpoints[cell];
    if (ep != null && ep != col) return; // can't cross another node

    // Collide with another wire → truncate that wire at the collision
    final other = colorAt(cell);
    if (other != null && other != col) {
      final op = paths[other]!;
      final oi = op.indexOf(cell);
      paths[other] = op.sublist(0, oi);
      if (paths[other]!.isEmpty) paths.remove(other);
    }

    paths[col] = [...paths[col]!, cell];

    if (ep == col && isColorConnected(col)) {
      AudioManager.instance.playConnect();
    }
    notifyListeners();
  }

  void endDrag() {
    if (activeColor == null) return;
    moves++;
    activeColor = null;
    _checkComplete();
    notifyListeners();
  }

  bool get allWiresConnected =>
      List.generate(level.pairCount, (c) => c).every(isColorConnected);

  void _checkComplete() {
    final allConnected = allWiresConnected;
    final fullCover =
        !kRequireFullFill || coveredCells == level.size * level.size;
    if (allConnected && fullCover && !isComplete) {
      isComplete = true;
      stars = _calcStars();
      AudioManager.instance.playComplete();
      Preferences.instance.saveLevelResult(currentLevelIndex, stars);
    }
  }

  int _calcStars() {
    final par = level.pairCount;
    if (moves <= par) return 3;
    if (moves <= par * 2) return 2;
    return 1;
  }

  void restartLevel() => loadLevel(currentLevelIndex);

  void nextLevel() {
    if (currentLevelIndex < 149) loadLevel(currentLevelIndex + 1);
  }
}
