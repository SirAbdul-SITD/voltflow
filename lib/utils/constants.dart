// lib/utils/constants.dart
import 'package:flutter/material.dart';

// ── VoltFlow palette: deep black + vivid neon wires ─────────────────────
const Color kBg          = Color(0xFF06060C);
const Color kSurface     = Color(0xFF101019);
const Color kBorder      = Color(0xFF23233A);
const Color kAccent      = Color(0xFF00E5FF);
const Color kTextPrimary = Colors.white;
const Color kTextDim     = Color(0xFF8C8CB0);

const Color kStarOn  = Color(0xFFFFD54F);
const Color kStarOff = Color(0xFF2A2A40);

const Color kEasyColor   = Color(0xFF00E676);
const Color kMediumColor = Color(0xFF00B0FF);
const Color kHardColor   = Color(0xFFFF6E40);

// Neon wire colors (assigned to pairs in order)
const List<Color> kWireColors = [
  Color(0xFF00E5FF), // cyan
  Color(0xFFFF4081), // pink
  Color(0xFF76FF03), // lime
  Color(0xFFFFAB40), // orange
  Color(0xFFE040FB), // purple
  Color(0xFFFFFF00), // yellow
  Color(0xFF18FFFF), // aqua
  Color(0xFFFF5252), // red
  Color(0xFF69F0AE), // mint
  Color(0xFF448AFF), // blue
];

const int kTotalLevels = 150;

TextStyle techno(double size,
        {Color color = Colors.white,
        FontWeight weight = FontWeight.bold,
        double letterSpacing = 1.5}) =>
    TextStyle(
      fontSize: size,
      color: color,
      fontWeight: weight,
      letterSpacing: letterSpacing,
    );
