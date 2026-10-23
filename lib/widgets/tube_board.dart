import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';
import '../utils/haptics.dart';
import '../utils/world_theme.dart';
import 'tube_widget.dart';

class _Layout {
  final double tw;
  final double th;
  final List<Rect> rects;
  const _Layout(this.tw, this.th, this.rects);
}

class _Pose {
  final Offset topLeft;
  final double angle;
  final double poured;
  final double stream;
  final Offset lip;
  final Offset target;
  const _Pose(this.topLeft, this.angle, this.poured, this.stream, this.lip,
      this.target);
}

/// The 3D shelf with all tubes. Handles the tilt-and-pour animation:
/// the source tube lifts, tilts over the destination, liquid streams out
/// into the glass, then the tube returns home.
class TubeBoard extends StatefulWidget {
  final GameProvider game;
  final WorldTheme theme;

  const TubeBoard({super.key, required this.game, required this.theme});

  @override
  State<TubeBoard> createState() => _TubeBoardState();
}

class _TubeBoardState extends State<TubeBoard> with TickerProviderStateMixin {
  late final AnimationController _pour = AnimationController(vsync: this);
  late final AnimationController _slosh = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400));
  late final AnimationController _pulse = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800));
  late final AnimationController _burst = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900));

  PourEvent? _active;
  int _handledPour = -1;
  int _handledBurst = 0;
  int _sloshA = -1;
  int _sloshB = -1;
  int _burstTube = -1;
  Color _burstColor = Colors.white;
  Rect? _burstRect;
  int _lastTick = 0;
  _Layout? _layout;

  static const double _a = 0.26;
  static const double _b = 0.74;

  @override
  void initState() {
    super.initState();
    _handledBurst = widget.game.completedSeq;
    _handledPour = widget.game.pourEvent?.id ?? -1;
    _pour.addStatusListener((s) {
      if (s == AnimationStatus.completed) _onPourDone();
    });
    _pour.addListener(() {
      if (_active == null) return;
      final p = ((_pour.value - _a) / (_b - _a)).clamp(0.0, 1.0);
      final ticks = (p * 5).floor();
      if (ticks > _lastTick && p < 1) {
        _lastTick = ticks;
        Haptics.flow();
      }
    });
  }

  @override
  void didUpdateWidget(covariant TubeBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    final g = widget.game;
    final e = g.pourEvent;
    if (e != null && e.id != _handledPour) {
      _handledPour = e.id;
      _active = e;
      _lastTick = 0;
      _pour.duration = Duration(milliseconds: 900 + 120 * e.amount);
      _pour.forward(from: 0);
    } else if (e == null && _active != null) {
      // level was restarted mid-pour
      _pour.stop();
      _active = null;
    }

    if (g.completedSeq != _handledBurst) {
      _handledBurst = g.completedSeq;
      _burstTube = g.completedTube;
      _burstColor = g.completedColor;
      final l = _layout;
      if (l != null && _burstTube >= 0 && _burstTube < l.rects.length) {
        _burstRect = l.rects[_burstTube];
        _burst.forward(from: 0);
      }
    }

    final hinted = g.hintFrom != -1;
    if (hinted && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!hinted && _pulse.isAnimating) {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  void _onPourDone() {
    final e = _active;
    if (e == null) return;
    _active = null;
    _sloshA = e.from;
    _sloshB = e.to;
    _slosh.forward(from: 0);
    widget.game.finishPour();
  }

  @override
  void dispose() {
    _pour.dispose();
    _slosh.dispose();
    _pulse.dispose();
    _burst.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------------
  _Layout _computeLayout(Size area, int n, int cap) {
    final hr = 2.3 + 0.16 * cap;
    const gapF = 0.34;
    const rowGapF = 0.62;
    final maxTw = area.width >= 600 ? 92.0 : 70.0;
    _Layout? best;
    for (int rows = 1; rows <= math.min(4, n); rows++) {
      final perRow = (n / rows).ceil();
      var tw = (area.width - 24) / (perRow + (perRow - 1) * gapF);
      tw = math.min(tw, maxTw);
      final byH = (area.height - 16) / (rows * hr + (rows - 1) * rowGapF);
      tw = math.min(tw, byH);
      tw = math.max(tw, 20.0);
      if (best != null && tw <= best.tw + 0.5) continue;
      final th = tw * hr;
      final totalH = rows * th + (rows - 1) * tw * rowGapF;
      final top0 = (area.height - totalH) / 2 + tw * 0.08;
      final base = n ~/ rows;
      final extra = n % rows;
      final rects = <Rect>[];
      for (int r = 0; r < rows; r++) {
        final c = base + (r < extra ? 1 : 0);
        final rowW = c * tw + (c - 1) * tw * gapF;
        final x0 = (area.width - rowW) / 2;
        final y = top0 + r * (th + tw * rowGapF);
        for (int k = 0; k < c; k++) {
          rects.add(Rect.fromLTWH(x0 + k * tw * (1 + gapF), y, tw, th));
        }
      }
      best = _Layout(tw, th, rects);
    }
    return best ?? _Layout(40, 120, const []);
  }

  _Pose _pose(PourEvent e, double t, _Layout L, Size area) {
    final tubes = widget.game.tubes;
    final tw = L.tw, th = L.th;
    final geo = TubeGeo(tw, th);
    final src = L.rects[e.from];
    final dst = L.rects[e.to];
    final cap = tubes[e.from].capacity;
    final srcLen = tubes[e.from].colors.length;
    final dstLen = tubes[e.to].colors.length;

    double d;
    if (dst.center.dx > src.center.dx + 1) {
      d = 1;
    } else if (dst.center.dx < src.center.dx - 1) {
      d = -1;
    } else {
      d = dst.center.dx < area.width / 2 ? -1 : 1;
    }

    final f0 = srcLen / cap;
    final f1 = (srcLen - e.amount) / cap;
    final rho = geo.interior.height / geo.interior.width;
    double phiFor(double f) {
      f = f.clamp(0.03, 1.0);
      final tn = f >= 0.5 ? 2 * (1 - f) * rho : rho / (2 * f);
      return math.atan(tn);
    }

    final thetaA = math.max(0.5, phiFor(f0));
    final lipLocal = d > 0 ? geo.interior.topRight : geo.interior.topLeft;
    final c = Offset(tw / 2, th / 2);
    final homeLip = src.topLeft + lipLocal;
    final lipTarget = Offset(dst.center.dx - d * tw * 0.12, dst.top - tw * 0.5);

    double angle;
    Offset lipPos;
    double poured;
    double stream = 0;
    if (t < _a) {
      final q = Curves.easeInOutCubic.transform(t / _a);
      angle = d * thetaA * q;
      lipPos = Offset.lerp(homeLip, lipTarget, q)!
          .translate(0, -math.sin(math.pi * q) * tw * 0.5);
      poured = 0;
    } else if (t <= _b) {
      final p = Curves.easeInOut.transform((t - _a) / (_b - _a));
      poured = p;
      final f = f0 - (e.amount / cap) * p;
      angle = d * math.max(thetaA, phiFor(f));
      lipPos = lipTarget;
      stream = math.max(0.0, math.min(1.0, math.min(p / 0.18, (1 - p) / 0.12)));
    } else {
      final q = Curves.easeInOutCubic.transform((t - _b) / (1 - _b));
      poured = 1;
      final endAngle = d * math.max(thetaA, phiFor(f1));
      angle = endAngle * (1 - q);
      lipPos = Offset.lerp(lipTarget, homeLip, q)!
          .translate(0, -math.sin(math.pi * q) * tw * 0.25);
    }

    final rv = lipLocal - c;
    final cs = math.cos(angle), sn = math.sin(angle);
    final rot = Offset(rv.dx * cs - rv.dy * sn, rv.dx * sn + rv.dy * cs);
    final topLeft = lipPos - c - rot;

    final dstFrac = (dstLen + e.amount * poured) / cap;
    final yTop = dst.top + geo.interior.top;
    final yBottom = dst.top + geo.interior.bottom;
    final surfaceY = yBottom - dstFrac * (yBottom - yTop);

    return _Pose(topLeft, angle, poured, stream, lipPos,
        Offset(dst.center.dx, surfaceY));
  }

  double _sloshFor(int i) {
    if (i != _sloshA && i != _sloshB) return 0;
    final t = _slosh.value * 1.4;
    final sign = i == _sloshB ? 1.0 : -1.0;
    return sign * 0.11 * math.exp(-3.2 * t) * math.sin(15 * t);
  }

  // ------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    return LayoutBuilder(builder: (context, c) {
      final cap = game.currentLevel.tubeCapacity;
      final layout = _computeLayout(c.biggest, game.tubes.length, cap);
      _layout = layout;
      return AnimatedBuilder(
        animation: Listenable.merge([_pour, _slosh, _burst]),
        builder: (context, _) => _buildStack(game, layout, c.biggest, cap),
      );
    });
  }

  Widget _buildStack(GameProvider game, _Layout L, Size area, int cap) {
    final tubes = game.tubes;
    final e = _active;
    final tw = L.tw, th = L.th;
    final children = <Widget>[];

    children.add(Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(painter: _ShelfPainter(L.rects, tw, widget.theme)),
      ),
    ));

    _Pose? pose;
    if (e != null && e.from < L.rects.length && e.to < L.rects.length) {
      pose = _pose(e, _pour.value, L, area);
    }
    Widget? activeW;

    for (int i = 0; i < tubes.length && i < L.rects.length; i++) {
      final rect = L.rects[i];
      final tube = tubes[i];
      var bands = TubeWidget.bandsOf(tube.colors);

      if (pose != null && e != null && e.to == i) {
        bands = [...bands, LiquidBand(e.color, e.amount * pose.poured)];
      }

      if (pose != null && e != null && e.from == i) {
        bands = List.of(bands);
        for (int k = 0; k < e.amount; k++) {
          final idx = bands.length - 1 - k;
          if (idx < 0) break;
          bands[idx] = LiquidBand(bands[idx].color, 1 - pose.poured);
        }
        activeW = Positioned(
          key: ValueKey('tube$i'),
          left: pose.topLeft.dx,
          top: pose.topLeft.dy,
          width: tw,
          height: th,
          child: Transform.rotate(
            angle: pose.angle,
            child: TubeWidget(
              bands: bands,
              capacity: cap,
              width: tw,
              height: th,
              tilt: pose.angle,
            ),
          ),
        );
        continue;
      }

      final selected = game.selectedTubeIndex == i && e == null;
      Color? glow;
      double glowAmt = 0;
      Animation<double>? pulse;
      if (selected) {
        glow = AppTheme.accent;
        glowAmt = 1;
      } else if (game.hintFrom == i) {
        glow = AppTheme.warning;
        glowAmt = 1;
        pulse = _pulse;
      } else if (game.hintTo == i) {
        glow = AppTheme.accent;
        glowAmt = 1;
        pulse = _pulse;
      }
      final done = !tube.isEmpty && tube.isSorted && e?.to != i;
      if (glow == null && done) {
        glow = AppTheme.success;
        glowAmt = 0.55;
      }

      children.add(AnimatedPositioned(
        key: ValueKey('tube$i'),
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        left: rect.left,
        top: rect.top - (selected ? th * 0.14 : 0),
        width: tw,
        height: th,
        child: TubeWidget(
          bands: bands,
          capacity: cap,
          width: tw,
          height: th,
          slosh: _sloshFor(i),
          glowColor: glow,
          glowAmount: glowAmt,
          completed: done,
          pulse: pulse,
          onTap: () => game.selectTube(i),
        ),
      ));
    }

    if (activeW != null) children.add(activeW);

    final burstT = _burst.isAnimating ? _burst.value : -1.0;
    children.add(Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _OverlayPainter(
            lip: pose?.lip,
            target: pose?.target,
            color: e?.color ?? Colors.white,
            strength: pose?.stream ?? 0,
            width: tw * 0.17,
            phase: _pour.value * 6,
            burstCenter: _burstRect == null
                ? null
                : Offset(_burstRect!.center.dx, _burstRect!.top + th * 0.04),
            burstT: burstT,
            burstColor: _burstColor,
            burstSize: tw,
          ),
        ),
      ),
    ));

    return Stack(clipBehavior: Clip.none, children: children);
  }
}

/// Shelf + soft contact shadows under each tube.
class _ShelfPainter extends CustomPainter {
  final List<Rect> rects;
  final double tw;
  final WorldTheme theme;
  _ShelfPainter(this.rects, this.tw, this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    final rows = <double, List<double>>{};
    for (final r in rects) {
      final e = rows.putIfAbsent(r.top, () => [r.left, r.right, r.bottom]);
      e[0] = math.min(e[0], r.left);
      e[1] = math.max(e[1], r.right);
    }
    for (final entry in rows.entries) {
      final l = entry.value[0] - tw * 0.3;
      final r = entry.value[1] + tw * 0.3;
      final bottom = entry.value[2];
      final shelf = RRect.fromLTRBR(
        l, bottom - tw * 0.1, r, bottom + tw * 0.22, Radius.circular(tw * 0.12),
      );
      canvas.drawRRect(
        shelf.shift(Offset(0, tw * 0.10)),
        Paint()
          ..color = Colors.black.withOpacity(0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      canvas.drawRRect(
        shelf,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withOpacity(0.26),
              theme.orb.withOpacity(0.12),
              Colors.white.withOpacity(0.04),
            ],
          ).createShader(shelf.outerRect),
      );
      canvas.drawLine(
        Offset(l + tw * 0.1, bottom - tw * 0.1),
        Offset(r - tw * 0.1, bottom - tw * 0.1),
        Paint()
          ..color = Colors.white.withOpacity(0.5)
          ..strokeWidth = 1.4
          ..strokeCap = StrokeCap.round,
      );
    }
    final sp = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    for (final r in rects) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(r.center.dx, r.bottom - tw * 0.02),
          width: tw * 0.95,
          height: tw * 0.2,
        ),
        sp,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ShelfPainter old) =>
      old.tw != tw || old.rects.length != rects.length || old.rects != rects;
}

/// Liquid stream, splash and "tube completed" sparkle burst.
class _OverlayPainter extends CustomPainter {
  final Offset? lip;
  final Offset? target;
  final Color color;
  final double strength;
  final double width;
  final double phase;
  final Offset? burstCenter;
  final double burstT;
  final Color burstColor;
  final double burstSize;

  _OverlayPainter({
    required this.lip,
    required this.target,
    required this.color,
    required this.strength,
    required this.width,
    required this.phase,
    required this.burstCenter,
    required this.burstT,
    required this.burstColor,
    required this.burstSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (lip != null && target != null && strength > 0.01) {
      final l = lip!;
      final t = target!;
      final dy = math.max(10.0, t.dy - l.dy);
      final dx = t.dx - l.dx;
      final path = Path()
        ..moveTo(l.dx, l.dy)
        ..cubicTo(l.dx + dx * 0.5, l.dy + dy * 0.05, t.dx, l.dy + dy * 0.45,
            t.dx, t.dy);
      final w = width * strength;
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = w
          ..color = color.withOpacity(0.96),
      );
      final hsl = HSLColor.fromColor(color);
      canvas.drawPath(
        path.shift(Offset(-w * 0.18, 0)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = w * 0.32
          ..color = hsl
              .withLightness((hsl.lightness + 0.3).clamp(0.0, 1.0))
              .toColor()
              .withOpacity(0.7),
      );

      // ripples
      for (int k = 0; k < 3; k++) {
        final q = (phase * 0.9 + k / 3) % 1.0;
        final rw = w * (1.1 + q * 3.0);
        canvas.drawOval(
          Rect.fromCenter(center: t, width: rw * 2, height: rw * 0.55),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6
            ..color = Colors.white.withOpacity((1 - q) * 0.55 * strength),
        );
      }
      // droplets
      for (int i = 0; i < 5; i++) {
        final a = -math.pi * (0.15 + 0.7 * i / 4);
        final r = (phase * 1.3 + i * 0.37) % 1.0;
        final p = t +
            Offset(math.cos(a) * r * w * 3.2,
                math.sin(a) * r * w * 3.6 + r * r * w * 3.4);
        canvas.drawCircle(
          p,
          math.max(0.5, w * 0.17 * (1 - r)),
          Paint()..color = color.withOpacity(0.85 * (1 - r)),
        );
      }
    }

    if (burstCenter != null && burstT >= 0) {
      final c = burstCenter!;
      final e = Curves.easeOutCubic.transform(burstT);
      canvas.drawCircle(
        c,
        burstSize * (0.3 + 1.2 * e),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3 * (1 - burstT) + 0.5
          ..color = burstColor.withOpacity((1 - burstT) * 0.9),
      );
      for (int i = 0; i < 10; i++) {
        final a = i * math.pi * 2 / 10;
        final dist = burstSize * (0.4 + 1.3 * e);
        final p = c + Offset(math.cos(a) * dist, math.sin(a) * dist);
        canvas.drawCircle(
          p,
          math.max(0.5, 4 * (1 - burstT)),
          Paint()
            ..color = (i.isEven ? Colors.white : AppTheme.gold)
                .withOpacity(1 - burstT),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter old) => true;
}
