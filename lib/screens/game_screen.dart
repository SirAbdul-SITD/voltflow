// lib/screens/game_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../game/flow_state.dart';
import '../utils/constants.dart';
import '../utils/preferences.dart';
import 'level_select_screen.dart';

class GameScreen extends StatefulWidget {
  final int levelIndex;
  const GameScreen({super.key, required this.levelIndex});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _victoryCtrl;
  late final Animation<double> _victoryAnim;

  @override
  void initState() {
    super.initState();
    _victoryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _victoryAnim =
        CurvedAnimation(parent: _victoryCtrl, curve: Curves.elasticOut);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FlowState>().loadLevel(widget.levelIndex);
    });
  }

  @override
  void dispose() {
    _victoryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Consumer<FlowState>(builder: (ctx, st, _) {
        if (!st.initialized) {
          return const Center(child: CircularProgressIndicator(color: kAccent));
        }
        if (st.isComplete && !_victoryCtrl.isCompleted) {
          _victoryCtrl.forward();
          if (Preferences.instance.isVibrationEnabled()) {
            HapticFeedback.heavyImpact();
          }
        }
        return Stack(children: [
          SafeArea(
            child: Column(children: [
              _hud(st),
              const SizedBox(height: 4),
              _progressRow(st),
              Expanded(child: Center(child: _FlowBoard(state: st))),
              _bottomBar(st),
              const SizedBox(height: 12),
            ]),
          ),
          if (st.isComplete) _victory(st),
        ]);
      }),
    );
  }

  Widget _hud(FlowState st) {
    final diffColor = st.level.difficulty == 'Easy'
        ? kEasyColor
        : st.level.difficulty == 'Medium'
            ? kMediumColor
            : kHardColor;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kBorder)),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: kTextDim, size: 16),
          ),
        ),
        const Spacer(),
        Column(children: [
          Text('LEVEL ${st.level.index + 1}',
              style: techno(14, letterSpacing: 3)),
          Text(st.level.difficulty.toUpperCase(),
              style: techno(10, color: diffColor, letterSpacing: 2)),
        ]),
        const Spacer(),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${st.moves}',
              style: techno(18, color: kAccent, weight: FontWeight.w900)),
          Text('MOVES', style: techno(9, color: kTextDim, letterSpacing: 2)),
        ]),
      ]),
    );
  }

  Widget _progressRow(FlowState st) {
    final connected = List.generate(st.level.pairCount, (c) => c)
        .where(st.isColorConnected)
        .length;
    final cover = st.coveredCells;
    final total = st.level.size * st.level.size;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('WIRES  $connected / ${st.level.pairCount}',
            style: techno(11, color: kTextDim, letterSpacing: 2)),
        const SizedBox(width: 24),
        Text('FILL  ${(cover * 100 / total).round()}%',
            style: techno(11, color: kTextDim, letterSpacing: 2)),
      ]),
    );
  }

  Widget _bottomBar(FlowState st) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _actionBtn(Icons.refresh_rounded, 'RESTART', () {
            _victoryCtrl.reset();
            st.restartLevel();
          }),
          const SizedBox(width: 24),
          _actionBtn(Icons.grid_view_rounded, 'LEVELS', () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (_) => const LevelSelectScreen()));
          }),
        ],
      );

  Widget _actionBtn(IconData icon, String label, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kBorder),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: kTextDim, size: 16),
            const SizedBox(width: 6),
            Text(label, style: techno(10, color: kTextDim, letterSpacing: 2)),
          ]),
        ),
      );

  Widget _victory(FlowState st) => Container(
        color: Colors.black.withOpacity(0.78),
        child: Center(
          child: ScaleTransition(
            scale: _victoryAnim,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kAccent.withOpacity(0.5), width: 1.5),
                boxShadow: [
                  BoxShadow(
                      color: kAccent.withOpacity(0.2),
                      blurRadius: 40,
                      spreadRadius: 4)
                ],
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kEasyColor.withOpacity(0.15),
                    border: Border.all(color: kEasyColor, width: 2),
                  ),
                  child: const Icon(Icons.bolt_rounded,
                      color: kEasyColor, size: 32),
                ),
                const SizedBox(height: 16),
                Text('FULLY ENERGIZED',
                    style: techno(16,
                        color: kAccent,
                        weight: FontWeight.w900,
                        letterSpacing: 3)),
                const SizedBox(height: 6),
                Text('${st.moves} MOVES',
                    style: techno(12, color: kTextDim, letterSpacing: 2)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                      3,
                      (i) => Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              i < st.stars
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: i < st.stars ? kStarOn : kStarOff,
                              size: 36,
                            ),
                          )),
                ),
                const SizedBox(height: 24),
                Row(children: [
                  Expanded(
                      child: _vBtn('REPLAY', Icons.refresh_rounded, false, () {
                    _victoryCtrl.reset();
                    st.restartLevel();
                  })),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _vBtn('NEXT', Icons.arrow_forward_rounded, true,
                          () {
                    _victoryCtrl.reset();
                    if (st.currentLevelIndex < 149) {
                      st.nextLevel();
                    } else {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (_) => const LevelSelectScreen()));
                    }
                  })),
                ]),
              ]),
            ),
          ),
        ),
      );

  Widget _vBtn(String label, IconData icon, bool primary, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            gradient: primary
                ? const LinearGradient(
                    colors: [Color(0xFF0090A8), Color(0xFF00C2D8)])
                : null,
            color: primary ? null : kBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: primary ? kAccent.withOpacity(0.5) : kBorder),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(label, style: techno(12, letterSpacing: 2)),
          ]),
        ),
      );
}

// ── The draggable wire board ─────────────────────────────────────────────────
class _FlowBoard extends StatelessWidget {
  final FlowState state;
  const _FlowBoard({required this.state});

  int? _cellAt(Offset local, double boardSize, int gridSize) {
    final cell = boardSize / gridSize;
    final c = (local.dx / cell).floor();
    final r = (local.dy / cell).floor();
    if (r < 0 || c < 0 || r >= gridSize || c >= gridSize) return null;
    return r * gridSize + c;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final boardSize = (size.width - 28).clamp(0.0, size.height * 0.62);
    final grid = state.level.size;

    return Container(
      width: boardSize + 12,
      height: boardSize + 12,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: kSurface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder, width: 1.5),
      ),
      child: GestureDetector(
        onPanStart: (d) {
          final cell = _cellAt(d.localPosition, boardSize, grid);
          if (cell != null) {
            if (Preferences.instance.isVibrationEnabled()) {
              HapticFeedback.selectionClick();
            }
            state.startDrag(cell);
          }
        },
        onPanUpdate: (d) {
          final cell = _cellAt(d.localPosition, boardSize, grid);
          if (cell != null) state.dragTo(cell);
        },
        onPanEnd: (_) => state.endDrag(),
        child: CustomPaint(
          size: Size(boardSize, boardSize),
          painter: _FlowPainter(state),
        ),
      ),
    );
  }
}

class _FlowPainter extends CustomPainter {
  final FlowState st;
  _FlowPainter(st0) : st = st0;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = st.level.size;
    final cell = size.width / grid;

    // Grid lines
    final gp = Paint()
      ..color = kBorder.withOpacity(0.55)
      ..strokeWidth = 1;
    for (int i = 0; i <= grid; i++) {
      canvas.drawLine(Offset(i * cell, 0), Offset(i * cell, size.height), gp);
      canvas.drawLine(Offset(0, i * cell), Offset(size.width, i * cell), gp);
    }

    Offset center(int idx) => Offset(
        (idx % grid) * cell + cell / 2, (idx ~/ grid) * cell + cell / 2);

    // Cell tint under wires
    for (final e in st.paths.entries) {
      final color = kWireColors[e.key % kWireColors.length];
      final tint = Paint()..color = color.withOpacity(0.10);
      for (final idx in e.value) {
        final r = idx ~/ grid, c = idx % grid;
        canvas.drawRect(
            Rect.fromLTWH(c * cell + 1, r * cell + 1, cell - 2, cell - 2),
            tint);
      }
    }

    // Wires: glow pass then solid pass
    for (final pass in [0, 1]) {
      for (final e in st.paths.entries) {
        final pts = e.value;
        if (pts.length < 2) continue;
        final color = kWireColors[e.key % kWireColors.length];
        final paint = Paint()
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke;
        if (pass == 0) {
          paint
            ..color = color.withOpacity(0.35)
            ..strokeWidth = cell * 0.48
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
        } else {
          paint
            ..color = color
            ..strokeWidth = cell * 0.30;
        }
        final path = Path()..moveTo(center(pts[0]).dx, center(pts[0]).dy);
        for (int i = 1; i < pts.length; i++) {
          path.lineTo(center(pts[i]).dx, center(pts[i]).dy);
        }
        canvas.drawPath(path, paint);
      }
    }

    // Endpoint nodes
    st.endpoints.forEach((idx, colorId) {
      final color = kWireColors[colorId % kWireColors.length];
      final o = center(idx);
      final connected = st.isColorConnected(colorId);
      // glow
      canvas.drawCircle(
          o,
          cell * (connected ? 0.40 : 0.34),
          Paint()
            ..color = color.withOpacity(connected ? 0.55 : 0.30)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
      // body
      canvas.drawCircle(o, cell * 0.26, Paint()..color = color);
      // dark core ring
      canvas.drawCircle(
          o,
          cell * 0.26,
          Paint()
            ..color = Colors.black.withOpacity(0.35)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
      if (connected) {
        canvas.drawCircle(o, cell * 0.10,
            Paint()..color = Colors.white.withOpacity(0.85));
      }
    });
  }

  @override
  bool shouldRepaint(_FlowPainter old) => true;
}
