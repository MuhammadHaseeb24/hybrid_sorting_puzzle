import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/level_data.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';
import 'game_screen.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final levels = LevelRepository.levels;
    final size = MediaQuery.of(context).size;
    final crossAxisCount = size.width > 600 ? 4 : 3;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      color: AppTheme.textPrimary,
                    ),
                    Expanded(
                      child: Text(
                        'Select Level',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Consumer<GameProvider>(
                      builder: (context, game, _) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: AppTheme.warning, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                '${game.totalStars}',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Levels grid
              Expanded(
                child: Consumer<GameProvider>(
                  builder: (context, game, _) {
                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: levels.length,
                      itemBuilder: (context, index) {
                        final level = levels[index];
                        final isUnlocked = game.isLevelUnlocked(level.id);
                        final stars = game.getStarsForLevel(level.id);

                        return _LevelCard(
                          level: level,
                          isUnlocked: isUnlocked,
                          stars: stars,
                          onTap: isUnlocked
                              ? () {
                                  game.loadLevel(level.id);
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (_, __, ___) =>
                                          const GameScreen(),
                                      transitionsBuilder: (_, anim, __, child) {
                                        return FadeTransition(
                                          opacity: anim,
                                          child: child,
                                        );
                                      },
                                    ),
                                  );
                                }
                              : null,
                        )
                            .animate(delay: (30 * index).ms)
                            .fadeIn(duration: 300.ms)
                            .scale(
                              begin: const Offset(0.85, 0.85),
                              curve: Curves.easeOutBack,
                            );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final LevelData level;
  final bool isUnlocked;
  final int stars;
  final VoidCallback? onTap;

  const _LevelCard({
    required this.level,
    required this.isUnlocked,
    required this.stars,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: isUnlocked
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.surfaceLight,
                    AppTheme.card,
                  ],
                )
              : null,
          color: isUnlocked ? null : AppTheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isUnlocked
                ? AppTheme.primary.withOpacity(0.3)
                : Colors.white.withOpacity(0.05),
            width: 1.5,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isUnlocked)
              Icon(
                Icons.lock_rounded,
                color: AppTheme.textSecondary.withOpacity(0.4),
                size: 28,
              )
            else
              Text(
                '${level.id}',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                level.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isUnlocked
                      ? AppTheme.textSecondary
                      : AppTheme.textSecondary.withOpacity(0.3),
                ),
              ),
            ),
            if (isUnlocked) ...[
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return Icon(
                    i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 15,
                    color: i < stars
                        ? AppTheme.warning
                        : AppTheme.textSecondary.withOpacity(0.3),
                  );
                }),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
