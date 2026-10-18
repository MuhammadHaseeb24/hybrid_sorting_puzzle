# Sortify — Professional Hybrid Sorting Puzzle

A polished Flutter hybrid-casual color tube sorting game (2026 style).

## What's Included

### Core Gameplay
- Classic Water Sort style tube pouring
- 30 handcrafted progressive levels
- Stars system (1–3★ based on move efficiency)
- Undo / Hint / Extra Tube boosters

### Professional Features
- **Progress Saving** — Levels, stars, boosters & achievements persist
- **Achievements** — 15 achievements including weekly **Top Player Badge** (7 days)
- **Hints System** — 2 free hints, then watch short rewarded ad for +3 more
- **Same ad flow** for Undo and Extra Tube when empty
- **Settings** — Sound, Music, Haptics toggles + Reset Progress
- **Responsive UI** — Works on small phones to large screens
- **Modern Dark Theme** — Vibrant accents, glass tubes, confetti, micro-animations
- **Weekly Top Badge** — Unlocks when you collect enough stars

### Screens
1. Home (logo, stats, Top Player badge, Play / Achievements / Settings)
2. Level Select (grid with lock/unlock + stars)
3. Game (tubes, boosters, win/lose overlays)
4. Achievements (list + weekly badge banner)
5. Settings (audio, boosters info, progress, reset)

## How to Run

```bash
cd sortify
flutter pub get
flutter run
```

Requirements: Flutter 3.0+

## Project Structure

```
lib/
├── main.dart
├── models/
│   ├── level_data.dart      # Tube, LevelData, 30 levels, colors
│   └── achievement.dart     # Achievement definitions
├── providers/
│   └── game_provider.dart   # Full game state + persistence
├── screens/
│   ├── home_screen.dart
│   ├── level_select_screen.dart
│   ├── game_screen.dart
│   ├── achievements_screen.dart
│   └── settings_screen.dart
├── widgets/
│   ├── tube_widget.dart
│   ├── booster_button.dart
│   └── ad_dialog.dart       # Simulated rewarded ad
├── services/
│   └── progress_service.dart # SharedPreferences
└── utils/
    └── app_theme.dart
```

## Booster Rules
- Start with **2 free Hints**, 5 Undos, 2 Extra Tubes
- When a booster reaches 0 → tap shows "Watch Ad" dialog
- Simulated 3-second ad → grants +3 Hints / +3 Undos / +2 Extra Tubes

## Next Steps for Production
- Replace simulated ad with real AdMob / AppLovin rewarded ads
- Add real sound effects (audioplayers already in pubspec)
- Add more levels or procedural generator
- Daily challenges / LiveOps
- Leaderboards

---

Built with Flutter + Provider + Google Fonts + flutter_animate + confetti
Ready for soft launch testing!
