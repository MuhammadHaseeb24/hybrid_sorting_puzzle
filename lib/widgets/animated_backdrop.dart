import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/world_theme.dart';

/// Animated themed background: gradient + floating glowing orbs + vignette.
class AnimatedBackdrop extends StatefulWidget {
  final WorldTheme? theme;
  final Widget? child;

  const AnimatedBackdrop({super.key, this.theme, this.child});

  @override
  State<AnimatedBackdrop> createState() => _AnimatedBackdropState();
}

class _AnimatedBackdropState extends State<AnimatedBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 40),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme ?? WorldTheme.worlds[0];
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 700),
          child: DecoratedBox(
            key: ValueKey(t.index),
            decoration: BoxDecoration(gradient: t.gradient),
            child: const SizedBox.expand(),
          ),
        ),
        RepaintBoundary(
          child: CustomPaint(
            painter: _OrbPainter(_c, t.orb),
            size: Size.infinite,
          ),
        ),
        IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                radius: 1.15,
                colors: [Colors.transparent, Colors.black.withOpacity(0.45)],
              ),
            ),
            child: const SizedBox.expand(),
          ),
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _Orb {
  final double x, y, r, phase;
  final int loops, sway;
  const _Orb(this.x, this.y, this.r, this.phase, this.loops, this.sway);
}

class _OrbPainter extends CustomPainter {
  final Animation<double> anim;
  final Color color;

  static final List<_Orb> _orbs = List.generate(18, (i) {
    final r = math.Random(i * 37 + 5);
    return _Orb(
      r.nextDouble(),
      r.nextDouble(),
      8 + r.nextDouble() * 42,
      r.nextDouble() * math.pi * 2,
      1 + (i % 3),
      1 + (i % 2),
    );
  });

  _OrbPainter(this.anim, this.color) : super(repaint: anim);

  @override
  void paint(Canvas canvas, Size size) {
    final t = anim.value;
    for (final o in _orbs) {
      final y = ((o.y - t * o.loops) % 1.0);
      final x = o.x + 0.03 * math.sin(t * math.pi * 2 * o.sway + o.phase);
      final c = Offset(x * size.width, y * size.height);
      final rect = Rect.fromCircle(center: c, radius: o.r);
      canvas.drawCircle(
        c,
        o.r,
        Paint()
          ..shader = RadialGradient(
            colors: [color.withOpacity(0.30), color.withOpacity(0.0)],
          ).createShader(rect),
      );
      if (o.r > 24) {
        canvas.drawCircle(
          c,
          o.r * 0.55,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = Colors.white.withOpacity(0.06),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _OrbPainter old) => old.color != color;
}
