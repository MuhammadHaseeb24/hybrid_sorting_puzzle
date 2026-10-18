import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/level_data.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';
import '../utils/responsive.dart';
import 'level_select_screen.dart';
import 'settings_screen.dart';
import 'achievements_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = R(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: r.screenPadding,
                      child: Column(
                        children: [
                          // Top badge
                          Align(
                            alignment: Alignment.centerRight,
                            child: Consumer<GameProvider>(
                              builder: (context, game, _) {
                                if (!game.hasWeeklyBadge) {
                                  return SizedBox(height: r.sp(36));
                                }
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: r.sp(12),
                                    vertical: r.sp(6),
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.goldGradient,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.gold.withOpacity(0.4),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('🥇', style: TextStyle(fontSize: r.sp(14))),
                                      SizedBox(width: r.sp(6)),
                                      Text(
                                        'Top Player',
                                        style: GoogleFonts.poppins(
                                          fontSize: r.sp(12),
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ).animate().fadeIn().shimmer(duration: 2000.ms);
                              },
                            ),
                          ),

                          SizedBox(height: r.isSmall ? 12 : 24),

                          // Logo
                          _buildLogo(r)
                              .animate()
                              .fadeIn(duration: 600.ms)
                              .slideY(begin: -0.15, end: 0, curve: Curves.easeOutCubic),

                          SizedBox(height: r.sp(10)),

                          Text(
                            'Sort • Guide • Escape',
                            style: GoogleFonts.poppins(
                              fontSize: r.sp(14),
                              fontWeight: FontWeight.w400,
                              color: AppTheme.textSecondary,
                              letterSpacing: 1.2,
                            ),
                          ).animate().fadeIn(delay: 250.ms),

                          SizedBox(height: r.sp(18)),

                          // Stats
                          Consumer<GameProvider>(
                            builder: (context, game, _) {
                              return Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 12,
                                runSpacing: 8,
                                children: [
                                  _statChip(Icons.star_rounded, '${game.totalStars}', AppTheme.warning, r),
                                  _statChip(
                                    Icons.flag_rounded,
                                    '${game.unlockedLevel - 1}/${LevelRepository.totalLevels}',
                                    AppTheme.accent,
                                    r,
                                  ),
                                ],
                              ).animate().fadeIn(delay: 350.ms);
                            },
                          ),

                          const Spacer(),

                          // Play button
                          _buildPlayButton(context, r)
                              .animate()
                              .fadeIn(delay: 450.ms)
                              .scale(begin: const Offset(0.85, 0.85), curve: Curves.easeOutBack),

                          SizedBox(height: r.sp(18)),

                          // Secondary buttons
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 12,
                            runSpacing: 10,
                            children: [
                              _secondaryButton(
                                icon: Icons.emoji_events_rounded,
                                label: 'Achievements',
                                r: r,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                                  );
                                },
                              ),
                              _secondaryButton(
                                icon: Icons.settings_rounded,
                                label: 'Settings',
                                r: r,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                                  );
                                },
                              ),
                            ],
                          ).animate().fadeIn(delay: 600.ms),

                          const Spacer(),

                          Text(
                            'Hybrid Casual Puzzle 2026',
                            style: GoogleFonts.poppins(
                              fontSize: r.sp(11),
                              color: AppTheme.textSecondary.withOpacity(0.5),
                            ),
                          ),
                          SizedBox(height: r.sp(12)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String value, Color color, R r) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.sp(14), vertical: r.sp(8)),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: r.sp(17), color: color),
          SizedBox(width: r.sp(6)),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: r.sp(13),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(R r) {
    final size = r.sp(r.isSmall ? 78 : 96);
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppTheme.primary, AppTheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.45),
                blurRadius: 28,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Icon(Icons.auto_awesome, size: size * 0.46, color: Colors.white),
        ),
        SizedBox(height: r.sp(16)),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppTheme.primary, AppTheme.accent, AppTheme.secondary],
          ).createShader(bounds),
          child: Text(
            'SORTIFY',
            style: GoogleFonts.poppins(
              fontSize: r.sp(r.isSmall ? 32 : 40),
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 3,
            ),
          ),
        ),
        Text(
          'HYBRID SORTING',
          style: GoogleFonts.poppins(
            fontSize: r.sp(12),
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
            letterSpacing: 3.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButton(BuildContext context, R r) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const LevelSelectScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.08),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                  child: child,
                ),
              );
            },
          ),
        );
      },
      child: Container(
        width: r.sp(r.isSmall ? 190 : 210),
        height: r.sp(r.isSmall ? 52 : 60),
        decoration: BoxDecoration(
          gradient: AppTheme.buttonGradient,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.45),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow_rounded, size: r.sp(30), color: Colors.white),
            SizedBox(width: r.sp(6)),
            Text(
              'PLAY',
              style: GoogleFonts.poppins(
                fontSize: r.sp(20),
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _secondaryButton({
    required IconData icon,
    required String label,
    required R r,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: r.sp(16), vertical: r.sp(11)),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight.withOpacity(0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.textSecondary, size: r.sp(18)),
            SizedBox(width: r.sp(7)),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: r.sp(12.5),
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
