import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/sound_service.dart';
import '../utils/haptics.dart';

/// Glossy 3D "jelly" button with press animation, click sound and vibration.
class JellyButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final List<Color> colors;
  final double height;
  final double? width;
  final double fontSize;

  const JellyButton({
    super.key,
    required this.label,
    this.icon,
    required this.onTap,
    this.colors = const [Color(0xFF7B6CFF), Color(0xFF5B4CFF)],
    this.height = 56,
    this.width,
    this.fontSize = 17,
  });

  @override
  State<JellyButton> createState() => _JellyButtonState();
}

class _JellyButtonState extends State<JellyButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final base = widget.colors.last;
    final dark = HSLColor.fromColor(base)
        .withLightness(
            (HSLColor.fromColor(base).lightness - 0.18).clamp(0.05, 1.0))
        .toColor();
    final radius = widget.height * 0.38;
    final disabled = widget.onTap == null;

    return GestureDetector(
      onTapDown: disabled ? null : (_) => setState(() => _down = true),
      onTapUp: disabled ? null : (_) => setState(() => _down = false),
      onTapCancel: disabled ? null : () => setState(() => _down = false),
      onTap: disabled
          ? null
          : () {
              SoundService().playClick();
              Haptics.tap();
              widget.onTap!();
            },
      child: AnimatedScale(
        scale: _down ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 90),
        child: Opacity(
          opacity: disabled ? 0.5 : 1,
          child: Container(
            width: widget.width,
            height: widget.height,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: widget.colors,
              ),
              boxShadow: [
                BoxShadow(
                  color: dark,
                  offset: Offset(0, _down ? 2 : 5),
                ),
                BoxShadow(
                  color: base.withOpacity(0.45),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 4,
                  right: 4,
                  top: 3,
                  height: widget.height * 0.42,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(radius - 3),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.38),
                          Colors.white.withOpacity(0.02),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon,
                          color: Colors.white, size: widget.fontSize + 6),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        widget.label,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: widget.fontSize,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.35),
                              offset: const Offset(0, 2),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
