import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/level_data.dart';
import '../models/achievement.dart';
import '../services/progress_service.dart';

enum GameStatus { playing, won, lost }

class GameProvider extends ChangeNotifier {
  late LevelData currentLevel;
  late List<Tube> tubes;
  int moves = 0;
  int selectedTubeIndex = -1;
  GameStatus status = GameStatus.playing;
  List<List<Tube>> history = [];
  int starsEarned = 0;
  bool isAnimating = false;
  bool usedHintThisLevel = false;

  // Boosters (loaded from storage)
  int undoCount = 5;
  int hintCount = 2;
  int extraTubeCount = 2;

  // Progress
  int unlockedLevel = 1;
  Map<int, int> levelStars = {};
  int totalStars = 0;
  Set<String> unlockedAchievements = {};
  bool hasWeeklyBadge = false;

  // Settings
  bool soundEnabled = true;
  bool musicEnabled = true;
  bool hapticsEnabled = true;

  // Stats
  int gamesPlayed = 0;
  int perfectLevels = 0;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    unlockedLevel = await ProgressService.getUnlockedLevel();
    levelStars = await ProgressService.getAllStars();
    totalStars = await ProgressService.getTotalStars();
    hintCount = await ProgressService.getHintCount();
    undoCount = await ProgressService.getUndoCount();
    extraTubeCount = await ProgressService.getExtraTubeCount();
    unlockedAchievements = await ProgressService.getUnlockedAchievements();
    hasWeeklyBadge = await ProgressService.hasActiveWeeklyBadge();
    soundEnabled = await ProgressService.getSoundEnabled();
    musicEnabled = await ProgressService.getMusicEnabled();
    hapticsEnabled = await ProgressService.getHapticsEnabled();
    gamesPlayed = await ProgressService.getGamesPlayed();
    perfectLevels = await ProgressService.getPerfectLevels();
    _initialized = true;
    notifyListeners();
  }

  void loadLevel(int levelId) {
    currentLevel = LevelRepository.getLevel(levelId);
    tubes = currentLevel.createTubes();
    moves = 0;
    selectedTubeIndex = -1;
    status = GameStatus.playing;
    history.clear();
    starsEarned = 0;
    isAnimating = false;
    usedHintThisLevel = false;
    notifyListeners();
  }

  void selectTube(int index) {
    if (status != GameStatus.playing || isAnimating) return;

    if (hapticsEnabled) {
      HapticFeedback.selectionClick();
    }

    if (selectedTubeIndex == -1) {
      if (!tubes[index].isEmpty) {
        selectedTubeIndex = index;
        notifyListeners();
      }
    } else if (selectedTubeIndex == index) {
      selectedTubeIndex = -1;
      notifyListeners();
    } else {
      _tryPour(selectedTubeIndex, index);
    }
  }

  void _tryPour(int from, int to) {
    final source = tubes[from];
    final dest = tubes[to];

    if (!source.canPourTo(dest)) {
      selectedTubeIndex = tubes[to].isEmpty ? -1 : to;
      notifyListeners();
      return;
    }

    _saveHistory();

    final amount = source.pourAmountTo(dest);
    final color = source.topColor!;

    for (int i = 0; i < amount; i++) {
      source.colors.removeLast();
      dest.colors.add(color);
    }

    moves++;
    selectedTubeIndex = -1;

    if (hapticsEnabled) {
      HapticFeedback.lightImpact();
    }

    if (_checkWin()) {
      status = GameStatus.won;
      _calculateStars();
      _onLevelComplete();
    } else if (moves >= currentLevel.maxMoves) {
      status = GameStatus.lost;
    }

    notifyListeners();
  }

  bool _checkWin() {
    for (final tube in tubes) {
      if (!tube.isEmpty && !tube.isSorted) return false;
    }
    return tubes.any((t) => !t.isEmpty);
  }

  void _calculateStars() {
    if (moves <= currentLevel.stars3Moves) {
      starsEarned = 3;
    } else if (moves <= currentLevel.stars2Moves) {
      starsEarned = 2;
    } else {
      starsEarned = 1;
    }
  }

  Future<void> _onLevelComplete() async {
    await ProgressService.incrementGamesPlayed();
    gamesPlayed++;
    await ProgressService.addMoves(moves);

    // Save stars
    await ProgressService.saveStars(currentLevel.id, starsEarned);
    levelStars[currentLevel.id] = starsEarned > (levelStars[currentLevel.id] ?? 0)
        ? starsEarned
        : levelStars[currentLevel.id] ?? 0;
    totalStars = levelStars.values.fold(0, (a, b) => a + b);

    if (starsEarned == 3) {
      await ProgressService.incrementPerfectLevels();
      perfectLevels++;
    }

    // Unlock next level
    final nextId = currentLevel.id + 1;
    if (nextId > unlockedLevel && nextId <= LevelRepository.totalLevels) {
      unlockedLevel = nextId;
      await ProgressService.setUnlockedLevel(nextId);
    }

    // Check achievements
    await _checkAchievements();

    // Weekly badge logic: if player has high stars, grant weekly badge
    if (totalStars >= 30 && !hasWeeklyBadge) {
      await ProgressService.startWeeklyBadge();
      hasWeeklyBadge = true;
      await ProgressService.unlockAchievement('weekly_top');
      unlockedAchievements.add('weekly_top');
    }

    notifyListeners();
  }

  Future<void> _checkAchievements() async {
    final completedLevels = levelStars.keys.length;
    final threeStarCount =
        levelStars.values.where((s) => s == 3).length;

    final checks = <String, bool>{
      'first_win': completedLevels >= 1,
      'level_5': completedLevels >= 5,
      'level_10': completedLevels >= 10,
      'level_20': completedLevels >= 20,
      'level_30': completedLevels >= 30,
      'three_star_1': threeStarCount >= 1,
      'three_star_5': threeStarCount >= 5,
      'three_star_15': threeStarCount >= 15,
      'perfect_3': perfectLevels >= 3,
      'total_stars_30': totalStars >= 30,
      'total_stars_60': totalStars >= 60,
      'games_20': gamesPlayed >= 20,
      'speed_demon': moves <= 10 && starsEarned >= 1,
    };

    for (final entry in checks.entries) {
      if (entry.value && !unlockedAchievements.contains(entry.key)) {
        await ProgressService.unlockAchievement(entry.key);
        unlockedAchievements.add(entry.key);
      }
    }
  }

  void _saveHistory() {
    history.add(tubes.map((t) => t.copyWith()).toList());
    if (history.length > 30) history.removeAt(0);
  }

  Future<void> undo() async {
    if (undoCount <= 0 || history.isEmpty || status != GameStatus.playing) {
      return;
    }
    tubes = history.removeLast();
    moves = (moves - 1).clamp(0, 999);
    selectedTubeIndex = -1;
    undoCount--;
    await ProgressService.setUndoCount(undoCount);
    if (hapticsEnabled) HapticFeedback.mediumImpact();
    notifyListeners();
  }

  /// Returns true if hint was used, false if needs ad
  Future<bool> useHint() async {
    if (status != GameStatus.playing) return false;

    if (hintCount > 0) {
      // Free / remaining hints
      for (int i = 0; i < tubes.length; i++) {
        for (int j = 0; j < tubes.length; j++) {
          if (i != j && tubes[i].canPourTo(tubes[j])) {
            selectedTubeIndex = i;
            hintCount--;
            usedHintThisLevel = true;
            await ProgressService.setHintCount(hintCount);
            notifyListeners();
            return true;
          }
        }
      }
      return false;
    }
    // No free hints left → caller should show ad dialog
    return false;
  }

  Future<void> addHintFromAd() async {
    // After watching ad, give 3 hints
    hintCount += 3;
    await ProgressService.setHintCount(hintCount);
    notifyListeners();
  }

  Future<void> addExtraTube() async {
    if (extraTubeCount <= 0 || status != GameStatus.playing) return;
    tubes.add(Tube(colors: [], capacity: currentLevel.tubeCapacity));
    extraTubeCount--;
    await ProgressService.setExtraTubeCount(extraTubeCount);
    if (hapticsEnabled) HapticFeedback.mediumImpact();
    notifyListeners();
  }

  Future<void> addExtraTubeFromAd() async {
    extraTubeCount += 2;
    await ProgressService.setExtraTubeCount(extraTubeCount);
    notifyListeners();
  }

  Future<void> addUndoFromAd() async {
    undoCount += 3;
    await ProgressService.setUndoCount(undoCount);
    notifyListeners();
  }

  void resetLevel() {
    loadLevel(currentLevel.id);
  }

  bool get hasNextLevel => currentLevel.id < LevelRepository.totalLevels;
  int get nextLevelId => currentLevel.id + 1;

  int getStarsForLevel(int id) => levelStars[id] ?? 0;
  bool isLevelUnlocked(int id) => id <= unlockedLevel;

  // Settings
  Future<void> setSound(bool value) async {
    soundEnabled = value;
    await ProgressService.setSoundEnabled(value);
    notifyListeners();
  }

  Future<void> setMusic(bool value) async {
    musicEnabled = value;
    await ProgressService.setMusicEnabled(value);
    notifyListeners();
  }

  Future<void> setHaptics(bool value) async {
    hapticsEnabled = value;
    await ProgressService.setHapticsEnabled(value);
    notifyListeners();
  }

  Future<void> resetAllProgress() async {
    await ProgressService.resetProgress();
    unlockedLevel = 1;
    levelStars = {};
    totalStars = 0;
    unlockedAchievements = {};
    hasWeeklyBadge = false;
    hintCount = 2;
    undoCount = 5;
    extraTubeCount = 2;
    gamesPlayed = 0;
    perfectLevels = 0;
    notifyListeners();
  }
}
