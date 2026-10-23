import 'package:flutter/material.dart';

/// Visual theme for each 30-level "world" of the road map.
class WorldTheme {
  final int index;
  final String name;
  final String icon;
  final Color top;
  final Color bottom;
  final Color orb;
  final Color accent;
  final Color primary;

  const WorldTheme({
    required this.index,
    required this.name,
    required this.icon,
    required this.top,
    required this.bottom,
    required this.orb,
    required this.accent,
    required this.primary,
  });

  LinearGradient get gradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [top, bottom],
      );

  static const int levelsPerWorld = 30;

  static const List<WorldTheme> worlds = [
    WorldTheme(index: 0, name: 'Crystal Lab', icon: '🧪', top: Color(0xFF1D1650), bottom: Color(0xFF0A0A1C), orb: Color(0xFF8B7BFF), accent: Color(0xFF00E5A0), primary: Color(0xFF5B4CFF)),
    WorldTheme(index: 1, name: 'Ocean Reef', icon: '🐠', top: Color(0xFF06406B), bottom: Color(0xFF021A2E), orb: Color(0xFF4FC3F7), accent: Color(0xFF64FFDA), primary: Color(0xFF0288D1)),
    WorldTheme(index: 2, name: 'Candy Land', icon: '🍭', top: Color(0xFF5A1B5E), bottom: Color(0xFF220A33), orb: Color(0xFFFF80AB), accent: Color(0xFFFFD54F), primary: Color(0xFFE91E8C)),
    WorldTheme(index: 3, name: 'Sunset Desert', icon: '🏜️', top: Color(0xFF6D2A12), bottom: Color(0xFF230E0A), orb: Color(0xFFFFB74D), accent: Color(0xFFFFEB3B), primary: Color(0xFFFF7043)),
    WorldTheme(index: 4, name: 'Emerald Forest', icon: '🌲', top: Color(0xFF0F4D2E), bottom: Color(0xFF06190F), orb: Color(0xFF69F0AE), accent: Color(0xFFCCFF90), primary: Color(0xFF2E7D32)),
    WorldTheme(index: 5, name: 'Arctic Frost', icon: '❄️', top: Color(0xFF1F5A7A), bottom: Color(0xFF0A2236), orb: Color(0xFFB3E5FC), accent: Color(0xFFE1F5FE), primary: Color(0xFF29B6F6)),
    WorldTheme(index: 6, name: 'Neon City', icon: '🌃', top: Color(0xFF2B0A4A), bottom: Color(0xFF080314), orb: Color(0xFFFF2BD6), accent: Color(0xFF00F0FF), primary: Color(0xFFB000FF)),
    WorldTheme(index: 7, name: 'Volcano', icon: '🌋', top: Color(0xFF5C1010), bottom: Color(0xFF1A0505), orb: Color(0xFFFF5722), accent: Color(0xFFFFC107), primary: Color(0xFFD32F2F)),
    WorldTheme(index: 8, name: 'Galaxy', icon: '🌌', top: Color(0xFF150A3D), bottom: Color(0xFF020010), orb: Color(0xFFB388FF), accent: Color(0xFF80D8FF), primary: Color(0xFF651FFF)),
    WorldTheme(index: 9, name: 'Golden Palace', icon: '👑', top: Color(0xFF5D4308), bottom: Color(0xFF1F1503), orb: Color(0xFFFFD54F), accent: Color(0xFFFFF176), primary: Color(0xFFFFA000)),
    WorldTheme(index: 10, name: 'Rainbow Sky', icon: '🌈', top: Color(0xFF3A2A8F), bottom: Color(0xFF0E1B4D), orb: Color(0xFFFF8A80), accent: Color(0xFF84FFFF), primary: Color(0xFF7C4DFF)),
  ];

  static int indexForLevel(int level) {
    final i = (level - 1) ~/ levelsPerWorld;
    if (i < 0) return 0;
    if (i >= worlds.length) return worlds.length - 1;
    return i;
  }

  static WorldTheme forLevel(int level) => worlds[indexForLevel(level)];
  static WorldTheme byIndex(int i) =>
      worlds[i < 0 ? 0 : (i >= worlds.length ? worlds.length - 1 : i)];
}
