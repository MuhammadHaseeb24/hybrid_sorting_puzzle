import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/level_data.dart';
import '../providers/game_provider.dart';
import '../services/sound_service.dart';
import '../utils/app_theme.dart';
import '../utils/haptics.dart';
import '../utils/world_theme.dart';
import '../widgets/animated_backdrop.dart';
import 'game_screen.dart';

const double _itemH = 108;

double _nodeX(int level, double width) =>
    width * (0.5 + 0.27 * math.sin(level * 0.9));

/// Winding road map with all 320 levels (level 1 at the bottom).
class LevelSelectScreen extends StatefulWidget {
  /// When true (inside the bottom-nav shell) the back button is hidden.
  final bool embedded;
  const LevelSelectScreen({super.key, this.embedded = false});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  final ScrollController _sc = ScrollController();
  final ScrollController _chapterSc = ScrollController();
  late final ValueNotifier<int> _world;
  bool _jumped = false;

  @override
  void initState() {
    super.initState();
    final game = context.read<GameProvider>();
    _world = ValueNotifier(WorldTheme.indexForLevel(game.unlockedLevel));
    _sc.addListener(_onScroll);
  }

  @override
  void dispose() {
    _sc.dispose();
    _chapterSc.dispose();
    _world.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_sc.hasClients) return;
    final center = _sc.offset + _sc.position.viewportDimension / 2;
    final level = ((center - 30) / _itemH).floor() + 1;
    final idx = WorldTheme.indexForLevel(
        math.max(1, math.min(LevelRepository.totalLevels, level)));
    if (idx != _world.value) {
      _world.value = idx;
      if (_chapterSc.hasClients) {
        final t = math.max(
            0.0, math.min(_chapterSc.position.maxScrollExtent, idx * 92.0 - 120));
        _chapterSc.animateTo(t,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    }
  }

  double _targetFor(int level) {
    final vp = _sc.position.viewportDimension;
    final t = 30 + (level - 1) * _itemH + _itemH / 2 - vp / 2;
    return math.max(0.0, math.min(_sc.position.maxScrollExtent, t));
  }

  void _goToCurrent(int level, {bool instantFirst = false}) {
    if (!_sc.hasClients) return;
    final target = _targetFor(level);
    if (instantFirst && target > 600) {
      _sc.jumpTo(target - 600);
    }
    _sc.animateTo(
      target,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<int>(
        valueListenable: _world,
        builder: (context, worldIdx, _) {
          return AnimatedBackdrop(
            theme: WorldTheme.byIndex(worldIdx),
            child: SafeArea(
              child: Consumer<GameProvider>(
                builder: (context, game, _) {
                  final current = math.min(
                      game.unlockedLevel, LevelRepository.totalLevels);
                  if (!_jumped) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_jumped || !_sc.hasClients) return;
                      _jumped = true;
                      _goToCurrent(current, instantFirst: true);
                    });
                  }
                  return Stack(
                    children: [
                      ListView.builder(
                        controller: _sc,
                        reverse: true,
                        itemExtent: _itemH,
                        cacheExtent: 400,
                        padding: const EdgeInsets.only(top: 124, bottom: 30),
                        itemCount: LevelRepository.totalLevels,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final level = index + 1;
                          return _RoadRow(
                            level: level,
                            unlocked: game.isLevelUnlocked(level),
                            nextUnlocked: game.isLevelUnlocked(level + 1),
                            isCurrent: level == current,
                            stars: game.getStarsForLevel(level),
                            onTap: () => _open(context, game, level),
                          );
                        },
                      ),
                      _topBar(context, game, worldIdx),
                      _chapterStrip(game, worldIdx),
                      Positioned(
                        right: 16,
                        bottom: 18,
                        child: _GlassFab(
                          icon: Icons.my_location_rounded,
                          onTap: () => _goToCurrent(current),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _open(BuildContext context, GameProvider game, int level) {
    if (!game.isLevelUnlocked(level)) {
      Haptics.light();
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 1400),
            backgroundColor: AppTheme.surfaceLight,
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Finish level ${game.unlockedLevel} first!',
              style: GoogleFonts.poppins(),
            ),
          ),
        );
      return;
    }
    SoundService().playClick();
    Haptics.tap();
    game.loadLevel(level);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const GameScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  Widget _topBar(BuildContext context, GameProvider game, int worldIdx) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: _topBarBody(context, game, worldIdx),
    );
  }

  Widget _topBarBody(BuildContext context, GameProvider game, int worldIdx) {
    final w = WorldTheme.byIndex(worldIdx);
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 14, 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.55), Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          if (!widget.embedded)
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: AppTheme.textPrimary,
            )
          else
            const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Adventure Map',
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.w700),
                ),
                Text(
                  '${w.icon}  World ${w.index + 1} • ${w.name}',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded,
                    color: AppTheme.warning, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${game.totalStars}',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on_rounded,
                    color: AppTheme.gold, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${game.coins}',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Horizontal chapter (world) picker: tap to jump to that chapter.
  Widget _chapterStrip(GameProvider game, int worldIdx) {
    return Positioned(
      top: 64,
      left: 0,
      right: 0,
      height: 50,
      child: ListView.separated(
        controller: _chapterSc,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: WorldTheme.worlds.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final w = WorldTheme.worlds[i];
          final start = i * WorldTheme.levelsPerWorld + 1;
          final open = game.unlockedLevel >= start;
          final selected = i == worldIdx;
          return GestureDetector(
            onTap: () {
              Haptics.tap();
              SoundService().playClick();
              if (_sc.hasClients) {
                _sc.animateTo(
                  _targetFor(math.min(LevelRepository.totalLevels, start + 12)),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                );
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 84,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: selected
                    ? LinearGradient(colors: [
                        Color.lerp(w.primary, Colors.white, 0.2)!,
                        w.primary,
                      ])
                    : null,
                color: selected ? null : Colors.black.withOpacity(0.3),
                border: Border.all(
                  color: selected
                      ? Colors.white.withOpacity(0.8)
                      : Colors.white.withOpacity(open ? 0.2 : 0.08),
                  width: selected ? 1.6 : 1,
                ),
                boxShadow: selected
                    ? [BoxShadow(color: w.primary.withOpacity(0.6), blurRadius: 12)]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Opacity(
                    opacity: open ? 1 : 0.45,
                    child: Text(open ? w.icon : '🔒',
                        style: const TextStyle(fontSize: 17)),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Ch ${i + 1}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withOpacity(open ? 1 : 0.5),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GlassFab extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassFab({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Haptics.tap();
        onTap();
      },
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.14),
          border: Border.all(color: Colors.white.withOpacity(0.35)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

// ---------------------------------------------------------------------
class _RoadRow extends StatelessWidget {
  final int level;
  final bool unlocked;
  final bool nextUnlocked;
  final bool isCurrent;
  final int stars;
  final VoidCallback onTap;

  const _RoadRow({
    required this.level,
    required this.unlocked,
    required this.nextUnlocked,
    required this.isCurrent,
    required this.stars,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WorldTheme.forLevel(level);
    final isBoss = level % 10 == 0;
    final nodeSize = isBoss ? 78.0 : 64.0;
    final startsWorld = (level - 1) % WorldTheme.levelsPerWorld == 0;

    return LayoutBuilder(builder: (context, c) {
      final x = _nodeX(level, c.maxWidth);
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _RoadPainter(
                level: level,
                theme: theme,
                width: c.maxWidth,
                upReached: nextUnlocked,
                downReached: unlocked,
              ),
            ),
          ),
          if (startsWorld) _bannerSide(theme, c.maxWidth, x, nodeSize),
          Positioned(
            left: x - nodeSize / 2,
            top: _itemH / 2 - nodeSize / 2,
            width: nodeSize,
            height: nodeSize,
            child: _node(theme, isBoss, nodeSize),
          ),
          if (unlocked && !isCurrent)
            Positioned(
              left: x - 30,
              top: _itemH / 2 + nodeSize / 2 - 2,
              width: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return Icon(
                    i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 15,
                    color: i < stars
                        ? AppTheme.warning
                        : Colors.white.withOpacity(0.3),
                  );
                }),
              ),
            ),
          if (isCurrent)
            Positioned(
              left: x - 36,
              top: _itemH / 2 - nodeSize / 2 - 30,
              width: 72,
              child: _PlayBubble(color: theme.accent)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .moveY(begin: 0, end: -6, duration: 700.ms),
            ),
        ],
      );
    });
  }

  Widget _bannerSide(WorldTheme theme, double width, double x, double nodeSize) {
    final rightSpace = width - (x + nodeSize / 2) - 12;
    final leftSpace = x - nodeSize / 2 - 12;
    final onRight = rightSpace >= leftSpace;
    final space = math.max(80.0, math.min(170.0, onRight ? rightSpace : leftSpace));
    return Positioned(
      top: _itemH / 2 - 22,
      left: onRight ? x + nodeSize / 2 + 8 : null,
      right: onRight ? null : width - (x - nodeSize / 2) + 8,
      width: space,
      child: IgnorePointer(
        child: Align(
          alignment: onRight ? Alignment.centerLeft : Alignment.centerRight,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: _WorldBanner(theme: theme),
          ),
        ),
      ),
    );
  }

  Widget _node(WorldTheme theme, bool isBoss, double size) {
    final List<Color> grad;
    if (!unlocked) {
      grad = [const Color(0xFF4A4F66), const Color(0xFF2B2F42)];
    } else if (isBoss) {
      grad = [const Color(0xFFFFD54F), const Color(0xFFE53935)];
    } else if (stars > 0) {
      grad = [Color.lerp(theme.primary, Colors.white, 0.3)!, theme.primary];
    } else {
      grad = [theme.accent, Color.lerp(theme.accent, theme.primary, 0.6)!];
    }

    Widget node = GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.35, -0.45),
            radius: 1.0,
            colors: [grad.first, grad.last],
          ),
          border: Border.all(
            color: isCurrent
                ? Colors.white
                : Colors.white.withOpacity(unlocked ? 0.55 : 0.12),
            width: isCurrent ? 3.5 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              offset: const Offset(0, 5),
            ),
            if (unlocked)
              BoxShadow(
                color: grad.last.withOpacity(isCurrent ? 0.85 : 0.4),
                blurRadius: isCurrent ? 26 : 12,
                spreadRadius: isCurrent ? 3 : 0,
              ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: size * 0.08,
              left: size * 0.2,
              right: size * 0.2,
              height: size * 0.28,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(unlocked ? 0.45 : 0.1),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            if (!unlocked)
              Icon(Icons.lock_rounded,
                  color: Colors.white.withOpacity(0.45), size: size * 0.4)
            else
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isBoss)
                    Text('👑', style: TextStyle(fontSize: size * 0.22)),
                  Text(
                    '$level',
                    style: GoogleFonts.poppins(
                      fontSize: size * (level >= 100 ? 0.30 : 0.36),
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.0,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.45),
                          offset: const Offset(0, 2),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );

    if (isCurrent) {
      node = node
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.1, 1.1),
            duration: 900.ms,
            curve: Curves.easeInOut,
          );
    }
    return node;
  }
}

class _PlayBubble extends StatelessWidget {
  final Color color;
  const _PlayBubble({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.6), blurRadius: 10),
        ],
      ),
      child: Center(
        child: Text(
          'PLAY',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: Colors.black87,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class _WorldBanner extends StatelessWidget {
  final WorldTheme theme;
  const _WorldBanner({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primary, Color.lerp(theme.primary, theme.accent, 0.6)!],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: theme.primary.withOpacity(0.6), blurRadius: 12),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${theme.icon} WORLD ${theme.index + 1}',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          Text(
            theme.name,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Draws the half of the road leading up to the next node and the half coming
/// from the previous node, so each row stays inside its own bounds.
class _RoadPainter extends CustomPainter {
  final int level;
  final WorldTheme theme;
  final double width;
  final bool upReached;
  final bool downReached;

  _RoadPainter({
    required this.level,
    required this.theme,
    required this.width,
    required this.upReached,
    required this.downReached,
  });

  // cubic split helpers (t = 0.5)
  List<Offset> _firstHalf(List<Offset> p) => [
        p[0],
        (p[0] + p[1]) / 2,
        (p[0] + p[1] * 2 + p[2]) / 4,
        (p[0] + p[1] * 3 + p[2] * 3 + p[3]) / 8,
      ];

  List<Offset> _secondHalf(List<Offset> p) => [
        (p[0] + p[1] * 3 + p[2] * 3 + p[3]) / 8,
        (p[1] + p[2] * 2 + p[3]) / 4,
        (p[2] + p[3]) / 2,
        p[3],
      ];

  Path _cubic(List<Offset> p) => Path()
    ..moveTo(p[0].dx, p[0].dy)
    ..cubicTo(p[1].dx, p[1].dy, p[2].dx, p[2].dy, p[3].dx, p[3].dy);

  void _stroke(Canvas canvas, Path path, bool reached) {
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..strokeCap = StrokeCap.round
        ..color = Colors.black.withOpacity(0.28),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 13
        ..strokeCap = StrokeCap.round
        ..color = reached
            ? theme.accent.withOpacity(0.85)
            : Colors.white.withOpacity(0.14),
    );
    // dashed centre line
    for (final m in path.computeMetrics()) {
      double d = 0;
      while (d < m.length) {
        final seg = m.extractPath(d, math.min(d + 6, m.length));
        canvas.drawPath(
          seg,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.2
            ..strokeCap = StrokeCap.round
            ..color = Colors.white.withOpacity(reached ? 0.7 : 0.2),
        );
        d += 14;
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final x = _nodeX(level, width);
    final cy = _itemH / 2;

    // segment to level+1 (above): this row draws its first half
    if (level < 320) {
      final xn = _nodeX(level + 1, width);
      final seg = [
        Offset(x, cy),
        Offset(x, cy - _itemH * 0.5),
        Offset(xn, cy - _itemH * 0.5),
        Offset(xn, cy - _itemH),
      ];
      // reached when the NEXT level is unlocked => level itself completed
      _stroke(canvas, _cubic(_firstHalf(seg)), upReached);
    }
    // segment from level-1 (below): second half of that segment
    if (level > 1) {
      final xp = _nodeX(level - 1, width);
      final seg = [
        Offset(xp, cy + _itemH),
        Offset(xp, cy + _itemH * 0.5),
        Offset(x, cy + _itemH * 0.5),
        Offset(x, cy),
      ];
      _stroke(canvas, _cubic(_secondHalf(seg)), downReached);
    }
  }

  @override
  bool shouldRepaint(covariant _RoadPainter old) =>
      old.upReached != upReached ||
      old.downReached != downReached ||
      old.width != width ||
      old.theme != theme;
}
