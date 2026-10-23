import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// One layer of liquid. [amount] is measured in tube "slots" (can be fractional
/// while liquid is flowing).
class LiquidBand {
  final Color color;
  final double amount;
  const LiquidBand(this.color, this.amount);

  @override
  bool operator ==(Object other) =>
      other is LiquidBand && other.color == color && other.amount == amount;

  @override
  int get hashCode => Object.hash(color, amount);
}

/// Shared geometry of the glass tube so the board and painter agree.
class TubeGeo {
  final double w;
  final double h;
  const TubeGeo(this.w, this.h);

  double get rim => w * 0.2;
  double get inset => w * 0.09;

  Rect get interior => Rect.fromLTRB(inset, rim * 0.5, w - inset, h - inset);

  Path get body => Path()
    ..addRRect(RRect.fromRectAndCorners(
      Rect.fromLTRB(0, rim * 0.5, w, h),
      bottomLeft: Radius.circular(w / 2),
      bottomRight: Radius.circular(w / 2),
    ));

  Path get interiorPath => Path()
    ..addRRect(RRect.fromRectAndCorners(
      interior,
      bottomLeft: Radius.circular(interior.width / 2),
      bottomRight: Radius.circular(interior.width / 2),
    ));

  Rect get mouthRect => Rect.fromLTWH(0, 0, w, rim);
  Rect get mouthInner =>
      Rect.fromLTRB(inset, rim * 0.1, w - inset, rim * 0.9);

  Path get liquidClip => Path.combine(
        PathOperation.union,
        interiorPath,
        Path()..addOval(mouthInner),
      );
}

Color _lighten(Color c, double a) {
  final h = HSLColor.fromColor(c);
  return h.withLightness((h.lightness + a).clamp(0.0, 1.0)).toColor();
}

Color _darken(Color c, double a) => _lighten(c, -a);

List<Offset> _clip(List<Offset> poly, Offset n, double k) {
  final out = <Offset>[];
  for (int i = 0; i < poly.length; i++) {
    final a = poly[i];
    final b = poly[(i + 1) % poly.length];
    final da = a.dx * n.dx + a.dy * n.dy - k;
    final db = b.dx * n.dx + b.dy * n.dy - k;
    final ina = da >= 0;
    final inb = db >= 0;
    if (ina) out.add(a);
    if (ina != inb) {
      final t = da / (da - db);
      out.add(Offset(a.dx + (b.dx - a.dx) * t, a.dy + (b.dy - a.dy) * t));
    }
  }
  return out;
}

double _area(List<Offset> p) {
  if (p.length < 3) return 0;
  double s = 0;
  for (int i = 0; i < p.length; i++) {
    final a = p[i];
    final b = p[(i + 1) % p.length];
    s += a.dx * b.dy - b.dx * a.dy;
  }
  return s.abs() / 2;
}

class GlassTubePainter extends CustomPainter {
  final List<LiquidBand> bands;
  final int capacity;
  final double tilt; // radians, + = clockwise
  final double slosh; // extra surface wobble in radians
  final Color? glowColor;
  final double glowAmount;
  final bool completed;
  final Animation<double>? pulse;

  GlassTubePainter({
    required this.bands,
    required this.capacity,
    this.tilt = 0,
    this.slosh = 0,
    this.glowColor,
    this.glowAmount = 0,
    this.completed = false,
    this.pulse,
  }) : super(repaint: pulse);

  @override
  void paint(Canvas canvas, Size size) {
    final g = TubeGeo(size.width, size.height);
    final w = g.w;
    final h = g.h;
    final full = Rect.fromLTWH(0, 0, w, h);
    final body = g.body;

    // Glow (selected / hint / completed)
    if (glowColor != null && glowAmount > 0) {
      final amt = glowAmount * (pulse != null ? 0.4 + 0.6 * pulse!.value : 1.0);
      canvas.drawPath(
        body,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..color = glowColor!.withOpacity(0.55 * amt)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
      );
    }

    // Glass body + dark inner back wall
    canvas.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(colors: [
          Colors.white.withOpacity(0.11),
          Colors.white.withOpacity(0.03),
          Colors.white.withOpacity(0.08),
        ]).createShader(full),
    );
    canvas.drawPath(
        g.interiorPath, Paint()..color = Colors.black.withOpacity(0.2));
    canvas.drawOval(g.mouthInner, Paint()..color = Colors.black.withOpacity(0.22));

    _paintLiquid(canvas, g);

    // Glass outline
    canvas.drawPath(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..shader = LinearGradient(colors: [
          Colors.white.withOpacity(0.6),
          Colors.white.withOpacity(0.18),
          Colors.white.withOpacity(0.4),
        ]).createShader(full),
    );

    // Reflections
    final leftStreak = RRect.fromRectAndRadius(
      Rect.fromLTWH(g.inset + w * 0.05, g.rim + h * 0.04, w * 0.08, h * 0.62),
      Radius.circular(w * 0.04),
    );
    canvas.drawRRect(
      leftStreak,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withOpacity(0.55), Colors.white.withOpacity(0.0)],
        ).createShader(leftStreak.outerRect),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w - g.inset - w * 0.14, g.rim + h * 0.2, w * 0.035, h * 0.3),
        Radius.circular(w * 0.02),
      ),
      Paint()..color = Colors.white.withOpacity(0.2),
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.22, h - g.inset - w * 0.2, w * 0.56, w * 0.1),
      Paint()..color = Colors.white.withOpacity(0.12),
    );

    // Front rim
    canvas.drawOval(
      g.mouthRect.deflate(0.8),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.7
        ..color = Colors.white.withOpacity(0.65),
    );

    // Lid for completed tubes
    if (completed) {
      final lid = Rect.fromCenter(
        center: Offset(w / 2, g.rim * 0.5),
        width: w * 1.04,
        height: g.rim * 1.1,
      );
      canvas.drawOval(
        lid,
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFFFF3B0), Color(0xFFFFC107), Color(0xFFB8860B)],
          ).createShader(lid),
      );
      canvas.drawOval(
        lid.deflate(1),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = Colors.white.withOpacity(0.7),
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * 0.4, g.rim * 0.38),
          width: w * 0.3,
          height: g.rim * 0.28,
        ),
        Paint()..color = Colors.white.withOpacity(0.55),
      );
    }
  }

  void _paintLiquid(Canvas canvas, TubeGeo g) {
    // merge neighbouring bands of equal colour
    final merged = <LiquidBand>[];
    for (final b in bands) {
      if (b.amount <= 0.0001) continue;
      if (merged.isNotEmpty && merged.last.color == b.color) {
        merged[merged.length - 1] =
            LiquidBand(b.color, merged.last.amount + b.amount);
      } else {
        merged.add(b);
      }
    }
    if (merged.isEmpty) return;

    final phi = tilt + slosh;
    final n = Offset(math.sin(phi), math.cos(phi));
    final rect = g.interior;
    final poly = <Offset>[rect.topLeft, rect.topRight, rect.bottomRight, rect.bottomLeft];
    double dot(Offset p) => p.dx * n.dx + p.dy * n.dy;
    double dmin = double.infinity, dmax = -double.infinity;
    for (final p in poly) {
      final d = dot(p);
      dmin = math.min(dmin, d);
      dmax = math.max(dmax, d);
    }
    final totalArea = rect.width * rect.height;
    final upright = phi.abs() < 1e-4;

    double kFor(double frac) {
      if (frac <= 0) return dmax + 1;
      if (frac >= 1) return dmin - 1;
      if (upright) return rect.bottom - frac * rect.height;
      double lo = dmin, hi = dmax;
      for (int i = 0; i < 22; i++) {
        final mid = (lo + hi) / 2;
        if (_area(_clip(poly, n, mid)) > frac * totalArea) {
          lo = mid;
        } else {
          hi = mid;
        }
      }
      return (lo + hi) / 2;
    }

    final cap = capacity > 0 ? capacity : 1;
    final ks = <double>[kFor(0)];
    double cum = 0;
    for (final b in merged) {
      cum += b.amount;
      ks.add(kFor(math.min(1.0, cum / cap)));
    }

    canvas.save();
    canvas.clipPath(g.liquidClip);
    final layerBounds = Rect.fromLTWH(-4, -4, g.w + 8, g.h + 8);
    canvas.saveLayer(layerBounds, Paint());

    for (int i = 0; i < merged.length; i++) {
      final kTop = ks[i + 1];
      final kBottom = ks[i];
      var pg = _clip(poly, n, kTop);
      if (i > 0) pg = _clip(pg, Offset(-n.dx, -n.dy), -kBottom);
      if (pg.length < 3) continue;

      final color = merged[i].color;
      final paint = Paint();
      final kt = kTop.clamp(dmin, dmax);
      final kb = kBottom.clamp(dmin, dmax);
      if ((kb - kt).abs() > 0.5) {
        paint.shader = ui.Gradient.linear(
          Offset(n.dx * kt, n.dy * kt),
          Offset(n.dx * kb, n.dy * kb),
          [_lighten(color, 0.1), color, _darken(color, 0.12)],
          [0.0, 0.45, 1.0],
        );
      } else {
        paint.color = color;
      }
      final path = Path()..addPolygon(pg, true);
      canvas.drawPath(path, paint);

      // Surface / interface ellipse (gives the 3D disc look)
      final kc = kTop.clamp(dmin + 0.01, dmax - 0.01);
      final chord = _chord(poly, n, kc);
      if (chord != null) {
        final mid = (chord.$1 + chord.$2) / 2;
        final len = (chord.$2 - chord.$1).distance;
        final ang = math.atan2(
            chord.$2.dy - chord.$1.dy, chord.$2.dx - chord.$1.dx);
        final isTop = i == merged.length - 1;
        canvas.save();
        canvas.translate(mid.dx, mid.dy);
        canvas.rotate(ang);
        final oval = Rect.fromCenter(
            center: Offset.zero, width: len, height: math.max(2.0, len * 0.22));
        canvas.drawOval(
          oval,
          isTop ? (Paint()..color = _lighten(color, 0.16)) : paint,
        );
        if (isTop) {
          canvas.drawOval(
            oval.deflate(len * 0.05),
            Paint()..color = Colors.white.withOpacity(0.16),
          );
          canvas.drawOval(
            oval,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1
              ..color = Colors.white.withOpacity(0.35),
          );
        }
        canvas.restore();
      }
    }

    // cylinder shading on everything that has liquid
    canvas.drawRect(
      layerBounds,
      Paint()
        ..blendMode = BlendMode.srcATop
        ..shader = LinearGradient(
          colors: [
            Colors.black.withOpacity(0.3),
            Colors.white.withOpacity(0.16),
            Colors.transparent,
            Colors.black.withOpacity(0.36),
          ],
          stops: const [0.0, 0.22, 0.55, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, g.w, g.h)),
    );
    canvas.restore();
    canvas.restore();
  }

  (Offset, Offset)? _chord(List<Offset> poly, Offset n, double k) {
    final pts = <Offset>[];
    for (int i = 0; i < poly.length; i++) {
      final a = poly[i];
      final b = poly[(i + 1) % poly.length];
      final da = a.dx * n.dx + a.dy * n.dy - k;
      final db = b.dx * n.dx + b.dy * n.dy - k;
      if ((da >= 0) != (db >= 0)) {
        final t = da / (da - db);
        pts.add(Offset(a.dx + (b.dx - a.dx) * t, a.dy + (b.dy - a.dy) * t));
      }
    }
    if (pts.length < 2) return null;
    return (pts[0], pts[1]);
  }

  @override
  bool shouldRepaint(covariant GlassTubePainter old) =>
      old.tilt != tilt ||
      old.slosh != slosh ||
      old.capacity != capacity ||
      old.glowColor != glowColor ||
      old.glowAmount != glowAmount ||
      old.completed != completed ||
      old.bands.length != bands.length ||
      !_sameBands(old.bands);

  bool _sameBands(List<LiquidBand> o) {
    for (int i = 0; i < bands.length; i++) {
      if (o[i] != bands[i]) return false;
    }
    return true;
  }
}

/// Glass tube widget (3D look). Used on the game board, home logo, etc.
class TubeWidget extends StatelessWidget {
  final List<LiquidBand> bands;
  final int capacity;
  final double width;
  final double height;
  final double tilt;
  final double slosh;
  final Color? glowColor;
  final double glowAmount;
  final bool completed;
  final Animation<double>? pulse;
  final VoidCallback? onTap;

  const TubeWidget({
    super.key,
    required this.bands,
    required this.capacity,
    required this.width,
    required this.height,
    this.tilt = 0,
    this.slosh = 0,
    this.glowColor,
    this.glowAmount = 0,
    this.completed = false,
    this.pulse,
    this.onTap,
  });

  static List<LiquidBand> bandsOf(List<Color> colors) =>
      [for (final c in colors) LiquidBand(c, 1)];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size(width, height),
          painter: GlassTubePainter(
            bands: bands,
            capacity: capacity,
            tilt: tilt,
            slosh: slosh,
            glowColor: glowColor,
            glowAmount: glowAmount,
            completed: completed,
            pulse: pulse,
          ),
        ),
      ),
    );
  }
}
