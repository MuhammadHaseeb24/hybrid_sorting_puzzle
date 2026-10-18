import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';
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
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
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
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    return Consumer<GameProvider>(
      builder: (context, game, _) {
        if (game.status == GameStatus.won) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _confettiController.play();
          });
        }

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
            child: Stack(
              children: [
                SafeArea(
                  child: Column(
                    children: [
                      _buildTopBar(context, game),
                      SizedBox(height: isSmall ? 4 : 8),
                      _buildInfoBar(game, isSmall),
                      const Spacer(),
                      _buildTubesBoard(game, size),
                      const Spacer(),
                      _buildBoosters(game),
                      SizedBox(height: isSmall ? 8 : 12),
                      _buildBottomActions(context, game),
                      SizedBox(height: isSmall ? 12 : 16),
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
                    numberOfParticles: 40,
                    gravity: 0.2,
                  ),
                ),
                if (game.status == GameStatus.won)
                  _buildWinOverlay(context, game),
                if (game.status == GameStatus.lost)
                  _buildLoseOverlay(context, game),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, GameProvider game) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: AppTheme.textPrimary,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Level ${game.currentLevel.id}',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  game.currentLevel.name,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => game.resetLevel(),
            icon: const Icon(Icons.refresh_rounded),
            color: AppTheme.textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBar(GameProvider game, bool isSmall) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmall ? 16 : 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _infoChip(
            icon: Icons.swap_horiz_rounded,
            label: 'Moves',
            value: '${game.moves}/${game.currentLevel.maxMoves}',
          ),
          _infoChip(
            icon: Icons.star_rounded,
            label: '3★ Target',
            value: '≤${game.currentLevel.stars3Moves}',
            color: AppTheme.warning,
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight.withOpacity(0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTubesBoard(GameProvider game, Size size) {
    final tubes = game.tubes;
    final tubeCount = tubes.length;
    final maxPerRow = size.width > 400 ? 6 : 5;
    final availableWidth = size.width - 32;
    final tubeWidth =
        (availableWidth / tubeCount.clamp(1, maxPerRow)).clamp(40.0, 62.0);
    final tubeHeight = tubeWidth * 3.1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 16,
        children: List.generate(tubes.length, (index) {
          return TubeWidget(
            tube: tubes[index],
            isSelected: game.selectedTubeIndex == index,
            onTap: () => game.selectTube(index),
            width: tubeWidth,
            height: tubeHeight,
          )
              .animate(delay: (30 * index).ms)
              .fadeIn(duration: 250.ms)
              .slideY(begin: 0.12, end: 0);
        }),
      ),
    );
  }

  Widget _buildBoosters(GameProvider game) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
    );
  }

  Widget _buildBottomActions(BuildContext context, GameProvider game) {
    return TextButton.icon(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LevelSelectScreen()),
        );
      },
      icon: const Icon(Icons.grid_view_rounded, size: 18),
      label: Text(
        'Levels',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      ),
      style: TextButton.styleFrom(foregroundColor: AppTheme.textSecondary),
    );
  }

  Widget _buildWinOverlay(BuildContext context, GameProvider game) {
    return Container(
      color: Colors.black.withOpacity(0.78),
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(28),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.surfaceLight, AppTheme.card],
              ),
              borderRadius: BorderRadius.circular(28),
              border:
                  Border.all(color: AppTheme.accent.withOpacity(0.4), width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accent.withOpacity(0.25),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events_rounded,
                        size: 60, color: AppTheme.warning)
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.elasticOut),
                const SizedBox(height: 12),
                Text(
                  'Level Complete!',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Moves: ${game.moves}',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    return Icon(
                      Icons.star_rounded,
                      size: 40,
                      color: i < game.starsEarned
                          ? AppTheme.warning
                          : AppTheme.textSecondary.withOpacity(0.25),
                    )
                        .animate(delay: (180 * i).ms)
                        .scale(
                          begin: const Offset(0, 0),
                          duration: 400.ms,
                          curve: Curves.elasticOut,
                        );
                  }),
                ),
                if (game.hasWeeklyBadge) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: AppTheme.goldGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '🥇 Top Player Badge Active',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _overlayButton(
                      label: 'Replay',
                      icon: Icons.refresh_rounded,
                      onTap: () => game.resetLevel(),
                      outlined: true,
                    ),
                    const SizedBox(width: 12),
                    if (game.hasNextLevel)
                      _overlayButton(
                        label: 'Next',
                        icon: Icons.arrow_forward_rounded,
                        onTap: () => game.loadLevel(game.nextLevelId),
                      )
                    else
                      _overlayButton(
                        label: 'Levels',
                        icon: Icons.grid_view_rounded,
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LevelSelectScreen(),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms).scale(
                begin: const Offset(0.85, 0.85),
                curve: Curves.easeOutBack,
              ),
        ),
      ),
    );
  }

  Widget _buildLoseOverlay(BuildContext context, GameProvider game) {
    return Container(
      color: Colors.black.withOpacity(0.78),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(28),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
                color: AppTheme.secondary.withOpacity(0.4), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.sentiment_dissatisfied_rounded,
                  size: 60, color: AppTheme.secondary),
              const SizedBox(height: 12),
              Text(
                'Out of Moves!',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Try again with better strategy',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              _overlayButton(
                label: 'Try Again',
                icon: Icons.refresh_rounded,
                onTap: () => game.resetLevel(),
              ),
            ],
          ),
        ).animate().fadeIn().scale(begin: const Offset(0.85, 0.85)),
      ),
    );
  }

  Widget _overlayButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool outlined = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          gradient: outlined ? null : AppTheme.buttonGradient,
          color: outlined ? Colors.transparent : null,
          borderRadius: BorderRadius.circular(16),
          border: outlined
              ? Border.all(color: AppTheme.primary.withOpacity(0.5), width: 1.5)
              : null,
          boxShadow: outlined
              ? null
              : [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 15,
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
