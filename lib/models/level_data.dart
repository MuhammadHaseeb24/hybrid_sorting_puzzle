import 'package:flutter/material.dart';

/// Represents a single tube in the sorting puzzle
class Tube {
  final List<Color> colors; // Bottom to top
  final int capacity;

  Tube({required this.colors, this.capacity = 4});

  Tube copyWith({List<Color>? colors, int? capacity}) {
    return Tube(
      colors: colors ?? List.from(this.colors),
      capacity: capacity ?? this.capacity,
    );
  }

  bool get isEmpty => colors.isEmpty;
  bool get isFull => colors.length >= capacity;
  bool get isSorted {
    if (colors.isEmpty) return true;
    final first = colors.first;
    return colors.every((c) => c == first) && colors.length == capacity;
  }

  Color? get topColor => colors.isEmpty ? null : colors.last;

  bool canPourTo(Tube other) {
    if (isEmpty) return false;
    if (other.isFull) return false;
    if (other.isEmpty) return true;
    return topColor == other.topColor;
  }

  int pourAmountTo(Tube other) {
    if (!canPourTo(other)) return 0;
    final space = other.capacity - other.colors.length;
    int sameColorCount = 0;
    final top = topColor!;
    for (int i = colors.length - 1; i >= 0; i--) {
      if (colors[i] == top) {
        sameColorCount++;
      } else {
        break;
      }
    }
    return sameColorCount.clamp(0, space);
  }
}

class LevelData {
  final int id;
  final String name;
  final List<List<Color>> initialTubes;
  final int maxMoves;
  final int tubeCapacity;
  final int stars3Moves;
  final int stars2Moves;

  const LevelData({
    required this.id,
    required this.name,
    required this.initialTubes,
    this.maxMoves = 50,
    this.tubeCapacity = 4,
    this.stars3Moves = 15,
    this.stars2Moves = 25,
  });

  List<Tube> createTubes() {
    return initialTubes
        .map((colors) => Tube(colors: List.from(colors), capacity: tubeCapacity))
        .toList();
  }
}

class GameColors {
  static const Color red = Color(0xFFE53935);
  static const Color blue = Color(0xFF1E88E5);
  static const Color green = Color(0xFF43A047);
  static const Color yellow = Color(0xFFFDD835);
  static const Color purple = Color(0xFF8E24AA);
  static const Color orange = Color(0xFFFB8C00);
  static const Color cyan = Color(0xFF00ACC1);
  static const Color pink = Color(0xFFD81B60);
  static const Color teal = Color(0xFF00897B);
  static const Color indigo = Color(0xFF3949AB);
  static const Color lime = Color(0xFFC0CA33);
  static const Color amber = Color(0xFFFFB300);

  static const List<Color> palette = [
    red, blue, green, yellow, purple, orange, cyan, pink, teal, indigo, lime, amber,
  ];
}

class LevelRepository {
  static final List<LevelData> levels = [
    // ===== TUTORIAL / EASY (1-10) =====
    LevelData(
      id: 1,
      name: "First Sort",
      initialTubes: [
        [GameColors.red, GameColors.blue, GameColors.red, GameColors.blue],
        [GameColors.blue, GameColors.red, GameColors.blue, GameColors.red],
        [],
        [],
      ],
      maxMoves: 20,
      stars3Moves: 8,
      stars2Moves: 12,
    ),
    LevelData(
      id: 2,
      name: "Color Mix",
      initialTubes: [
        [GameColors.green, GameColors.yellow, GameColors.green, GameColors.yellow],
        [GameColors.yellow, GameColors.green, GameColors.yellow, GameColors.green],
        [GameColors.green, GameColors.yellow],
        [],
        [],
      ],
      maxMoves: 25,
      stars3Moves: 10,
      stars2Moves: 16,
    ),
    LevelData(
      id: 3,
      name: "Triple Threat",
      initialTubes: [
        [GameColors.red, GameColors.blue, GameColors.green, GameColors.red],
        [GameColors.blue, GameColors.green, GameColors.red, GameColors.blue],
        [GameColors.green, GameColors.red, GameColors.blue, GameColors.green],
        [],
        [],
      ],
      maxMoves: 35,
      stars3Moves: 14,
      stars2Moves: 22,
    ),
    LevelData(
      id: 4,
      name: "Rainbow Start",
      initialTubes: [
        [GameColors.purple, GameColors.orange, GameColors.cyan, GameColors.purple],
        [GameColors.orange, GameColors.cyan, GameColors.purple, GameColors.orange],
        [GameColors.cyan, GameColors.purple, GameColors.orange, GameColors.cyan],
        [],
        [],
        [],
      ],
      maxMoves: 40,
      stars3Moves: 16,
      stars2Moves: 25,
    ),
    LevelData(
      id: 5,
      name: "Deep Mix",
      initialTubes: [
        [GameColors.red, GameColors.green, GameColors.blue, GameColors.yellow],
        [GameColors.yellow, GameColors.red, GameColors.green, GameColors.blue],
        [GameColors.blue, GameColors.yellow, GameColors.red, GameColors.green],
        [GameColors.green, GameColors.blue, GameColors.yellow, GameColors.red],
        [],
        [],
      ],
      maxMoves: 50,
      stars3Moves: 20,
      stars2Moves: 32,
    ),
    LevelData(
      id: 6,
      name: "Pink Teal",
      initialTubes: [
        [GameColors.pink, GameColors.teal, GameColors.indigo, GameColors.pink],
        [GameColors.teal, GameColors.indigo, GameColors.pink, GameColors.teal],
        [GameColors.indigo, GameColors.pink, GameColors.teal, GameColors.indigo],
        [GameColors.pink, GameColors.teal],
        [],
        [],
        [],
      ],
      maxMoves: 55,
      stars3Moves: 22,
      stars2Moves: 35,
    ),
    LevelData(
      id: 7,
      name: "Six Colors",
      initialTubes: [
        [GameColors.red, GameColors.blue, GameColors.green, GameColors.yellow],
        [GameColors.purple, GameColors.orange, GameColors.cyan, GameColors.pink],
        [GameColors.yellow, GameColors.red, GameColors.blue, GameColors.green],
        [GameColors.pink, GameColors.purple, GameColors.orange, GameColors.cyan],
        [GameColors.green, GameColors.yellow, GameColors.red, GameColors.blue],
        [],
        [],
        [],
      ],
      maxMoves: 70,
      stars3Moves: 28,
      stars2Moves: 45,
    ),
    LevelData(
      id: 8,
      name: "Master Puzzle",
      initialTubes: [
        [GameColors.indigo, GameColors.teal, GameColors.pink, GameColors.cyan],
        [GameColors.orange, GameColors.purple, GameColors.yellow, GameColors.green],
        [GameColors.cyan, GameColors.indigo, GameColors.teal, GameColors.pink],
        [GameColors.green, GameColors.orange, GameColors.purple, GameColors.yellow],
        [GameColors.pink, GameColors.cyan, GameColors.indigo, GameColors.teal],
        [GameColors.yellow, GameColors.green, GameColors.orange, GameColors.purple],
        [],
        [],
      ],
      maxMoves: 80,
      stars3Moves: 32,
      stars2Moves: 50,
    ),
    LevelData(
      id: 9,
      name: "Color Storm",
      initialTubes: [
        [GameColors.red, GameColors.lime, GameColors.blue, GameColors.amber],
        [GameColors.lime, GameColors.blue, GameColors.amber, GameColors.red],
        [GameColors.blue, GameColors.amber, GameColors.red, GameColors.lime],
        [GameColors.amber, GameColors.red, GameColors.lime, GameColors.blue],
        [],
        [],
      ],
      maxMoves: 55,
      stars3Moves: 22,
      stars2Moves: 35,
    ),
    LevelData(
      id: 10,
      name: "Steady Hand",
      initialTubes: [
        [GameColors.teal, GameColors.pink, GameColors.indigo, GameColors.cyan],
        [GameColors.pink, GameColors.indigo, GameColors.cyan, GameColors.teal],
        [GameColors.indigo, GameColors.cyan, GameColors.teal, GameColors.pink],
        [GameColors.cyan, GameColors.teal],
        [],
        [],
        [],
      ],
      maxMoves: 60,
      stars3Moves: 24,
      stars2Moves: 38,
    ),

    // ===== MEDIUM (11-25) =====
    LevelData(
      id: 11,
      name: "Layer Cake",
      initialTubes: [
        [GameColors.red, GameColors.red, GameColors.blue, GameColors.green],
        [GameColors.blue, GameColors.green, GameColors.red, GameColors.blue],
        [GameColors.green, GameColors.red, GameColors.blue, GameColors.green],
        [GameColors.yellow, GameColors.yellow, GameColors.yellow],
        [],
        [],
      ],
      maxMoves: 50,
      stars3Moves: 20,
      stars2Moves: 32,
    ),
    LevelData(
      id: 12,
      name: "Double Trouble",
      initialTubes: [
        [GameColors.purple, GameColors.orange, GameColors.purple, GameColors.orange],
        [GameColors.cyan, GameColors.pink, GameColors.cyan, GameColors.pink],
        [GameColors.orange, GameColors.purple, GameColors.orange, GameColors.purple],
        [GameColors.pink, GameColors.cyan, GameColors.pink, GameColors.cyan],
        [],
        [],
        [],
      ],
      maxMoves: 55,
      stars3Moves: 22,
      stars2Moves: 36,
    ),
    LevelData(
      id: 13,
      name: "Five Alive",
      initialTubes: [
        [GameColors.red, GameColors.blue, GameColors.green, GameColors.yellow],
        [GameColors.purple, GameColors.red, GameColors.blue, GameColors.green],
        [GameColors.yellow, GameColors.purple, GameColors.red, GameColors.blue],
        [GameColors.green, GameColors.yellow, GameColors.purple, GameColors.red],
        [GameColors.blue, GameColors.green, GameColors.yellow, GameColors.purple],
        [],
        [],
      ],
      maxMoves: 70,
      stars3Moves: 28,
      stars2Moves: 45,
    ),
    LevelData(
      id: 14,
      name: "Narrow Path",
      initialTubes: [
        [GameColors.teal, GameColors.indigo, GameColors.pink, GameColors.cyan],
        [GameColors.indigo, GameColors.pink, GameColors.cyan, GameColors.teal],
        [GameColors.pink, GameColors.cyan, GameColors.teal, GameColors.indigo],
        [GameColors.cyan, GameColors.teal, GameColors.indigo, GameColors.pink],
        [],
        [],
      ],
      maxMoves: 60,
      stars3Moves: 25,
      stars2Moves: 40,
    ),
    LevelData(
      id: 15,
      name: "Chaos Order",
      initialTubes: [
        [GameColors.red, GameColors.lime, GameColors.amber, GameColors.blue],
        [GameColors.lime, GameColors.amber, GameColors.blue, GameColors.red],
        [GameColors.amber, GameColors.blue, GameColors.red, GameColors.lime],
        [GameColors.blue, GameColors.red, GameColors.lime, GameColors.amber],
        [GameColors.red, GameColors.lime],
        [],
        [],
        [],
      ],
      maxMoves: 75,
      stars3Moves: 30,
      stars2Moves: 48,
    ),
    LevelData(
      id: 16,
      name: "Sunset Mix",
      initialTubes: [
        [GameColors.orange, GameColors.pink, GameColors.purple, GameColors.red],
        [GameColors.pink, GameColors.purple, GameColors.red, GameColors.orange],
        [GameColors.purple, GameColors.red, GameColors.orange, GameColors.pink],
        [GameColors.red, GameColors.orange, GameColors.pink, GameColors.purple],
        [],
        [],
      ],
      maxMoves: 55,
      stars3Moves: 22,
      stars2Moves: 36,
    ),
    LevelData(
      id: 17,
      name: "Ocean Depths",
      initialTubes: [
        [GameColors.blue, GameColors.cyan, GameColors.teal, GameColors.indigo],
        [GameColors.cyan, GameColors.teal, GameColors.indigo, GameColors.blue],
        [GameColors.teal, GameColors.indigo, GameColors.blue, GameColors.cyan],
        [GameColors.indigo, GameColors.blue, GameColors.cyan, GameColors.teal],
        [],
        [],
        [],
      ],
      maxMoves: 60,
      stars3Moves: 24,
      stars2Moves: 40,
    ),
    LevelData(
      id: 18,
      name: "Neon Nights",
      initialTubes: [
        [GameColors.pink, GameColors.lime, GameColors.cyan, GameColors.yellow],
        [GameColors.lime, GameColors.cyan, GameColors.yellow, GameColors.pink],
        [GameColors.cyan, GameColors.yellow, GameColors.pink, GameColors.lime],
        [GameColors.yellow, GameColors.pink, GameColors.lime, GameColors.cyan],
        [GameColors.pink, GameColors.lime],
        [],
        [],
      ],
      maxMoves: 70,
      stars3Moves: 28,
      stars2Moves: 45,
    ),
    LevelData(
      id: 19,
      name: "Forest Path",
      initialTubes: [
        [GameColors.green, GameColors.teal, GameColors.lime, GameColors.yellow],
        [GameColors.teal, GameColors.lime, GameColors.yellow, GameColors.green],
        [GameColors.lime, GameColors.yellow, GameColors.green, GameColors.teal],
        [GameColors.yellow, GameColors.green, GameColors.teal, GameColors.lime],
        [],
        [],
      ],
      maxMoves: 55,
      stars3Moves: 22,
      stars2Moves: 36,
    ),
    LevelData(
      id: 20,
      name: "Royal Flush",
      initialTubes: [
        [GameColors.purple, GameColors.indigo, GameColors.pink, GameColors.blue],
        [GameColors.indigo, GameColors.pink, GameColors.blue, GameColors.purple],
        [GameColors.pink, GameColors.blue, GameColors.purple, GameColors.indigo],
        [GameColors.blue, GameColors.purple, GameColors.indigo, GameColors.pink],
        [GameColors.purple, GameColors.indigo],
        [],
        [],
        [],
      ],
      maxMoves: 75,
      stars3Moves: 30,
      stars2Moves: 48,
    ),
    LevelData(
      id: 21,
      name: "Fire & Ice",
      initialTubes: [
        [GameColors.red, GameColors.orange, GameColors.blue, GameColors.cyan],
        [GameColors.orange, GameColors.blue, GameColors.cyan, GameColors.red],
        [GameColors.blue, GameColors.cyan, GameColors.red, GameColors.orange],
        [GameColors.cyan, GameColors.red, GameColors.orange, GameColors.blue],
        [],
        [],
      ],
      maxMoves: 55,
      stars3Moves: 22,
      stars2Moves: 36,
    ),
    LevelData(
      id: 22,
      name: "Candy Crush",
      initialTubes: [
        [GameColors.pink, GameColors.yellow, GameColors.green, GameColors.purple],
        [GameColors.yellow, GameColors.green, GameColors.purple, GameColors.pink],
        [GameColors.green, GameColors.purple, GameColors.pink, GameColors.yellow],
        [GameColors.purple, GameColors.pink, GameColors.yellow, GameColors.green],
        [],
        [],
        [],
      ],
      maxMoves: 60,
      stars3Moves: 24,
      stars2Moves: 40,
    ),
    LevelData(
      id: 23,
      name: "Midnight",
      initialTubes: [
        [GameColors.indigo, GameColors.purple, GameColors.blue, GameColors.teal],
        [GameColors.purple, GameColors.blue, GameColors.teal, GameColors.indigo],
        [GameColors.blue, GameColors.teal, GameColors.indigo, GameColors.purple],
        [GameColors.teal, GameColors.indigo, GameColors.purple, GameColors.blue],
        [GameColors.indigo, GameColors.purple],
        [],
        [],
      ],
      maxMoves: 70,
      stars3Moves: 28,
      stars2Moves: 45,
    ),
    LevelData(
      id: 24,
      name: "Sunrise",
      initialTubes: [
        [GameColors.amber, GameColors.orange, GameColors.red, GameColors.pink],
        [GameColors.orange, GameColors.red, GameColors.pink, GameColors.amber],
        [GameColors.red, GameColors.pink, GameColors.amber, GameColors.orange],
        [GameColors.pink, GameColors.amber, GameColors.orange, GameColors.red],
        [],
        [],
      ],
      maxMoves: 55,
      stars3Moves: 22,
      stars2Moves: 36,
    ),
    LevelData(
      id: 25,
      name: "Spectrum",
      initialTubes: [
        [GameColors.red, GameColors.orange, GameColors.yellow, GameColors.green],
        [GameColors.blue, GameColors.indigo, GameColors.purple, GameColors.pink],
        [GameColors.green, GameColors.red, GameColors.orange, GameColors.yellow],
        [GameColors.pink, GameColors.blue, GameColors.indigo, GameColors.purple],
        [GameColors.yellow, GameColors.green, GameColors.red, GameColors.orange],
        [GameColors.purple, GameColors.pink, GameColors.blue, GameColors.indigo],
        [],
        [],
      ],
      maxMoves: 90,
      stars3Moves: 36,
      stars2Moves: 55,
    ),

    // ===== HARD (26-40) =====
    LevelData(
      id: 26,
      name: "Tight Squeeze",
      initialTubes: [
        [GameColors.red, GameColors.blue, GameColors.green, GameColors.yellow],
        [GameColors.purple, GameColors.orange, GameColors.cyan, GameColors.pink],
        [GameColors.teal, GameColors.indigo, GameColors.lime, GameColors.amber],
        [GameColors.yellow, GameColors.red, GameColors.blue, GameColors.green],
        [GameColors.pink, GameColors.purple, GameColors.orange, GameColors.cyan],
        [GameColors.amber, GameColors.teal, GameColors.indigo, GameColors.lime],
        [],
        [],
      ],
      maxMoves: 100,
      stars3Moves: 40,
      stars2Moves: 65,
    ),
    LevelData(
      id: 27,
      name: "Puzzle Master",
      initialTubes: [
        [GameColors.cyan, GameColors.pink, GameColors.teal, GameColors.indigo],
        [GameColors.orange, GameColors.lime, GameColors.amber, GameColors.red],
        [GameColors.indigo, GameColors.cyan, GameColors.pink, GameColors.teal],
        [GameColors.red, GameColors.orange, GameColors.lime, GameColors.amber],
        [GameColors.teal, GameColors.indigo, GameColors.cyan, GameColors.pink],
        [GameColors.amber, GameColors.red, GameColors.orange, GameColors.lime],
        [],
        [],
      ],
      maxMoves: 95,
      stars3Moves: 38,
      stars2Moves: 60,
    ),
    LevelData(
      id: 28,
      name: "Color Bomb",
      initialTubes: [
        [GameColors.red, GameColors.yellow, GameColors.blue, GameColors.green],
        [GameColors.yellow, GameColors.blue, GameColors.green, GameColors.red],
        [GameColors.blue, GameColors.green, GameColors.red, GameColors.yellow],
        [GameColors.green, GameColors.red, GameColors.yellow, GameColors.blue],
        [GameColors.purple, GameColors.orange, GameColors.cyan, GameColors.pink],
        [GameColors.orange, GameColors.cyan, GameColors.pink, GameColors.purple],
        [],
        [],
        [],
      ],
      maxMoves: 110,
      stars3Moves: 45,
      stars2Moves: 70,
    ),
    LevelData(
      id: 29,
      name: "Expert Only",
      initialTubes: [
        [GameColors.indigo, GameColors.teal, GameColors.pink, GameColors.cyan],
        [GameColors.lime, GameColors.amber, GameColors.red, GameColors.orange],
        [GameColors.cyan, GameColors.indigo, GameColors.teal, GameColors.pink],
        [GameColors.orange, GameColors.lime, GameColors.amber, GameColors.red],
        [GameColors.pink, GameColors.cyan, GameColors.indigo, GameColors.teal],
        [GameColors.red, GameColors.orange, GameColors.lime, GameColors.amber],
        [GameColors.teal, GameColors.pink],
        [],
        [],
      ],
      maxMoves: 120,
      stars3Moves: 48,
      stars2Moves: 75,
    ),
    LevelData(
      id: 30,
      name: "Final Boss",
      initialTubes: [
        [GameColors.red, GameColors.blue, GameColors.green, GameColors.yellow],
        [GameColors.purple, GameColors.orange, GameColors.cyan, GameColors.pink],
        [GameColors.teal, GameColors.indigo, GameColors.lime, GameColors.amber],
        [GameColors.yellow, GameColors.red, GameColors.blue, GameColors.green],
        [GameColors.pink, GameColors.purple, GameColors.orange, GameColors.cyan],
        [GameColors.amber, GameColors.teal, GameColors.indigo, GameColors.lime],
        [GameColors.green, GameColors.yellow, GameColors.red, GameColors.blue],
        [],
        [],
      ],
      maxMoves: 130,
      stars3Moves: 52,
      stars2Moves: 80,
    ),
  ];

  static LevelData getLevel(int id) {
    return levels.firstWhere((l) => l.id == id, orElse: () => levels.first);
  }

  static int get totalLevels => levels.length;
}
