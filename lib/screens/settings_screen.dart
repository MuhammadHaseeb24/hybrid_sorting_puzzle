import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/animated_backdrop.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackdrop(
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
                        'Settings',
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
              Expanded(
                child: Consumer<GameProvider>(
                  builder: (context, game, _) {
                    return ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      children: [
                        _sectionTitle('Audio & Feedback'),
                        _settingsCard([
                          _switchTile(
                            icon: Icons.volume_up_rounded,
                            title: 'Sound Effects',
                            subtitle: 'Pour & UI sounds',
                            value: game.soundEnabled,
                            onChanged: (v) => game.setSound(v),
                          ),
                          _divider(),
                          _switchTile(
                            icon: Icons.music_note_rounded,
                            title: 'Background Music',
                            subtitle: 'Ambient music',
                            value: game.musicEnabled,
                            onChanged: (v) => game.setMusic(v),
                          ),
                          _divider(),
                          _switchTile(
                            icon: Icons.vibration_rounded,
                            title: 'Haptic Feedback',
                            subtitle: 'Vibration on actions',
                            value: game.hapticsEnabled,
                            onChanged: (v) => game.setHaptics(v),
                          ),
                        ]),
                        const SizedBox(height: 20),
                        _sectionTitle('Boosters'),
                        _settingsCard([
                          _infoTile(
                            icon: Icons.lightbulb_outline_rounded,
                            title: 'Hints',
                            value: '×${game.hintCount}',
                            color: AppTheme.warning,
                          ),
                          _divider(),
                          _infoTile(
                            icon: Icons.undo_rounded,
                            title: 'Undos',
                            value: '×${game.undoCount}',
                            color: AppTheme.primary,
                          ),
                          _divider(),
                          _infoTile(
                            icon: Icons.add_box_outlined,
                            title: 'Extra Tubes',
                            value: '×${game.extraTubeCount}',
                            color: AppTheme.accent,
                          ),
                        ]),
                        const SizedBox(height: 20),
                        _sectionTitle('Progress'),
                        _settingsCard([
                          _infoTile(
                            icon: Icons.flag_rounded,
                            title: 'Levels Cleared',
                            value: '${game.unlockedLevel - 1}',
                            color: AppTheme.accent,
                          ),
                          _divider(),
                          _infoTile(
                            icon: Icons.star_rounded,
                            title: 'Total Stars',
                            value: '${game.totalStars}',
                            color: AppTheme.warning,
                          ),
                          _divider(),
                          _infoTile(
                            icon: Icons.sports_esports_rounded,
                            title: 'Games Played',
                            value: '${game.gamesPlayed}',
                            color: AppTheme.primary,
                          ),
                        ]),
                        const SizedBox(height: 20),
                        _sectionTitle('Danger Zone'),
                        _settingsCard([
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.secondary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.delete_forever_rounded,
                                  color: AppTheme.secondary, size: 22),
                            ),
                            title: Text(
                              'Reset Progress',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.secondary,
                              ),
                            ),
                            subtitle: Text(
                              'Clears all levels, stars & achievements',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            onTap: () => _confirmReset(context, game),
                          ),
                        ]),
                        const SizedBox(height: 28),
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'Sortify',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              Text(
                                'v1.0.0 • Hybrid Casual 2026',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _settingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(children: children),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
            fontSize: 12, color: AppTheme.textSecondary),
      ),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      trailing: Text(
        value,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: color,
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: Colors.white.withOpacity(0.06),
    );
  }

  void _confirmReset(BuildContext context, GameProvider game) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Reset All Progress?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'This will permanently delete all your levels, stars, achievements and badges. This cannot be undone.',
          style: GoogleFonts.poppins(
              fontSize: 14, color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              await game.resetAllProgress();
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Progress reset',
                        style: GoogleFonts.poppins()),
                    backgroundColor: AppTheme.surfaceLight,
                  ),
                );
              }
            },
            child: Text(
              'Reset',
              style: GoogleFonts.poppins(
                  color: AppTheme.secondary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
