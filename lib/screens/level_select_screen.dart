import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/level_data.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';
import '../utils/responsive.dart';
import 'game_screen.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    final levels = LevelRepository.levels;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: r.sp(6), vertical: r.sp(6)),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_ios_new_rounded, size: r.sp(22)),
                      color: AppTheme.textPrimary,
                    ),
                    Expanded(
                      child: Text(
                        'Select Level',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: r.sp(19),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Consumer<GameProvider>(
                      builder: (context, game, _) {
                        return Padding(
                          padding: EdgeInsets.only(right: r.sp(10)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star_rounded, color: AppTheme.warning, size: r.sp(17)),
                              SizedBox(width: r.sp(3)),
                              Text(
                                '${game.totalStars}',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: r.sp(13),
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

              // Grid
              Expanded(
                child: Consumer<GameProvider>(
                  builder: (context, game, _) {
                    return GridView.builder(
                      padding: EdgeInsets.fromLTRB(r.sp(14), r.sp(6), r.sp(14), r.sp(20)),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: r.levelGridCount,
                        crossAxisSpacing: r.sp(10),
                        mainAxisSpacing: r.sp(10),
                        childAspectRatio: r.isTablet ? 0.95 : 0.84,
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
                          r: r,
                          onTap: isUnlocked
                              ? () {
                                  game.loadLevel(level.id);
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (_, __, ___) => const GameScreen(),
                                      transitionsBuilder: (_, anim, __, child) {
                                        return FadeTransition(opacity: anim, child: child);
                                      },
                                    ),
                                  );
                                }
                              : null,
                        )
                            .animate(delay: (25 * index).ms)
                            .fadeIn(duration: 280.ms)
                            .scale(begin: const Offset(0.88, 0.88), curve: Curves.easeOutBack);
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
  final R r;
  final VoidCallback? onTap;

  const _LevelCard({
    required this.level,
    required this.isUnlocked,
    required this.stars,
    required this.r,
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
                  colors: [AppTheme.surfaceLight, AppTheme.card],
                )
              : null,
          color: isUnlocked ? null : AppTheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(r.sp(16)),
          border: Border.all(
            color: isUnlocked
                ? AppTheme.primary.withOpacity(0.3)
                : Colors.white.withOpacity(0.05),
            width: 1.4,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isUnlocked)
              Icon(Icons.lock_rounded, color: AppTheme.textSecondary.withOpacity(0.4), size: r.sp(26))
            else
              Text(
                '${level.id}',
                style: GoogleFonts.poppins(
                  fontSize: r.sp(24),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            SizedBox(height: r.sp(3)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: r.sp(5)),
              child: Text(
                level.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: r.sp(10),
                  fontWeight: FontWeight.w500,
                  color: isUnlocked
                      ? AppTheme.textSecondary
                      : AppTheme.textSecondary.withOpacity(0.3),
                ),
              ),
            ),
            if (isUnlocked) ...[
              SizedBox(height: r.sp(5)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return Icon(
                    i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: r.sp(14),
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
