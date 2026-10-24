import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/sound_service.dart';
import '../utils/app_theme.dart';
import '../utils/haptics.dart';
import '../utils/navigation.dart';
import 'home_screen.dart';
import 'level_select_screen.dart';
import 'settings_screen.dart';

/// Bottom navigation shell: Map | big PLAY (home/game) | Settings.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const int _map = 0, _home = 1, _settings = 2;
  int _index = _home;

  void _select(int i) {
    if (i == _index) return;
    Haptics.tap();
    SoundService().playClick();
    setState(() => _index = i);
  }

  void _centerTap() {
    if (_index != _home) {
      _select(_home);
    } else {
      SoundService().playClick();
      Haptics.medium();
      startLevel(context);
    }
  }

  Widget _tab() {
    switch (_index) {
      case _map:
        return const LevelSelectScreen(embedded: true);
      case _settings:
        return const SettingsScreen(embedded: true);
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _index == _home,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _index = _home);
      },
      child: Scaffold(
        extendBody: true,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: KeyedSubtree(key: ValueKey(_index), child: _tab()),
        ),
        bottomNavigationBar: _NavBar(
          index: _index,
          onSelect: _select,
          onCenter: _centerTap,
        ),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;
  final VoidCallback onCenter;

  const _NavBar({
    required this.index,
    required this.onSelect,
    required this.onCenter,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    const panelH = 70.0;
    const total = 96.0;

    return SizedBox(
      height: total + bottom,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // glass panel
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: panelH + bottom,
            child: Container(
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xE61C1C3C), Color(0xF20A0A1C)],
                ),
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.18)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.35),
                    blurRadius: 24,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
            ),
          ),
          // side items
          Positioned(
            left: 0,
            right: 0,
            bottom: bottom,
            height: panelH,
            child: Row(
              children: [
                Expanded(
                  child: _NavItem(
                    icon: Icons.map_rounded,
                    label: 'Map',
                    selected: index == 0,
                    color: AppTheme.accent,
                    onTap: () => onSelect(0),
                  ),
                ),
                const SizedBox(width: 108),
                Expanded(
                  child: _NavItem(
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    selected: index == 2,
                    color: AppTheme.warning,
                    onTap: () => onSelect(2),
                  ),
                ),
              ],
            ),
          ),
          // big centre button
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Center(
              child: GestureDetector(
                onTap: onCenter,
                child: _CenterButton(active: index == 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterButton extends StatelessWidget {
  final bool active;
  const _CenterButton({required this.active});

  @override
  Widget build(BuildContext context) {
    final btn = Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.35, -0.5),
          radius: 1.0,
          colors: [Color(0xFFA99BFF), Color(0xFF5B4CFF), Color(0xFF2E22A8)],
          stops: [0.0, 0.55, 1.0],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.7), width: 2.5),
        boxShadow: [
          const BoxShadow(color: Color(0xFF1B1380), offset: Offset(0, 5)),
          BoxShadow(
            color: AppTheme.primary.withOpacity(active ? 0.9 : 0.5),
            blurRadius: active ? 26 : 14,
            spreadRadius: active ? 2 : 0,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 7,
            left: 16,
            right: 16,
            height: 22,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.5),
                    Colors.white.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.play_arrow_rounded,
                  color: Colors.white, size: 38),
              Text(
                'PLAY',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  height: 0.8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
    return btn
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.06, 1.06),
          duration: 1000.ms,
          curve: Curves.easeInOut,
        );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack,
            width: selected ? 52 : 44,
            height: selected ? 44 : 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: selected
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.lerp(color, Colors.white, 0.3)!,
                        color,
                      ],
                    )
                  : null,
              color: selected ? null : Colors.white.withOpacity(0.06),
              border: Border.all(
                color: Colors.white.withOpacity(selected ? 0.6 : 0.1),
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                          color: color.withOpacity(0.7),
                          blurRadius: 14,
                          offset: const Offset(0, 3)),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              size: selected ? 26 : 22,
              color: selected ? Colors.white : AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              color: selected ? Colors.white : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
