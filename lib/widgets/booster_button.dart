import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/sound_service.dart';
import '../utils/app_theme.dart';
import '../utils/haptics.dart';

/// Round glossy booster button with count / ad badge.
class BoosterButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final int count;
  final VoidCallback? onTap;
  final Color color;
  final bool showAdIcon;
  final double size;

  const BoosterButton({
    super.key,
    required this.icon,
    required this.label,
    required this.count,
    this.onTap,
    this.color = AppTheme.primary,
    this.showAdIcon = false,
    this.size = 58,
  });

  @override
  State<BoosterButton> createState() => _BoosterButtonState();
}

class _BoosterButtonState extends State<BoosterButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final needsAd = widget.count <= 0 || widget.showAdIcon;
    final enabled = widget.onTap != null;
    final c = widget.color;
    final dark = HSLColor.fromColor(c)
        .withLightness(
            (HSLColor.fromColor(c).lightness - 0.2).clamp(0.05, 1.0))
        .toColor();

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _down = true) : null,
      onTapUp: enabled ? (_) => setState(() => _down = false) : null,
      onTapCancel: enabled ? () => setState(() => _down = false) : null,
      onTap: enabled
          ? () {
              SoundService().playClick();
              Haptics.tap();
              widget.onTap!();
            }
          : null,
      child: AnimatedScale(
        scale: _down ? 0.92 : 1,
        duration: const Duration(milliseconds: 90),
        child: Opacity(
          opacity: enabled ? 1 : 0.45,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: const Alignment(-0.35, -0.5),
                        radius: 1.0,
                        colors: [
                          HSLColor.fromColor(c)
                              .withLightness((HSLColor.fromColor(c).lightness + 0.18).clamp(0.0, 0.95))
                              .toColor(),
                          c,
                          dark,
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.35), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                            color: dark, offset: Offset(0, _down ? 1 : 4)),
                        BoxShadow(
                          color: c.withOpacity(0.4),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(widget.icon,
                        color: Colors.white, size: widget.size * 0.46),
                  ),
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      constraints:
                          const BoxConstraints(minWidth: 22, minHeight: 22),
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: needsAd ? AppTheme.warning : Colors.white,
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(color: AppTheme.background, width: 2),
                      ),
                      child: Center(
                        child: needsAd
                            ? const Icon(Icons.play_arrow_rounded,
                                size: 14, color: Colors.black)
                            : Text(
                                '${widget.count}',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                widget.label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
