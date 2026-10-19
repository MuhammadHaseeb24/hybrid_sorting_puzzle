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
        [GameColors.green, GameColors.yellow, GameColors.yellow, GameColors.green],
        [GameColors.green, GameColors.yellow, GameColors.yellow, GameColors.green],
        [],
        [],
      ],
      maxMoves: 21,
      stars3Moves: 8,
      stars2Moves: 12,
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
        [GameColors.teal, GameColors.teal, GameColors.pink, GameColors.teal],
        [GameColors.pink, GameColors.indigo, GameColors.indigo, GameColors.teal],
        [GameColors.indigo, GameColors.indigo, GameColors.pink, GameColors.pink],
        [],
        [],
        [],
        [],
      ],
      maxMoves: 24,
      stars3Moves: 9,
      stars2Moves: 14,
    ),
    LevelData(
      id: 7,
      name: "Six Colors",
      initialTubes: [
        [GameColors.orange, GameColors.purple, GameColors.yellow, GameColors.red],
        [GameColors.red, GameColors.purple, GameColors.orange, GameColors.blue],
        [GameColors.yellow, GameColors.blue, GameColors.purple, GameColors.orange],
        [GameColors.red, GameColors.blue, GameColors.orange, GameColors.green],
        [GameColors.purple, GameColors.green, GameColors.yellow, GameColors.blue],
        [GameColors.yellow, GameColors.green, GameColors.green, GameColors.red],
        [],
        [],
      ],
      maxMoves: 63,
      stars3Moves: 27,
      stars2Moves: 40,
    ),
    LevelData(
      id: 8,
      name: "Master Puzzle",
      initialTubes: [
        [GameColors.cyan, GameColors.pink, GameColors.indigo, GameColors.teal],
        [GameColors.pink, GameColors.purple, GameColors.pink, GameColors.teal],
        [GameColors.teal, GameColors.indigo, GameColors.indigo, GameColors.teal],
        [GameColors.cyan, GameColors.orange, GameColors.pink, GameColors.purple],
        [GameColors.indigo, GameColors.cyan, GameColors.purple, GameColors.orange],
        [GameColors.orange, GameColors.orange, GameColors.cyan, GameColors.purple],
        [],
        [],
      ],
      maxMoves: 58,
      stars3Moves: 24,
      stars2Moves: 37,
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
        [GameColors.teal, GameColors.cyan, GameColors.pink, GameColors.indigo],
        [GameColors.indigo, GameColors.cyan, GameColors.teal, GameColors.pink],
        [GameColors.indigo, GameColors.pink, GameColors.indigo, GameColors.teal],
        [GameColors.cyan, GameColors.pink, GameColors.teal, GameColors.cyan],
        [],
        [],
        [],
      ],
      maxMoves: 44,
      stars3Moves: 18,
      stars2Moves: 27,
    ),
    LevelData(
      id: 11,
      name: "Layer Cake",
      initialTubes: [
        [GameColors.red, GameColors.yellow, GameColors.red, GameColors.green],
        [GameColors.yellow, GameColors.yellow, GameColors.blue, GameColors.blue],
        [GameColors.green, GameColors.green, GameColors.blue, GameColors.green],
        [GameColors.blue, GameColors.red, GameColors.red, GameColors.yellow],
        [],
        [],
      ],
      maxMoves: 32,
      stars3Moves: 13,
      stars2Moves: 19,
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
        [GameColors.blue, GameColors.lime, GameColors.lime, GameColors.blue],
        [GameColors.amber, GameColors.amber, GameColors.lime, GameColors.blue],
        [GameColors.red, GameColors.red, GameColors.blue, GameColors.amber],
        [GameColors.red, GameColors.red, GameColors.amber, GameColors.lime],
        [],
        [],
        [],
        [],
      ],
      maxMoves: 32,
      stars3Moves: 13,
      stars2Moves: 19,
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
        [GameColors.yellow, GameColors.cyan, GameColors.cyan, GameColors.yellow],
        [GameColors.lime, GameColors.pink, GameColors.pink, GameColors.yellow],
        [GameColors.lime, GameColors.cyan, GameColors.lime, GameColors.lime],
        [GameColors.pink, GameColors.cyan, GameColors.pink, GameColors.yellow],
        [],
        [],
        [],
      ],
      maxMoves: 35,
      stars3Moves: 14,
      stars2Moves: 21,
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
        [GameColors.purple, GameColors.purple, GameColors.pink, GameColors.purple],
        [GameColors.indigo, GameColors.pink, GameColors.purple, GameColors.pink],
        [GameColors.blue, GameColors.indigo, GameColors.blue, GameColors.blue],
        [GameColors.blue, GameColors.indigo, GameColors.pink, GameColors.indigo],
        [],
        [],
        [],
        [],
      ],
      maxMoves: 38,
      stars3Moves: 15,
      stars2Moves: 23,
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
        [GameColors.teal, GameColors.teal, GameColors.indigo, GameColors.indigo],
        [GameColors.purple, GameColors.teal, GameColors.teal, GameColors.indigo],
        [GameColors.indigo, GameColors.purple, GameColors.purple, GameColors.blue],
        [GameColors.blue, GameColors.blue, GameColors.purple, GameColors.blue],
        [],
        [],
        [],
      ],
      maxMoves: 30,
      stars3Moves: 12,
      stars2Moves: 18,
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
        [GameColors.indigo, GameColors.green, GameColors.red, GameColors.orange],
        [GameColors.blue, GameColors.indigo, GameColors.indigo, GameColors.blue],
        [GameColors.yellow, GameColors.red, GameColors.yellow, GameColors.green],
        [GameColors.green, GameColors.orange, GameColors.red, GameColors.red],
        [GameColors.orange, GameColors.green, GameColors.yellow, GameColors.blue],
        [GameColors.indigo, GameColors.yellow, GameColors.blue, GameColors.orange],
        [],
        [],
      ],
      maxMoves: 55,
      stars3Moves: 23,
      stars2Moves: 35,
    ),
    LevelData(
      id: 26,
      name: "Tight Squeeze",
      initialTubes: [
        [GameColors.orange, GameColors.red, GameColors.green, GameColors.purple],
        [GameColors.yellow, GameColors.blue, GameColors.blue, GameColors.orange],
        [GameColors.green, GameColors.green, GameColors.yellow, GameColors.red],
        [GameColors.blue, GameColors.red, GameColors.yellow, GameColors.purple],
        [GameColors.purple, GameColors.yellow, GameColors.blue, GameColors.red],
        [GameColors.purple, GameColors.green, GameColors.orange, GameColors.orange],
        [],
        [],
      ],
      maxMoves: 55,
      stars3Moves: 23,
      stars2Moves: 35,
    ),
    LevelData(
      id: 27,
      name: "Puzzle Master",
      initialTubes: [
        [GameColors.orange, GameColors.lime, GameColors.pink, GameColors.cyan],
        [GameColors.teal, GameColors.indigo, GameColors.pink, GameColors.teal],
        [GameColors.lime, GameColors.pink, GameColors.cyan, GameColors.teal],
        [GameColors.teal, GameColors.indigo, GameColors.indigo, GameColors.cyan],
        [GameColors.orange, GameColors.lime, GameColors.pink, GameColors.orange],
        [GameColors.orange, GameColors.lime, GameColors.indigo, GameColors.cyan],
        [],
        [],
      ],
      maxMoves: 60,
      stars3Moves: 25,
      stars2Moves: 38,
    ),
    LevelData(
      id: 28,
      name: "Color Bomb",
      initialTubes: [
        [GameColors.red, GameColors.yellow, GameColors.purple, GameColors.orange],
        [GameColors.blue, GameColors.yellow, GameColors.purple, GameColors.cyan],
        [GameColors.green, GameColors.purple, GameColors.orange, GameColors.red],
        [GameColors.green, GameColors.cyan, GameColors.purple, GameColors.blue],
        [GameColors.green, GameColors.cyan, GameColors.cyan, GameColors.blue],
        [GameColors.orange, GameColors.green, GameColors.yellow, GameColors.blue],
        [GameColors.yellow, GameColors.red, GameColors.orange, GameColors.red],
        [],
        [],
      ],
      maxMoves: 72,
      stars3Moves: 30,
      stars2Moves: 46,
    ),
    LevelData(
      id: 29,
      name: "Expert Only",
      initialTubes: [
        [GameColors.lime, GameColors.pink, GameColors.lime, GameColors.pink],
        [GameColors.lime, GameColors.teal, GameColors.red, GameColors.red],
        [GameColors.red, GameColors.amber, GameColors.teal, GameColors.lime],
        [GameColors.amber, GameColors.cyan, GameColors.cyan, GameColors.indigo],
        [GameColors.amber, GameColors.teal, GameColors.teal, GameColors.cyan],
        [GameColors.red, GameColors.cyan, GameColors.indigo, GameColors.amber],
        [GameColors.indigo, GameColors.indigo, GameColors.pink, GameColors.pink],
        [],
        [],
      ],
      maxMoves: 60,
      stars3Moves: 25,
      stars2Moves: 38,
    ),
    LevelData(
      id: 30,
      name: "Final Boss",
      initialTubes: [
        [GameColors.purple, GameColors.red, GameColors.green, GameColors.cyan],
        [GameColors.red, GameColors.cyan, GameColors.purple, GameColors.yellow],
        [GameColors.blue, GameColors.orange, GameColors.blue, GameColors.cyan],
        [GameColors.blue, GameColors.yellow, GameColors.red, GameColors.green],
        [GameColors.green, GameColors.blue, GameColors.red, GameColors.cyan],
        [GameColors.green, GameColors.yellow, GameColors.orange, GameColors.purple],
        [GameColors.orange, GameColors.orange, GameColors.purple, GameColors.yellow],
        [],
        [],
      ],
      maxMoves: 69,
      stars3Moves: 29,
      stars2Moves: 44,
    ),
  ];

  static LevelData getLevel(int id) {
    return levels.firstWhere((l) => l.id == id, orElse: () => levels.first);
  }

  static int get totalLevels => levels.length;
}
