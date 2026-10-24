import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/level_data.dart';
import '../providers/game_provider.dart';
import '../screens/game_screen.dart';

/// Loads [level] (or the player's current level) and opens the game screen.
void startLevel(BuildContext context, {int? level}) {
  final game = context.read<GameProvider>();
  final id = level ??
      (game.unlockedLevel > LevelRepository.totalLevels
          ? LevelRepository.totalLevels
          : game.unlockedLevel);
  game.loadLevel(id);
  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => const GameScreen(),
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
    ),
  );
}
