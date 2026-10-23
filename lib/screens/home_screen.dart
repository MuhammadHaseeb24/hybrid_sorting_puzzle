import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/level_data.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';
import '../utils/responsive.dart';
import '../utils/world_theme.dart';
import '../widgets/animated_backdrop.dart';
import '../widgets/jelly_button.dart';
import '../widgets/tube_widget.dart';
import 'achievements_screen.dart';
import 'level_select_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    return Scaffold(
      body: Consumer<GameProvider>(
        builder: (context, game, _) {
          final lvl = game.unlockedLevel.clamp(1, LevelRepository.totalLevels);
          final theme = WorldTheme.forLevel(lvl);
          return AnimatedBackdrop(
            theme: theme,
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: r.screenPadding,
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: game.hasWeeklyBadge
                                    ? _badge(r)
                                    : SizedBox(height: r.sp(36)),
                              ),
                              const Spacer(flex: 1),
                              _logoTubes(r),
                              SizedBox(height: r.sp(14)),
                              ShaderMask(
                                shaderCallback: (b) => const LinearGradient(
                                  colors: [
                                    Color(0xFFB9A8FF),
                                    Colors.white,
                                    Color(0xFF7CF5D0),
                                  ],
                                ).createShader(b),
                                child: Text(
                                  'SORTIFY',
                                  style: GoogleFonts.poppins(
                                    fontSize: r.sp(r.isSmall ? 38 : 46),
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 4,
                                    shadows: [
                                      Shadow(
                                        color: theme.primary.withOpacity(0.8),
                                        blurRadius: 24,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                                  .animate()
                                  .fadeIn(duration: 500.ms)
                                  .slideY(begin: -0.2, end: 0),
                              Text(
                                '3D LIQUID SORTING',
                                style: GoogleFonts.poppins(
                                  fontSize: r.sp(12),
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary,
                                  letterSpacing: 4,
                                ),
                              ).animate().fadeIn(delay: 250.ms),
                              SizedBox(height: r.sp(18)),
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 12,
                                runSpacing: 8,
                                children: [
                                  _chip(Icons.star_rounded, '${game.totalStars}',
                                      AppTheme.warning, r),
                                  _chip(
                                    Icons.flag_rounded,
                                    '${game.unlockedLevel - 1}/${LevelRepository.totalLevels}',
                                    AppTheme.accent,
                                    r,
                                  ),
                                  _chip(Icons.public_rounded, theme.name,
                                      theme.orb, r),
                                ],
                              ).animate().fadeIn(delay: 350.ms),
                              const Spacer(flex: 1),
                              JellyButton(
                                label: 'PLAY  •  LEVEL $lvl',
                                icon: Icons.play_arrow_rounded,
                                width: r.sp(270),
                                height: r.sp(r.isSmall ? 56 : 64),
                                fontSize: r.sp(18),
                                colors: [
                                  Color.lerp(theme.primary, Colors.white, 0.25)!,
                                  theme.primary,
                                ],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (_, __, ___) =>
                                          const LevelSelectScreen(),
                                      transitionsBuilder: (_, a, __, child) =>
                                          FadeTransition(
                                        opacity: a,
                                        child: SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0, 0.06),
                                            end: Offset.zero,
                                          ).animate(CurvedAnimation(
                                              parent: a,
                                              curve: Curves.easeOutCubic)),
                                          child: child,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                                  .animate(
                                      onPlay: (c) => c.repeat(reverse: true))
                                  .scale(
                                    begin: const Offset(1, 1),
                                    end: const Offset(1.04, 1.04),
                                    duration: 1100.ms,
                                    curve: Curves.easeInOut,
                                  ),
                              SizedBox(height: r.sp(18)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  JellyButton(
                                    label: 'Awards',
                                    icon: Icons.emoji_events_rounded,
                                    height: r.sp(46),
                                    width: r.sp(140),
                                    fontSize: r.sp(13),
                                    colors: const [
                                      Color(0xFFFFC857),
                                      Color(0xFFF59E0B),
                                    ],
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const AchievementsScreen()),
                                    ),
                                  ),
                                  SizedBox(width: r.sp(14)),
                                  JellyButton(
                                    label: 'Settings',
                                    icon: Icons.settings_rounded,
                                    height: r.sp(46),
                                    width: r.sp(140),
                                    fontSize: r.sp(13),
                                    colors: const [
                                      Color(0xFF8A94B8),
                                      Color(0xFF5B6585),
                                    ],
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const SettingsScreen()),
                                    ),
                                  ),
                                ],
                              ).animate().fadeIn(delay: 600.ms),
                              const Spacer(flex: 1),
                              Text(
                                '320 levels • 11 worlds',
                                style: GoogleFonts.poppins(
                                  fontSize: r.sp(11),
                                  color: AppTheme.textSecondary
                                      .withOpacity(0.55),
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
          );
        },
      ),
    );
  }

  Widget _logoTubes(R r) {
    final w = r.sp(r.isSmall ? 44 : 54);
    final h = w * 3.0;
    Widget tube(List<Color> cols, int delay, double dy) {
      return TubeWidget(
        bands: TubeWidget.bandsOf(cols),
        capacity: 4,
        width: w,
        height: h,
      )
          .animate(
            delay: delay.ms,
            onPlay: (c) => c.repeat(reverse: true),
          )
          .moveY(
            begin: -dy,
            end: dy,
            duration: 2200.ms,
            curve: Curves.easeInOut,
          );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        tube([GameColors.pink, GameColors.purple, GameColors.pink], 0, 5),
        SizedBox(width: w * 0.35),
        tube([
          GameColors.cyan,
          GameColors.blue,
          GameColors.cyan,
          GameColors.mint
        ], 300, 7),
        SizedBox(width: w * 0.35),
        tube([GameColors.yellow, GameColors.orange, GameColors.red], 600, 5),
        SizedBox(width: w * 0.35),
        tube([GameColors.green, GameColors.green], 900, 6),
      ],
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _badge(R r) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.sp(12), vertical: r.sp(6)),
      decoration: BoxDecoration(
        gradient: AppTheme.goldGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppTheme.gold.withOpacity(0.4), blurRadius: 8),
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
  }

  Widget _chip(IconData icon, String value, Color color, R r) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.sp(14), vertical: r.sp(8)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.4)),
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
}
