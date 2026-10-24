import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/level_data.dart';
import '../models/achievement.dart';
import '../services/progress_service.dart';
import '../services/sound_service.dart';
import '../utils/haptics.dart';

enum GameStatus { playing, won, lost }

enum TubeBuyResult { ok, maxed, noCoins, busy }

/// A pour that is currently being animated by the board. The tubes are only
/// mutated when [GameProvider.finishPour] is called at the end of the animation.
class PourEvent {
  final int id;
  final int from;
  final int to;
  final Color color;
  final int amount;
  const PourEvent({
    required this.id,
    required this.from,
    required this.to,
    required this.color,
    required this.amount,
  });
}

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
  String loseReason = ''; // 'moves' or 'stuck'

  // Pour animation + effects
  PourEvent? pourEvent;
  int _pourSeq = 0;
  int hintFrom = -1;
  int hintTo = -1;
  int completedSeq = 0;
  int completedTube = -1;
  Color completedColor = Colors.white;

  // Boosters
  int undoCount = 5;
  int hintCount = 2;
  // Coins + extra tubes (bought with coins, max 2 per game)
  int coins = ProgressService.startCoins;
  int extraTubesThisLevel = 0;
  int lastCoinsEarned = 0;
  static const int maxExtraTubesPerLevel = 2;
  static const List<int> extraTubePrices = [50, 100];

  int get extraTubePrice =>
      extraTubePrices[math.min(extraTubesThisLevel, extraTubePrices.length - 1)];
  bool get canAddMoreTubes => extraTubesThisLevel < maxExtraTubesPerLevel;

  /// Stars if the level were finished right now (3 up to par+2, then 2, then 1).
  int get starsNow => moves <= currentLevel.stars3Moves
      ? 3
      : (moves <= currentLevel.stars2Moves ? 2 : 1);

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
  int noHintLevels = 0;

  final SoundService sound = SoundService();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    unlockedLevel = await ProgressService.getUnlockedLevel();
    levelStars = await ProgressService.getAllStars();
    totalStars = await ProgressService.getTotalStars();
    hintCount = await ProgressService.getHintCount();
    undoCount = await ProgressService.getUndoCount();
    coins = await ProgressService.getCoins();
    unlockedAchievements = await ProgressService.getUnlockedAchievements();
    hasWeeklyBadge = await ProgressService.hasActiveWeeklyBadge();
    soundEnabled = await ProgressService.getSoundEnabled();
    musicEnabled = await ProgressService.getMusicEnabled();
    hapticsEnabled = await ProgressService.getHapticsEnabled();
    gamesPlayed = await ProgressService.getGamesPlayed();
    perfectLevels = await ProgressService.getPerfectLevels();
    noHintLevels = await ProgressService.getNoHintLevels();
    Haptics.enabled = hapticsEnabled;

    await sound.init();
    sound.setSoundEnabled(soundEnabled);
    sound.setMusicEnabled(musicEnabled);

    if (musicEnabled) {
      await sound.playBackgroundMusic();
    }

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
    pourEvent = null;
    hintFrom = -1;
    hintTo = -1;
    usedHintThisLevel = false;
    extraTubesThisLevel = 0;
    lastCoinsEarned = 0;
    loseReason = '';
    notifyListeners();
  }

  void _clearHint() {
    hintFrom = -1;
    hintTo = -1;
  }

  void selectTube(int index) {
    if (status != GameStatus.playing || isAnimating) return;
    if (index < 0 || index >= tubes.length) return;
    _clearHint();
    Haptics.tap();

    if (selectedTubeIndex == -1) {
      if (!tubes[index].isEmpty) {
        selectedTubeIndex = index;
        sound.playSelect();
      }
      notifyListeners();
    } else if (selectedTubeIndex == index) {
      selectedTubeIndex = -1;
      sound.playClick();
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
      if (selectedTubeIndex != -1) sound.playSelect();
      notifyListeners();
      return;
    }

    // Start the animation; tubes change in finishPour().
    pourEvent = PourEvent(
      id: ++_pourSeq,
      from: from,
      to: to,
      color: source.topColor!,
      amount: source.pourAmountTo(dest),
    );
    isAnimating = true;
    selectedTubeIndex = -1;
    sound.playPour();
    Haptics.light();
    notifyListeners();
  }

  /// Called by the board when the pour animation ends.
  void finishPour() {
    final e = pourEvent;
    if (e == null) return;
    final source = tubes[e.from];
    final dest = tubes[e.to];

    _saveHistory();
    for (int i = 0; i < e.amount; i++) {
      source.colors.removeLast();
      dest.colors.add(e.color);
    }
    final starsBefore = starsNow;
    moves++;
    pourEvent = null;
    isAnimating = false;
    if (starsNow < starsBefore) Haptics.heavy(); // lost a star

    final tubeDone = !dest.isEmpty && dest.isSorted;
    if (tubeDone) {
      completedTube = e.to;
      completedColor = e.color;
      completedSeq++;
      Haptics.medium();
    }

    if (_checkWin()) {
      status = GameStatus.won;
      _calculateStars();
      sound.playWin();
      Haptics.win();
      _onLevelComplete();
    } else if (moves >= currentLevel.maxMoves) {
      status = GameStatus.lost;
      loseReason = 'moves';
      sound.playLose();
      Haptics.lose();
    } else if (_isStuck()) {
      status = GameStatus.lost;
      loseReason = 'stuck';
      sound.playLose();
      Haptics.lose();
    } else if (tubeDone) {
      sound.playStar();
    }

    notifyListeners();
  }

  /// True if at least one legal pour exists on the board.
  bool get hasAnyMove {
    for (int i = 0; i < tubes.length; i++) {
      for (int j = 0; j < tubes.length; j++) {
        if (i != j && tubes[i].canPourTo(tubes[j])) return true;
      }
    }
    return false;
  }

  /// Stuck = no legal move AND no undo left AND no more tubes can be added.
  bool _isStuck() {
    if (hasAnyMove) return false;
    final canUndo = undoCount > 0 && history.isNotEmpty;
    return !canAddMoreTubes && !canUndo;
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
    // coins (computed synchronously so the win dialog can show them)
    final firstClear = !levelStars.containsKey(currentLevel.id);
    lastCoinsEarned = firstClear ? 20 + 10 * starsEarned : 5 + 3 * starsEarned;
    coins += lastCoinsEarned;
    ProgressService.setCoins(coins);

    await ProgressService.incrementGamesPlayed();
    gamesPlayed++;
    await ProgressService.addMoves(moves);

    await ProgressService.saveStars(currentLevel.id, starsEarned);
    final prev = levelStars[currentLevel.id] ?? 0;
    levelStars[currentLevel.id] = starsEarned > prev ? starsEarned : prev;
    totalStars = levelStars.values.fold(0, (a, b) => a + b);

    if (starsEarned == 3) {
      await ProgressService.incrementPerfectLevels();
      perfectLevels++;
      sound.playStar();
    }

    if (!usedHintThisLevel) {
      await ProgressService.incrementNoHintLevels();
      noHintLevels++;
    }

    final nextId = currentLevel.id + 1;
    if (nextId > unlockedLevel && nextId <= LevelRepository.totalLevels) {
      unlockedLevel = nextId;
      await ProgressService.setUnlockedLevel(nextId);
    }

    await _checkAchievements();

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
    final threeStarCount = levelStars.values.where((s) => s == 3).length;

    final checks = <String, bool>{
      'first_win': completedLevels >= 1,
      'level_5': completedLevels >= 5,
      'level_10': completedLevels >= 10,
      'level_20': completedLevels >= 20,
      'level_30': completedLevels >= 30,
      'level_50': completedLevels >= 50,
      'level_100': completedLevels >= 100,
      'level_200': completedLevels >= 200,
      'level_300': completedLevels >= 300,
      'three_star_1': threeStarCount >= 1,
      'three_star_5': threeStarCount >= 5,
      'three_star_15': threeStarCount >= 15,
      'perfect_3': perfectLevels >= 3,
      'total_stars_30': totalStars >= 30,
      'total_stars_60': totalStars >= 60,
      'games_20': gamesPlayed >= 20,
      'no_hint_5': noHintLevels >= 5,
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
    if (undoCount <= 0 ||
        history.isEmpty ||
        status != GameStatus.playing ||
        isAnimating) {
      return;
    }
    tubes = history.removeLast();
    moves = moves > 0 ? moves - 1 : 0;
    selectedTubeIndex = -1;
    _clearHint();
    undoCount--;
    await ProgressService.setUndoCount(undoCount);
    sound.playClick();
    Haptics.medium();
    notifyListeners();
  }

  /// Picks a useful move: prefers merging onto the same colour, finishing
  /// tubes, and avoids pointless "uniform tube -> empty tube" moves.
  List<int>? _bestMove() {
    int bestScore = -1 << 30;
    List<int>? best;
    List<int>? anyLegal;
    for (int i = 0; i < tubes.length; i++) {
      for (int j = 0; j < tubes.length; j++) {
        if (i == j || !tubes[i].canPourTo(tubes[j])) continue;
        anyLegal ??= [i, j];
        final src = tubes[i];
        final dst = tubes[j];
        final uniform = src.colors.every((c) => c == src.colors.first);
        if (uniform && dst.isEmpty) continue;
        final amt = src.pourAmountTo(dst);
        var score = amt;
        if (!dst.isEmpty) score += 10;
        if (amt == src.colors.length) score += 5;
        if (dst.colors.length + amt == dst.capacity &&
            dst.colors.every((c) => c == dst.colors.first)) {
          score += 8;
        }
        if (score > bestScore) {
          bestScore = score;
          best = [i, j];
        }
      }
    }
    return best ?? anyLegal;
  }

  Future<bool> useHint() async {
    if (status != GameStatus.playing || isAnimating) return false;
    if (hintCount <= 0) return false;
    final move = _bestMove();
    if (move == null) return false;
    selectedTubeIndex = -1;
    hintFrom = move[0];
    hintTo = move[1];
    hintCount--;
    usedHintThisLevel = true;
    await ProgressService.setHintCount(hintCount);
    sound.playClick();
    Haptics.light();
    notifyListeners();
    return true;
  }

  Future<void> addHintFromAd() async {
    hintCount += 3;
    await ProgressService.setHintCount(hintCount);
    sound.playClick();
    notifyListeners();
  }

  /// Buy one extra empty tube with coins (max 2 per game).
  TubeBuyResult buyExtraTube() {
    if (status != GameStatus.playing || isAnimating) return TubeBuyResult.busy;
    if (!canAddMoreTubes) return TubeBuyResult.maxed;
    final price = extraTubePrice;
    if (coins < price) return TubeBuyResult.noCoins;
    coins -= price;
    extraTubesThisLevel++;
    tubes.add(Tube(colors: [], capacity: currentLevel.tubeCapacity));
    _clearHint();
    ProgressService.setCoins(coins);
    sound.playClick();
    Haptics.medium();
    notifyListeners();
    return TubeBuyResult.ok;
  }

  Future<void> addCoinsFromAd([int amount = 50]) async {
    coins += amount;
    await ProgressService.setCoins(coins);
    sound.playStar();
    Haptics.light();
    notifyListeners();
  }

  Future<void> addUndoFromAd() async {
    undoCount += 3;
    await ProgressService.setUndoCount(undoCount);
    sound.playClick();
    notifyListeners();
  }

  /// Restart the current level from the very beginning.
  void resetLevel() {
    sound.playClick();
    loadLevel(currentLevel.id);
  }

  bool get hasNextLevel => currentLevel.id < LevelRepository.totalLevels;
  int get nextLevelId => currentLevel.id + 1;

  int getStarsForLevel(int id) => levelStars[id] ?? 0;
  bool isLevelUnlocked(int id) => id <= unlockedLevel;

  Future<void> setSound(bool value) async {
    soundEnabled = value;
    sound.setSoundEnabled(value);
    await ProgressService.setSoundEnabled(value);
    notifyListeners();
  }

  Future<void> setMusic(bool value) async {
    musicEnabled = value;
    sound.setMusicEnabled(value);
    await ProgressService.setMusicEnabled(value);
    notifyListeners();
  }

  Future<void> setHaptics(bool value) async {
    hapticsEnabled = value;
    Haptics.enabled = value;
    await ProgressService.setHapticsEnabled(value);
    if (value) Haptics.medium();
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
    coins = ProgressService.startCoins;
    extraTubesThisLevel = 0;
    gamesPlayed = 0;
    perfectLevels = 0;
    noHintLevels = 0;
    notifyListeners();
  }
}
