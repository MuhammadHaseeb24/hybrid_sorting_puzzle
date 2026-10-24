import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/level_data.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';
import '../utils/navigation.dart';
import '../utils/responsive.dart';
import '../utils/world_theme.dart';
import '../widgets/animated_backdrop.dart';
import '../widgets/jelly_button.dart';
import '../widgets/tube_widget.dart';

/// Home tab (centre of the bottom navigation). Shown inside [MainShell].
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<GameProvider>(
        builder: (context, game, _) {
          final lvl = game.unlockedLevel > LevelRepository.totalLevels
              ? LevelRepository.totalLevels
              : game.unlockedLevel;
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
                              Row(
                                children: [
                                  if (game.hasWeeklyBadge)
                                    _badge(r)
                                  else
                                    SizedBox(height: r.sp(36)),
                                  const Spacer(),
                                  _coinPill(game.coins, r),
                                ],
                              ),
                              const Spacer(flex: 1),
                              _logoScene(r, theme),
                              SizedBox(height: r.sp(16)),
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
                                spacing: 10,
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
                                  _chip(Icons.public_rounded,
                                      'Ch ${theme.index + 1} • ${theme.name}',
                                      theme.orb, r),
                                ],
                              ).animate().fadeIn(delay: 350.ms),
                              const Spacer(flex: 1),
                              JellyButton(
                                label: 'PLAY  •  LEVEL $lvl',
                                icon: Icons.play_arrow_rounded,
                                width: r.sp(280),
                                height: r.sp(r.isSmall ? 56 : 64),
                                fontSize: r.sp(18),
                                colors: [
                                  Color.lerp(theme.primary, Colors.white, 0.25)!,
                                  theme.primary,
                                ],
                                onTap: () => startLevel(context),
                              )
                                  .animate(
                                      onPlay: (c) => c.repeat(reverse: true))
                                  .scale(
                                    begin: const Offset(1, 1),
                                    end: const Offset(1.04, 1.04),
                                    duration: 1100.ms,
                                    curve: Curves.easeInOut,
                                  ),
                              SizedBox(height: r.sp(20)),
                              Text(
                                '320 levels • 11 chapters',
                                style: GoogleFonts.poppins(
                                  fontSize: r.sp(11),
                                  color:
                                      AppTheme.textSecondary.withOpacity(0.55),
                                ),
                              ),
                              SizedBox(height: r.sp(8)),
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

  /// Five glass tubes standing on a glossy podium with a glowing halo.
  Widget _logoScene(R r, WorldTheme theme) {
    var w = r.sp(r.isSmall ? 40 : 48);
    final maxW = (r.width - 48) / 6.4;
    if (w > maxW) w = maxW;
    final h = w * 3.0;
    final gap = w * 0.35;
    final rowW = w * 5 + gap * 4;

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

    final tubes = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        tube([GameColors.pink, GameColors.purple, GameColors.pink], 0, 3),
        SizedBox(width: gap),
        tube([
          GameColors.cyan,
          GameColors.blue,
          GameColors.cyan,
          GameColors.mint
        ], 250, 4),
        SizedBox(width: gap),
        tube([GameColors.yellow, GameColors.orange, GameColors.red], 500, 3),
        SizedBox(width: gap),
        tube([GameColors.green, GameColors.green], 750, 4),
        SizedBox(width: gap),
        tube([GameColors.violet, GameColors.indigo, GameColors.violet], 1000, 3),
      ],
    );

    return SizedBox(
      width: rowW + 40,
      height: h + w * 0.9,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // halo
          Positioned(
            bottom: w * 0.2,
            child: Container(
              width: rowW * 1.15,
              height: h * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.primary.withOpacity(0.45),
                    theme.primary.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fade(begin: 0.6, end: 1.0, duration: 1800.ms),
          // podium
          Positioned(
            bottom: 0,
            child: _podium(rowW + 28, w, theme),
          ),
          Positioned(
            bottom: w * 0.42,
            child: tubes,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.08, end: 0);
  }

  Widget _podium(double width, double w, WorldTheme theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // top slab
        Container(
          width: width,
          height: w * 0.34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(w * 0.16),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.55),
                Color.lerp(theme.orb, Colors.white, 0.2)!.withOpacity(0.35),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.55)),
            boxShadow: [
              BoxShadow(
                color: theme.primary.withOpacity(0.7),
                blurRadius: 22,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        // base
        Container(
          width: width * 0.88,
          height: w * 0.3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(w * 0.2),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.black.withOpacity(0.35),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
        ),
      ],
    );
  }

  Widget _coinPill(int coins, R r) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.sp(12), vertical: r.sp(6)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.14),
            Colors.black.withOpacity(0.25),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.gold.withOpacity(0.55)),
        boxShadow: [
          BoxShadow(color: AppTheme.gold.withOpacity(0.2), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.monetization_on_rounded,
              color: AppTheme.gold, size: r.sp(20)),
          SizedBox(width: r.sp(6)),
          Text(
            '$coins',
            style: GoogleFonts.poppins(
              fontSize: r.sp(14),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
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
