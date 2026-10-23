 Sortify — 3D Liquid Sorting (320 levels)

 What's new
- 3D glass tubes**: perspective rim, glass reflections, cylinder-shaded liquid with elliptical surfaces, floor shadows and shelves.
- Real pour animation: tap a tube, then a target. The tube lifts, tilts over the glass, a liquid stream falls in with ripples/droplets, the level drains and fills smoothly, then the tube returns. Surfaces slosh after landing.
- 320 levels / 11 worlds (30 levels per world): levels 1-30 are the original hand-made ones; 31-320 are generated deterministically and verified solvable by a built-in solver (also used to set the 3-star / 2-star move targets). Every 10th level is a Boss level with extra colors; some levels use 5-slot tubes.
- Winding road map with glowing path, world banners, boss nodes, pulsing current level, auto-scroll to your level and a "my location" button. Background theme changes per world.
- Animated backdrops (floating glow orbs, vignette) on every screen.
- Sound: overlapping SFX pool, music pauses when app goes to background.
- Vibration: select tick, pour start, flow ticks while liquid runs, tube-complete thump, win pattern, fail pattern (all respect the Settings toggle).
- Tube complete**: golden lid, green glow, sparkle burst + chime.
- Hints now highlight the source and target tubes with pulsing glow and pick a useful move.
- 4 new achievements (50/100/200/300 levels); "Self Reliant" (5 levels without hints) now actually unlocks.
- Glossy jelly buttons, round booster buttons, pause sheet (sound/music/vibration), redesigned win/lose dialogs.

 Install
1. Replace `lib/` and `pubspec.yaml` in your existing Flutter project with these.
2. Copy the included `assets/sounds/` folder (bg_music, select, pour, win, lose, click, star — .mp3, synthesized, royalty-free) into your project. You can replace them with your own files using the same names.
3. `flutter pub get` then `flutter run`.

 Structure (new/changed files)
- `models/level_data.dart` — palette (16 colors), 30 hand-made levels, procedural generator + solver
- `providers/game_provider.dart` — pour events, `finishPour()`, hints, achievements
- `widgets/tube_widget.dart` — 3D glass tube painter
- `widgets/tube_board.dart` — layout, pour/tilt animation, stream, sparkles
- `widgets/animated_backdrop.dart`, `jelly_button.dart`, `booster_button.dart`
- `screens/home_screen.dart`, `level_select_screen.dart` (road map), `game_screen.dart`
- `utils/world_theme.dart`, `utils/haptics.dart`

 Tuning
- Pour speed: `_pour.duration` in `tube_board._sync()` (default 900 ms + 120 ms per unit poured).
- Difficulty curve: `_generate()` in `level_data.dart` (colors, capacity, empty tubes, star thresholds).
- Real ads: replace `AdDialog` with AdMob rewarded ads.
