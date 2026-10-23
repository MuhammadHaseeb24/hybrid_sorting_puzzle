import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static const String _keyUnlocked = 'unlocked_level';
  static const String _keyStars = 'level_stars';
  static const String _keyTotalStars = 'total_stars';
  static const String _keyHintCount = 'hint_count';
  static const String _keyUndoCount = 'undo_count';
  static const String _keyExtraTubeCount = 'extra_tube_count';
  static const String _keyAchievements = 'achievements';
  static const String _keySound = 'sound_enabled';
  static const String _keyMusic = 'music_enabled';
  static const String _keyHaptics = 'haptics_enabled';
  static const String _keyWeeklyBadgeStart = 'weekly_badge_start';
  static const String _keyGamesPlayed = 'games_played';
  static const String _keyPerfectLevels = 'perfect_levels';
  static const String _keyTotalMoves = 'total_moves';
  static const String _keyNoHint = 'no_hint_levels';

  static Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  // Level progress
  static Future<int> getUnlockedLevel() async {
    final p = await _prefs;
    return p.getInt(_keyUnlocked) ?? 1;
  }

  static Future<void> setUnlockedLevel(int level) async {
    final p = await _prefs;
    final current = p.getInt(_keyUnlocked) ?? 1;
    if (level > current) {
      await p.setInt(_keyUnlocked, level);
    }
  }

  static Future<Map<int, int>> getAllStars() async {
    final p = await _prefs;
    final raw = p.getString(_keyStars);
    if (raw == null) return {};
    final Map<String, dynamic> decoded = jsonDecode(raw);
    return decoded.map((k, v) => MapEntry(int.parse(k), v as int));
  }

  static Future<void> saveStars(int levelId, int stars) async {
    final p = await _prefs;
    final all = await getAllStars();
    final existing = all[levelId] ?? 0;
    if (stars > existing) {
      all[levelId] = stars;
      await p.setString(
        _keyStars,
        jsonEncode(all.map((k, v) => MapEntry(k.toString(), v))),
      );
      // Update total
      final total = all.values.fold(0, (a, b) => a + b);
      await p.setInt(_keyTotalStars, total);
    }
  }

  static Future<int> getTotalStars() async {
    final p = await _prefs;
    return p.getInt(_keyTotalStars) ?? 0;
  }

  // Boosters
  static Future<int> getHintCount() async {
    final p = await _prefs;
    return p.getInt(_keyHintCount) ?? 2; // 2 free
  }

  static Future<void> setHintCount(int count) async {
    final p = await _prefs;
    await p.setInt(_keyHintCount, count);
  }

  static Future<int> getUndoCount() async {
    final p = await _prefs;
    return p.getInt(_keyUndoCount) ?? 5;
  }

  static Future<void> setUndoCount(int count) async {
    final p = await _prefs;
    await p.setInt(_keyUndoCount, count);
  }

  static Future<int> getExtraTubeCount() async {
    final p = await _prefs;
    return p.getInt(_keyExtraTubeCount) ?? 2;
  }

  static Future<void> setExtraTubeCount(int count) async {
    final p = await _prefs;
    await p.setInt(_keyExtraTubeCount, count);
  }

  // Achievements
  static Future<Set<String>> getUnlockedAchievements() async {
    final p = await _prefs;
    final list = p.getStringList(_keyAchievements) ?? [];
    return list.toSet();
  }

  static Future<void> unlockAchievement(String id) async {
    final p = await _prefs;
    final current = await getUnlockedAchievements();
    if (!current.contains(id)) {
      current.add(id);
      await p.setStringList(_keyAchievements, current.toList());
    }
  }

  // Settings
  static Future<bool> getSoundEnabled() async {
    final p = await _prefs;
    return p.getBool(_keySound) ?? true;
  }

  static Future<void> setSoundEnabled(bool value) async {
    final p = await _prefs;
    await p.setBool(_keySound, value);
  }

  static Future<bool> getMusicEnabled() async {
    final p = await _prefs;
    return p.getBool(_keyMusic) ?? true;
  }

  static Future<void> setMusicEnabled(bool value) async {
    final p = await _prefs;
    await p.setBool(_keyMusic, value);
  }

  static Future<bool> getHapticsEnabled() async {
    final p = await _prefs;
    return p.getBool(_keyHaptics) ?? true;
  }

  static Future<void> setHapticsEnabled(bool value) async {
    final p = await _prefs;
    await p.setBool(_keyHaptics, value);
  }

  // Weekly Top Badge
  static Future<DateTime?> getWeeklyBadgeStart() async {
    final p = await _prefs;
    final ms = p.getInt(_keyWeeklyBadgeStart);
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  static Future<void> startWeeklyBadge() async {
    final p = await _prefs;
    await p.setInt(_keyWeeklyBadgeStart, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<bool> hasActiveWeeklyBadge() async {
    final start = await getWeeklyBadgeStart();
    if (start == null) return false;
    return DateTime.now().difference(start).inDays < 7;
  }

  // Stats
  static Future<int> getGamesPlayed() async {
    final p = await _prefs;
    return p.getInt(_keyGamesPlayed) ?? 0;
  }

  static Future<void> incrementGamesPlayed() async {
    final p = await _prefs;
    final current = p.getInt(_keyGamesPlayed) ?? 0;
    await p.setInt(_keyGamesPlayed, current + 1);
  }

  static Future<int> getPerfectLevels() async {
    final p = await _prefs;
    return p.getInt(_keyPerfectLevels) ?? 0;
  }

  static Future<void> incrementPerfectLevels() async {
    final p = await _prefs;
    final current = p.getInt(_keyPerfectLevels) ?? 0;
    await p.setInt(_keyPerfectLevels, current + 1);
  }

  static Future<int> getTotalMoves() async {
    final p = await _prefs;
    return p.getInt(_keyTotalMoves) ?? 0;
  }

  static Future<void> addMoves(int moves) async {
    final p = await _prefs;
    final current = p.getInt(_keyTotalMoves) ?? 0;
    await p.setInt(_keyTotalMoves, current + moves);
  }

  static Future<int> getNoHintLevels() async {
    final p = await _prefs;
    return p.getInt(_keyNoHint) ?? 0;
  }

  static Future<void> incrementNoHintLevels() async {
    final p = await _prefs;
    final current = p.getInt(_keyNoHint) ?? 0;
    await p.setInt(_keyNoHint, current + 1);
  }

  // Reset all
  static Future<void> resetProgress() async {
    final p = await _prefs;
    await p.remove(_keyUnlocked);
    await p.remove(_keyStars);
    await p.remove(_keyTotalStars);
    await p.remove(_keyAchievements);
    await p.remove(_keyWeeklyBadgeStart);
    await p.remove(_keyGamesPlayed);
    await p.remove(_keyPerfectLevels);
    await p.remove(_keyTotalMoves);
    await p.remove(_keyNoHint);
    // Keep settings & boosters or reset boosters too
    await p.setInt(_keyHintCount, 2);
    await p.setInt(_keyUndoCount, 5);
    await p.setInt(_keyExtraTubeCount, 2);
  }
}
