import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/tube_widget.dart';
import '../widgets/booster_button.dart';
import '../widgets/ad_dialog.dart';
import 'level_select_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _showAdDialog({
    required String title,
    required String reward,
    required VoidCallback onComplete,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AdDialog(
        title: title,
        rewardText: reward,
        onComplete: onComplete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = R(context);

    return Consumer<GameProvider>(
      builder: (context, game, _) {
        if (game.status == GameStatus.won) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _confettiController.play();
          });
        }

        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
            child: Stack(
              children: [
                SafeArea(
                  child: Column(
                    children: [
                      _buildTopBar(context, game, r),
                      SizedBox(height: r.sp(4)),
                      _buildInfoBar(game, r),
                      Expanded(child: Center(child: _buildTubesBoard(game, r))),
                      _buildBoosters(game, r),
                      SizedBox(height: r.sp(6)),
                      _buildBottomActions(context, game, r),
                      SizedBox(height: r.sp(10)),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: false,
                    colors: const [
                      AppTheme.primary,
                      AppTheme.secondary,
                      AppTheme.accent,
                      AppTheme.warning,
                      Colors.white,
                    ],
                    numberOfParticles: 35,
                    gravity: 0.2,
                  ),
                ),
                if (game.status == GameStatus.won) _buildWinOverlay(context, game, r),
                if (game.status == GameStatus.lost) _buildLoseOverlay(context, game, r),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, GameProvider game, R r) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r.sp(4), vertical: r.sp(2)),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new_rounded, size: r.sp(20)),
            color: AppTheme.textPrimary,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Level ${game.currentLevel.id}',
                  style: GoogleFonts.poppins(
                    fontSize: r.sp(17),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  game.currentLevel.name,
                  style: GoogleFonts.poppins(
                    fontSize: r.sp(11),
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => game.resetLevel(),
            icon: Icon(Icons.refresh_rounded, size: r.sp(22)),
            color: AppTheme.textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBar(GameProvider game, R r) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r.sp(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flexible(
            child: _infoChip(
              icon: Icons.swap_horiz_rounded,
              label: 'Moves',
              value: '${game.moves}/${game.currentLevel.maxMoves}',
              r: r,
            ),
          ),
          SizedBox(width: r.sp(10)),
          Flexible(
            child: _infoChip(
              icon: Icons.star_rounded,
              label: '3★ Target',
              value: '≤${game.currentLevel.stars3Moves}',
              color: AppTheme.warning,
              r: r,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String label,
    required String value,
    Color color = AppTheme.primary,
    required R r,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.sp(12), vertical: r.sp(7)),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: r.sp(16), color: color),
          SizedBox(width: r.sp(6)),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: r.sp(9.5),
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: r.sp(13),
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTubesBoard(GameProvider game, R r) {
    final tubes = game.tubes;
    final tubeCount = tubes.length;

    // Calculate best tube size based on available width and count
    final availableWidth = r.width - r.sp(28);
    final maxPerRow = r.isTablet ? 8 : (r.width > 400 ? 6 : 5);
    final itemsInRow = tubeCount.clamp(1, maxPerRow);
    final tubeWidth = (availableWidth / itemsInRow).clamp(r.tubeMinWidth, r.tubeMaxWidth);
    final tubeHeight = tubeWidth * 3.05;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: r.sp(10), vertical: r.sp(8)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: r.width),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: r.sp(7),
          runSpacing: r.sp(14),
          children: List.generate(tubes.length, (index) {
            return TubeWidget(
              tube: tubes[index],
              isSelected: game.selectedTubeIndex == index,
              onTap: () => game.selectTube(index),
              width: tubeWidth,
              height: tubeHeight,
            )
                .animate(delay: (25 * index).ms)
                .fadeIn(duration: 220.ms)
                .slideY(begin: 0.1, end: 0);
          }),
        ),
      ),
    );
  }

  Widget _buildBoosters(GameProvider game, R r) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r.sp(10)),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BoosterButton(
              icon: Icons.undo_rounded,
              label: 'Undo',
              count: game.undoCount,
              onTap: () {
                if (game.undoCount > 0) {
                  game.undo();
                } else {
                  _showAdDialog(
                    title: 'Get More Undos',
                    reward: 'Watch a short ad to get +3 Undos',
                    onComplete: () => game.addUndoFromAd(),
                  );
                }
              },
              color: AppTheme.primary,
            ),
            SizedBox(width: r.sp(10)),
            BoosterButton(
              icon: Icons.lightbulb_outline_rounded,
              label: 'Hint',
              count: game.hintCount,
              onTap: () async {
                if (game.hintCount > 0) {
                  await game.useHint();
                } else {
                  _showAdDialog(
                    title: 'Get More Hints',
                    reward: 'Watch a short ad to get +3 Hints',
                    onComplete: () => game.addHintFromAd(),
                  );
                }
              },
              color: AppTheme.warning,
            ),
            SizedBox(width: r.sp(10)),
            BoosterButton(
              icon: Icons.add_box_outlined,
              label: 'Extra',
              count: game.extraTubeCount,
              onTap: () {
                if (game.extraTubeCount > 0) {
                  game.addExtraTube();
                } else {
                  _showAdDialog(
                    title: 'Get Extra Tubes',
                    reward: 'Watch a short ad to get +2 Extra Tubes',
                    onComplete: () => game.addExtraTubeFromAd(),
                  );
                }
              },
              color: AppTheme.accent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, GameProvider game, R r) {
    return TextButton.icon(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LevelSelectScreen()),
        );
      },
      icon: Icon(Icons.grid_view_rounded, size: r.sp(17)),
      label: Text(
        'Levels',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: r.sp(13)),
      ),
      style: TextButton.styleFrom(foregroundColor: AppTheme.textSecondary),
    );
  }

  Widget _buildWinOverlay(BuildContext context, GameProvider game, R r) {
    return Container(
      color: Colors.black.withOpacity(0.78),
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(r.sp(20)),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(maxWidth: r.isTablet ? 420 : 340),
            padding: EdgeInsets.all(r.sp(22)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.surfaceLight, AppTheme.card],
              ),
              borderRadius: BorderRadius.circular(r.sp(24)),
              border: Border.all(color: AppTheme.accent.withOpacity(0.4), width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accent.withOpacity(0.25),
                  blurRadius: 24,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.emoji_events_rounded, size: r.sp(54), color: AppTheme.warning)
                    .animate()
                    .scale(duration: 550.ms, curve: Curves.elasticOut),
                SizedBox(height: r.sp(10)),
                Text(
                  'Level Complete!',
                  style: GoogleFonts.poppins(
                    fontSize: r.sp(22),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: r.sp(4)),
                Text(
                  'Moves: ${game.moves}',
                  style: GoogleFonts.poppins(
                    fontSize: r.sp(14),
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: r.sp(12)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    return Icon(
                      Icons.star_rounded,
                      size: r.sp(36),
                      color: i < game.starsEarned
                          ? AppTheme.warning
                          : AppTheme.textSecondary.withOpacity(0.25),
                    )
                        .animate(delay: (160 * i).ms)
                        .scale(begin: const Offset(0, 0), duration: 380.ms, curve: Curves.elasticOut);
                  }),
                ),
                if (game.hasWeeklyBadge) ...[
                  SizedBox(height: r.sp(10)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: r.sp(10), vertical: r.sp(5)),
                    decoration: BoxDecoration(
                      gradient: AppTheme.goldGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '🥇 Top Player Badge Active',
                      style: GoogleFonts.poppins(
                        fontSize: r.sp(11),
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
                SizedBox(height: r.sp(20)),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _overlayButton(
                      label: 'Replay',
                      icon: Icons.refresh_rounded,
                      onTap: () => game.resetLevel(),
                      outlined: true,
                      r: r,
                    ),
                    if (game.hasNextLevel)
                      _overlayButton(
                        label: 'Next',
                        icon: Icons.arrow_forward_rounded,
                        onTap: () => game.loadLevel(game.nextLevelId),
                        r: r,
                      )
                    else
                      _overlayButton(
                        label: 'Levels',
                        icon: Icons.grid_view_rounded,
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LevelSelectScreen()),
                          );
                        },
                        r: r,
                      ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(duration: 280.ms).scale(
                begin: const Offset(0.88, 0.88),
                curve: Curves.easeOutBack,
              ),
        ),
      ),
    );
  }

  Widget _buildLoseOverlay(BuildContext context, GameProvider game, R r) {
    return Container(
      color: Colors.black.withOpacity(0.78),
      child: Center(
        child: Container(
          margin: EdgeInsets.all(r.sp(24)),
          width: double.infinity,
          constraints: BoxConstraints(maxWidth: r.isTablet ? 400 : 320),
          padding: EdgeInsets.all(r.sp(22)),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(r.sp(24)),
            border: Border.all(color: AppTheme.secondary.withOpacity(0.4), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.sentiment_dissatisfied_rounded, size: r.sp(54), color: AppTheme.secondary),
              SizedBox(height: r.sp(10)),
              Text(
                'Out of Moves!',
                style: GoogleFonts.poppins(
                  fontSize: r.sp(20),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: r.sp(5)),
              Text(
                'Try again with better strategy',
                style: GoogleFonts.poppins(
                  fontSize: r.sp(13),
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: r.sp(20)),
              _overlayButton(
                label: 'Try Again',
                icon: Icons.refresh_rounded,
                onTap: () => game.resetLevel(),
                r: r,
              ),
            ],
          ),
        ).animate().fadeIn().scale(begin: const Offset(0.88, 0.88)),
      ),
    );
  }

  Widget _overlayButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required R r,
    bool outlined = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: r.sp(20), vertical: r.sp(11)),
        decoration: BoxDecoration(
          gradient: outlined ? null : AppTheme.buttonGradient,
          color: outlined ? Colors.transparent : null,
          borderRadius: BorderRadius.circular(14),
          border: outlined
              ? Border.all(color: AppTheme.primary.withOpacity(0.5), width: 1.5)
              : null,
          boxShadow: outlined
              ? null
              : [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: r.sp(18)),
            SizedBox(width: r.sp(6)),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: r.sp(14),
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
