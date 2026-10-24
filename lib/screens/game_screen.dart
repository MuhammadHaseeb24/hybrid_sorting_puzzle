import 'dart:math' as math;
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';
import '../utils/haptics.dart';
import '../utils/responsive.dart';
import '../utils/world_theme.dart';
import '../widgets/ad_dialog.dart';
import '../widgets/animated_backdrop.dart';
import '../widgets/booster_button.dart';
import '../widgets/jelly_button.dart';
import '../widgets/tube_board.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final ConfettiController _confetti =
      ConfettiController(duration: const Duration(seconds: 3));
  bool _celebrated = false;

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  void _showAd(BuildContext context, String title, String reward,
      VoidCallback onDone) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AdDialog(title: title, rewardText: reward, onComplete: onDone),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    return Consumer<GameProvider>(
      builder: (context, game, _) {
        final theme = WorldTheme.forLevel(game.currentLevel.id);

        if (game.status == GameStatus.won && !_celebrated) {
          _celebrated = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _confetti.play();
          });
        } else if (game.status != GameStatus.won) {
          _celebrated = false;
        }

        return Scaffold(
          body: AnimatedBackdrop(
            theme: theme,
            child: Stack(
              children: [
                SafeArea(
                  child: Column(
                    children: [
                      _topBar(context, game, theme, r),
                      _movesBar(game, theme, r),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: r.isTablet ? 24 : 6),
                          child: TubeBoard(game: game, theme: theme),
                        ),
                      ),
                      _boosters(context, game, r),
                      SizedBox(height: r.isSmall ? 6 : 14),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confetti,
                    blastDirectionality: BlastDirectionality.explosive,
                    emissionFrequency: 0.05,
                    numberOfParticles: 28,
                    gravity: 0.25,
                    shouldLoop: false,
                    colors: const [
                      Colors.red,
                      Colors.blue,
                      Colors.green,
                      Colors.yellow,
                      Colors.purple,
                      Colors.orange,
                      Colors.pink,
                    ],
                  ),
                ),
                if (game.status == GameStatus.won)
                  _WinOverlay(game: game, theme: theme),
                if (game.status == GameStatus.lost)
                  _LoseOverlay(game: game, theme: theme),
              ],
            ),
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------------
  Widget _topBar(
      BuildContext context, GameProvider game, WorldTheme theme, R r) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 4),
      child: Row(
        children: [
          _roundIcon(Icons.arrow_back_ios_new_rounded, () {
            Navigator.pop(context);
          }),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'LEVEL ${game.currentLevel.id}',
                  style: GoogleFonts.poppins(
                    fontSize: r.sp(20),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  '${theme.icon} ${game.currentLevel.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: r.sp(11),
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _coinChip(game.coins),
          const SizedBox(width: 8),
          _roundIcon(Icons.refresh_rounded, game.resetLevel),
          const SizedBox(width: 8),
          _roundIcon(Icons.pause_rounded, () => _showPause(context)),
        ],
      ),
    );
  }

  Widget _roundIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        Haptics.tap();
        onTap();
      },
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.1),
          border: Border.all(color: Colors.white.withOpacity(0.25)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _coinChip(int coins) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: AppTheme.gold.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.monetization_on_rounded,
              size: 18, color: AppTheme.gold),
          const SizedBox(width: 4),
          Text(
            '$coins',
            style: GoogleFonts.poppins(
                fontSize: 13, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  /// Moves + live star rating: up to par+2 moves = 3 stars, then 2, then 1.
  Widget _movesBar(GameProvider game, WorldTheme theme, R r) {
    final lvl = game.currentLevel;
    final s3 = lvl.stars3Moves;
    final s2 = lvl.stars2Moves;
    final stars = game.starsNow;
    final Color tone = stars == 3
        ? AppTheme.accent
        : (stars == 2 ? AppTheme.warning : AppTheme.secondary);
    final String info = stars == 3
        ? 'Keep 3★ for ${s3 - game.moves} more moves'
        : (stars == 2
            ? 'Keep 2★ for ${s2 - game.moves} more moves'
            : 'Just finish the level for 1★');

    return Container(
      margin: EdgeInsets.symmetric(horizontal: r.isTablet ? 32 : 14, vertical: 6),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.10),
            Colors.black.withOpacity(0.28),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tone.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(color: tone.withOpacity(0.15), blurRadius: 12),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'MOVES',
                style: GoogleFonts.poppins(
                    fontSize: 9,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary),
              ),
              Text(
                '${game.moves}',
                style: GoogleFonts.poppins(
                    fontSize: 24,
                    height: 1.0,
                    fontWeight: FontWeight.w900,
                    color: tone),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              final lit = i < stars;
              return AnimatedScale(
                scale: lit ? 1.0 : 0.78,
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutBack,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    Icons.star_rounded,
                    key: ValueKey(lit),
                    size: 32,
                    color: lit ? AppTheme.gold : Colors.white.withOpacity(0.22),
                    shadows: lit
                        ? [Shadow(color: AppTheme.gold.withOpacity(0.7), blurRadius: 10)]
                        : null,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              info,
              textAlign: TextAlign.right,
              maxLines: 2,
              style: GoogleFonts.poppins(
                  fontSize: 11,
                  height: 1.25,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.surfaceLight,
        content: Text(msg, style: GoogleFonts.poppins()),
      ));
  }

  void _buyTube(BuildContext context, GameProvider game) {
    switch (game.buyExtraTube()) {
      case TubeBuyResult.ok:
      case TubeBuyResult.busy:
        break;
      case TubeBuyResult.maxed:
        Haptics.light();
        _toast(context, 'You can add only 2 extra tubes per game');
        break;
      case TubeBuyResult.noCoins:
        Haptics.light();
        _showAd(context, 'Not enough coins',
            'Watch a short ad to get +50 coins', () => game.addCoinsFromAd(50));
        break;
    }
  }

  Widget _boosters(BuildContext context, GameProvider game, R r) {
    final playing = game.status == GameStatus.playing;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        BoosterButton(
          icon: Icons.undo_rounded,
          label: 'Undo',
          count: game.undoCount,
          color: AppTheme.primary,
          size: r.sp(56),
          onTap: playing
              ? () {
                  if (game.undoCount <= 0) {
                    _showAd(context, 'Get 3 Undos',
                        'Watch a short ad to get +3 Undos', game.addUndoFromAd);
                  } else if (game.history.isNotEmpty) {
                    game.undo();
                  }
                }
              : null,
        ),
        BoosterButton(
          icon: Icons.lightbulb_rounded,
          label: 'Hint',
          count: game.hintCount,
          color: const Color(0xFFF59E0B),
          size: r.sp(56),
          onTap: playing
              ? () {
                  if (game.hintCount <= 0) {
                    _showAd(context, 'Get 3 Hints',
                        'Watch a short ad to get +3 Hints', game.addHintFromAd);
                  } else {
                    game.useHint();
                  }
                }
              : null,
        ),
        BoosterButton(
          icon: Icons.add_box_rounded,
          label: 'Tube',
          count: 0,
          badgeText:
              '${GameProvider.maxExtraTubesPerLevel - game.extraTubesThisLevel}',
          priceText: game.canAddMoreTubes ? '${game.extraTubePrice}' : 'MAX',
          color: AppTheme.success,
          size: r.sp(56),
          onTap: playing ? () => _buyTube(context, game) : null,
        ),
      ],
    );
  }

  void _showPause(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Consumer<GameProvider>(
          builder: (ctx, game, _) {
            Widget tile(IconData i, String t, bool v, ValueChanged<bool> cb) {
              return SwitchListTile(
                secondary: Icon(i, color: AppTheme.accent),
                title: Text(t, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                value: v,
                onChanged: cb,
              );
            }

            return Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text('PAUSED',
                        style: GoogleFonts.poppins(
                            fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 3)),
                    const SizedBox(height: 6),
                    tile(Icons.volume_up_rounded, 'Sound Effects', game.soundEnabled,
                        game.setSound),
                    tile(Icons.music_note_rounded, 'Music', game.musicEnabled,
                        game.setMusic),
                    tile(Icons.vibration_rounded, 'Vibration', game.hapticsEnabled,
                        game.setHaptics),
                    const SizedBox(height: 10),
                    JellyButton(
                      label: 'RESUME',
                      icon: Icons.play_arrow_rounded,
                      width: double.infinity,
                      height: 52,
                      onTap: () => Navigator.pop(ctx),
                    ),
                    const SizedBox(height: 12),
                    JellyButton(
                      label: 'LEVEL MAP',
                      icon: Icons.map_rounded,
                      width: double.infinity,
                      height: 48,
                      fontSize: 14,
                      colors: const [Color(0xFF8A94B8), Color(0xFF5B6585)],
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------
class _WinOverlay extends StatefulWidget {
  final GameProvider game;
  final WorldTheme theme;
  const _WinOverlay({required this.game, required this.theme});

  @override
  State<_WinOverlay> createState() => _WinOverlayState();
}

class _WinOverlayState extends State<_WinOverlay> {
  @override
  void initState() {
    super.initState();
    final n = widget.game.starsEarned;
    for (int i = 0; i < n; i++) {
      Future.delayed(Duration(milliseconds: 450 + i * 300), () {
        if (!mounted) return;
        widget.game.sound.playStar();
        Haptics.light();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final theme = widget.theme;
    return Container(
      color: Colors.black.withOpacity(0.65),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 28),
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.lerp(theme.primary, Colors.white, 0.1)!.withOpacity(0.95),
                AppTheme.card,
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.35), width: 1.5),
            boxShadow: [
              BoxShadow(color: theme.primary.withOpacity(0.6), blurRadius: 40),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                shaderCallback: (b) => AppTheme.goldGradient.createShader(b),
                child: Text(
                  'LEVEL COMPLETE!',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(3, (i) {
                  final earned = i < game.starsEarned;
                  final size = i == 1 ? 74.0 : 56.0;
                  final star = Icon(
                    earned ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: size,
                    color: earned ? AppTheme.gold : Colors.white.withOpacity(0.25),
                  );
                  if (!earned) return star;
                  return star
                      .animate(delay: (450 + i * 300).ms)
                      .scale(
                        begin: const Offset(0, 0),
                        end: const Offset(1, 1),
                        duration: 500.ms,
                        curve: Curves.elasticOut,
                      )
                      .rotate(begin: -0.25, end: 0, duration: 500.ms);
                }),
              ),
              const SizedBox(height: 8),
              Text(
                '${game.moves} moves  •  par ${game.currentLevel.stars3Moves - 2}',
                style: GoogleFonts.poppins(
                    fontSize: 15, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.monetization_on_rounded,
                      color: AppTheme.gold, size: 26),
                  const SizedBox(width: 6),
                  Text(
                    '+${game.lastCoinsEarned}',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.gold,
                    ),
                  ),
                ],
              )
                  .animate(delay: 1000.ms)
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.4, end: 0)
                  .then()
                  .shimmer(duration: 900.ms),
              if (game.hasWeeklyBadge)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('🥇 Top Player badge active',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppTheme.gold)),
                ),
              const SizedBox(height: 20),
              if (game.hasNextLevel)
                JellyButton(
                  label: 'NEXT LEVEL',
                  icon: Icons.arrow_forward_rounded,
                  width: double.infinity,
                  height: 56,
                  colors: const [Color(0xFF34F5B0), Color(0xFF00C27A)],
                  onTap: () => game.loadLevel(game.nextLevelId),
                )
              else
                Text('🎉 You finished all levels!',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: JellyButton(
                      label: 'REPLAY',
                      icon: Icons.refresh_rounded,
                      height: 46,
                      fontSize: 13,
                      colors: const [Color(0xFFFFC857), Color(0xFFF59E0B)],
                      onTap: game.resetLevel,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: JellyButton(
                      label: 'MAP',
                      icon: Icons.map_rounded,
                      height: 46,
                      fontSize: 13,
                      colors: const [Color(0xFF8A94B8), Color(0xFF5B6585)],
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 250.ms).scale(
            begin: const Offset(0.85, 0.85),
            curve: Curves.easeOutBack,
            duration: 400.ms,
          ),
    );
  }
}

class _LoseOverlay extends StatelessWidget {
  final GameProvider game;
  final WorldTheme theme;
  const _LoseOverlay({required this.game, required this.theme});

  @override
  Widget build(BuildContext context) {
    final byMoves = game.loseReason == 'moves';
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 28),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppTheme.secondary.withOpacity(0.6)),
            boxShadow: [
              BoxShadow(color: AppTheme.secondary.withOpacity(0.35), blurRadius: 30),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(byMoves ? '⏱️' : '🧊', style: const TextStyle(fontSize: 52)),
              const SizedBox(height: 8),
              Text(
                byMoves ? 'OUT OF MOVES' : 'NO MOVES LEFT',
                style: GoogleFonts.poppins(
                    fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
              const SizedBox(height: 6),
              Text(
                byMoves
                    ? 'Try fewer, smarter pours!'
                    : 'Every tube is blocked. Try again!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 13, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 20),
              JellyButton(
                label: 'TRY AGAIN',
                icon: Icons.refresh_rounded,
                width: double.infinity,
                height: 54,
                colors: const [Color(0xFFFF8A80), Color(0xFFE53935)],
                onTap: game.resetLevel,
              ),
              const SizedBox(height: 12),
              JellyButton(
                label: 'LEVEL MAP',
                icon: Icons.map_rounded,
                width: double.infinity,
                height: 46,
                fontSize: 13,
                colors: const [Color(0xFF8A94B8), Color(0xFF5B6585)],
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 250.ms).shake(hz: 3, duration: 400.ms),
    );
  }
}
