// lib/screens/home_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/preferences.dart';
import 'level_select_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completed = Preferences.instance.getCompletedCount();
    final totalStars = Preferences.instance.getTotalStars();

    return Scaffold(
      backgroundColor: kBg,
      body: Stack(children: [
        AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _FlowBgPainter(_ctrl.value),
          ),
        ),
        SafeArea(
          child: Column(children: [
            const Spacer(flex: 2),
            Text('VOLTFLOW',
                style: techno(42,
                    color: kAccent, weight: FontWeight.w900, letterSpacing: 8)),
            const SizedBox(height: 8),
            Text('DRAW  ·  LINK  ·  ENERGIZE',
                style: techno(12, color: kTextDim, letterSpacing: 4)),
            const SizedBox(height: 28),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _chip(Icons.check_circle_outline, '$completed / $kTotalLevels',
                  kEasyColor),
              const SizedBox(width: 14),
              _chip(Icons.star, '$totalStars', kStarOn),
            ]),
            const Spacer(flex: 3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 52),
              child: Column(children: [
                _btn('PLAY', Icons.play_arrow_rounded, true, () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const LevelSelectScreen()));
                }),
                const SizedBox(height: 14),
                _btn('SETTINGS', Icons.tune_rounded, false, () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const SettingsScreen()));
                }),
              ]),
            ),
            const SizedBox(height: 56),
          ]),
        ),
      ]),
    );
  }

  Widget _chip(IconData icon, String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kBorder),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(label, style: techno(13)),
        ]),
      );

  Widget _btn(String label, IconData icon, bool primary, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: primary
                ? const LinearGradient(
                    colors: [Color(0xFF0090A8), Color(0xFF00C2D8)])
                : null,
            color: primary ? null : kSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: primary ? kAccent.withOpacity(0.7) : kBorder,
                width: primary ? 1.5 : 1),
            boxShadow: primary
                ? [BoxShadow(color: kAccent.withOpacity(0.3), blurRadius: 22)]
                : null,
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: primary ? Colors.white : kTextDim, size: 20),
            const SizedBox(width: 10),
            Text(label,
                style: techno(15,
                    color: primary ? Colors.white : kTextDim,
                    letterSpacing: 3)),
          ]),
        ),
      );
}

/// Drifting neon wires background
class _FlowBgPainter extends CustomPainter {
  final double t;
  _FlowBgPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      kWireColors[0].withOpacity(0.13),
      kWireColors[1].withOpacity(0.11),
      kWireColors[2].withOpacity(0.10),
    ];
    for (int i = 0; i < 3; i++) {
      final p = Paint()
        ..color = colors[i]
        ..strokeWidth = 26
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final path = Path();
      final phase = t * 2 * pi + i * 2.1;
      path.moveTo(-50, size.height * (0.2 + 0.3 * i));
      for (double x = 0; x <= size.width + 50; x += 24) {
        path.lineTo(
            x,
            size.height * (0.2 + 0.3 * i) +
                sin(x / 90 + phase) * 36);
      }
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(_FlowBgPainter o) => o.t != t;
}
