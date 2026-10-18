import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/achievement.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      color: AppTheme.textPrimary,
                    ),
                    Expanded(
                      child: Text(
                        'Achievements',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              // Weekly badge banner
              Consumer<GameProvider>(
                builder: (context, game, _) {
                  if (!game.hasWeeklyBadge) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppTheme.goldGradient,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.gold.withOpacity(0.35),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Text('🥇', style: TextStyle(fontSize: 36)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Top Player Badge',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'Active for 7 days • You are among the top!',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().shimmer(duration: 2500.ms);
                },
              ),
              // Stats summary
              Consumer<GameProvider>(
                builder: (context, game, _) {
                  final unlocked = game.unlockedAchievements.length;
                  final total = AchievementRepository.all.length;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _miniStat(
                            'Unlocked',
                            '$unlocked / $total',
                            AppTheme.accent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _miniStat(
                            'Total Stars',
                            '${game.totalStars}',
                            AppTheme.warning,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // Achievements list
              Expanded(
                child: Consumer<GameProvider>(
                  builder: (context, game, _) {
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: AchievementRepository.all.length,
                      itemBuilder: (context, index) {
                        final ach = AchievementRepository.all[index];
                        final isUnlocked =
                            game.unlockedAchievements.contains(ach.id);

                        return _AchievementTile(
                          achievement: ach,
                          isUnlocked: isUnlocked,
                        )
                            .animate(delay: (40 * index).ms)
                            .fadeIn(duration: 300.ms)
                            .slideX(begin: 0.05, end: 0);
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

  Widget _miniStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;

  const _AchievementTile({
    required this.achievement,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUnlocked ? AppTheme.card : AppTheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked
              ? (achievement.isWeekly
                  ? AppTheme.gold.withOpacity(0.4)
                  : AppTheme.primary.withOpacity(0.25))
              : Colors.white.withOpacity(0.04),
        ),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: (achievement.isWeekly ? AppTheme.gold : AppTheme.primary)
                      .withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? (achievement.isWeekly
                      ? AppTheme.gold.withOpacity(0.2)
                      : AppTheme.primary.withOpacity(0.15))
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                isUnlocked ? achievement.icon : '🔒',
                style: TextStyle(fontSize: isUnlocked ? 24 : 18),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isUnlocked
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  achievement.description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isUnlocked
                        ? AppTheme.textSecondary
                        : AppTheme.textSecondary.withOpacity(0.35),
                  ),
                ),
              ],
            ),
          ),
          if (isUnlocked)
            Icon(
              Icons.check_circle_rounded,
              color: achievement.isWeekly ? AppTheme.gold : AppTheme.accent,
              size: 24,
            ),
        ],
      ),
    );
  }
}
