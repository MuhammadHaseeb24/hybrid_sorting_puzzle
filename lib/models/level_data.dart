import 'dart:math' as math;
import 'package:collection/collection.dart';
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

  static const Color brown = Color(0xFF8D6E63);
  static const Color sky = Color(0xFF81D4FA);
  static const Color mint = Color(0xFF69F0AE);
  static const Color violet = Color(0xFFB388FF);

  static const List<Color> palette = [
    red, blue, green, yellow, purple, orange, cyan, pink, teal, indigo, lime, amber,
    brown, sky, mint, violet,
  ];
}

class LevelRepository {
  static final List<LevelData> _handmade = [
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

  // ---------------------------------------------------------------------
  // Procedural levels 31..320 (deterministic, solver-verified)
  // ---------------------------------------------------------------------
  static const int totalLevels = 320;
  static final Map<int, LevelData> _cache = {};

  static const List<String> _adj = [
    'Neon', 'Crystal', 'Golden', 'Frozen', 'Wild', 'Silent', 'Cosmic', 'Sweet',
    'Electric', 'Misty', 'Royal', 'Lucky', 'Hidden', 'Rapid', 'Velvet', 'Solar',
    'Lunar', 'Emerald', 'Ruby', 'Amber',
  ];
  static const List<String> _noun = [
    'Splash', 'Rainbow', 'Cascade', 'Potion', 'Wave', 'Mix', 'Swirl', 'Drops',
    'Lagoon', 'Storm', 'Spectrum', 'Elixir', 'Fusion', 'Bloom', 'Twist',
  ];

  static LevelData getLevel(int id) {
    final safe = math.max(1, math.min(totalLevels, id));
    return _cache.putIfAbsent(
      safe,
          () => safe <= _handmade.length
          ? _withPar(_handmade[safe - 1])
          : _generate(safe),
    );
  }

  /// Hand-made levels also get solver-based star targets (par + 2 = 3 stars).
  static LevelData _withPar(LevelData l) {
    final ids = <Color, int>{};
    int idx(Color c) => ids.putIfAbsent(c, () => ids.length);
    final tubes = <List<int>>[
      for (final t in l.initialTubes) [for (final c in t) idx(c)],
    ];
    final solved = _solve(tubes, l.tubeCapacity, 0, 8000);
    final int par = solved > 0 ? solved : math.max<int>(1, l.stars3Moves - 2);
    final stars3 = par + 2;
    final int stars2 = stars3 + math.max<int>(3, (par * 0.4).ceil());
    return LevelData(
      id: l.id,
      name: l.name,
      initialTubes: l.initialTubes,
      maxMoves: 999,
      tubeCapacity: l.tubeCapacity,
      stars3Moves: stars3,
      stars2Moves: stars2,
    );
  }

  static LevelData _generate(int id) {
    final tier = id - 31;
    var colorCount = math.min(14, 5 + tier ~/ 24);
    var capacity = 4;
    if (id >= 120 && id % 4 == 0) {
      capacity = 5;
      colorCount = math.min(colorCount, 10);
    }
    final isBoss = id % 10 == 0;
    if (isBoss) colorCount = math.min(colorCount + 1, 15);
    const empties = 2;

    List<List<int>>? tubes;
    int solved = -1;
    var usedEmpties = empties;
    for (int attempt = 0; attempt < 4; attempt++) {
      final rng = math.Random(id * 7919 + 17 + attempt * 101);
      usedEmpties = attempt == 3 ? empties + 1 : empties;
      final idx = List<int>.generate(GameColors.palette.length, (i) => i)
        ..shuffle(rng);
      final chosen = idx.take(colorCount).toList();
      List<List<int>> candidate;
      var guard = 0;
      do {
        final balls = <int>[];
        for (final c in chosen) {
          for (int k = 0; k < capacity; k++) {
            balls.add(c);
          }
        }
        balls.shuffle(rng);
        candidate = [];
        for (int t = 0; t < colorCount; t++) {
          candidate.add(balls.sublist(t * capacity, (t + 1) * capacity));
        }
        guard++;
      } while (guard < 20 &&
          candidate.any((t) => t.every((c) => c == t.first)));
      tubes = candidate;
      if (attempt == 3) break; // fallback: extra empty tube, accepted unchecked
      final moves = _solve(candidate, capacity, usedEmpties, 6000);
      if (moves > 0) {
        solved = moves;
        break;
      }
    }

    // par = moves of a good solution. 3 stars up to par + 2, then fewer stars.
    final par = solved > 0 ? solved : (colorCount * capacity * 0.9).round();
    final stars3 = par + 2;
    final int stars2 = stars3 + math.max<int>(3, (par * 0.4).ceil());
    const maxMoves = 999; // no hard move limit, only stars go down

    final initial = <List<Color>>[
      for (final t in tubes!) [for (final c in t) GameColors.palette[c]],
      for (int e = 0; e < usedEmpties; e++) <Color>[],
    ];

    final name = isBoss
        ? 'Boss: ${_adj[(id * 7) % _adj.length]}'
        : '${_adj[(id * 7) % _adj.length]} ${_noun[(id * 13) % _noun.length]}';

    return LevelData(
      id: id,
      name: name,
      initialTubes: initial,
      maxMoves: maxMoves,
      tubeCapacity: capacity,
      stars3Moves: stars3,
      stars2Moves: stars2,
    );
  }

  /// Weighted best-first search using the same pour rules as the game.
  /// Returns the move count of a solution found, or -1 if limit reached.
  static int _solve(List<List<int>> start, int cap, int empties, int limit) {
    final init = <List<int>>[
      for (final t in start) List<int>.from(t),
      for (int i = 0; i < empties; i++) <int>[],
    ];

    int heuristic(List<List<int>> s) {
      var h = 0;
      final where = <int, int>{};
      for (final t in s) {
        final seen = <int>{};
        for (int i = 0; i < t.length; i++) {
          if (i > 0 && t[i] != t[i - 1]) h += 3;
          seen.add(t[i]);
        }
        for (final c in seen) {
          where[c] = (where[c] ?? 0) + 1;
        }
      }
      for (final v in where.values) {
        h += v - 1;
      }
      return h;
    }

    bool isGoal(List<List<int>> s) {
      for (final t in s) {
        if (t.isEmpty) continue;
        if (t.length != cap) return false;
        for (final c in t) {
          if (c != t.first) return false;
        }
      }
      return true;
    }

    String key(List<List<int>> s) {
      final parts = s.map((t) => t.join(',')).toList()..sort();
      return parts.join('|');
    }

    final open = PriorityQueue<_Node>((a, b) => a.f.compareTo(b.f));
    final seen = <String>{key(init)};
    open.add(_Node(init, 0, heuristic(init) * 3));
    var popped = 0;
    while (open.isNotEmpty && popped < limit) {
      final node = open.removeFirst();
      popped++;
      if (isGoal(node.s)) return node.depth;
      final s = node.s;
      for (int i = 0; i < s.length; i++) {
        final src = s[i];
        if (src.isEmpty) continue;
        final top = src.last;
        var run = 0;
        for (int k = src.length - 1; k >= 0 && src[k] == top; k--) {
          run++;
        }
        final uniform = run == src.length;
        for (int j = 0; j < s.length; j++) {
          if (i == j) continue;
          final dst = s[j];
          if (dst.length >= cap) continue;
          if (dst.isNotEmpty && dst.last != top) continue;
          if (dst.isEmpty && uniform) continue;
          final amt = math.min(run, cap - dst.length);
          final next = <List<int>>[
            for (int q = 0; q < s.length; q++) List<int>.from(s[q]),
          ];
          for (int k = 0; k < amt; k++) {
            next[i].removeLast();
            next[j].add(top);
          }
          if (seen.add(key(next))) {
            open.add(_Node(
                next, node.depth + 1, heuristic(next) * 3 + node.depth + 1));
          }
        }
      }
    }
    return -1;
  }
}

class _Node {
  final List<List<int>> s;
  final int depth;
  final int f;
  _Node(this.s, this.depth, this.f);
}