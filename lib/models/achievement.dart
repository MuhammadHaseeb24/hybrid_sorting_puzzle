class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon; // emoji or icon name
  final int target;
  final AchievementType type;
  final bool isWeekly;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.target,
    required this.type,
    this.isWeekly = false,
  });
}

enum AchievementType {
  levelsCompleted,
  threeStars,
  perfectLevels,
  totalStars,
  gamesPlayed,
  weeklyTop,
  special,
}

class AchievementRepository {
  static const List<Achievement> all = [
    Achievement(
      id: 'first_win',
      title: 'First Victory',
      description: 'Complete your first level',
      icon: '🎯',
      target: 1,
      type: AchievementType.levelsCompleted,
    ),
    Achievement(
      id: 'level_5',
      title: 'Getting Started',
      description: 'Complete 5 levels',
      icon: '🚀',
      target: 5,
      type: AchievementType.levelsCompleted,
    ),
    Achievement(
      id: 'level_10',
      title: 'Rising Star',
      description: 'Complete 10 levels',
      icon: '⭐',
      target: 10,
      type: AchievementType.levelsCompleted,
    ),
    Achievement(
      id: 'level_20',
      title: 'Puzzle Pro',
      description: 'Complete 20 levels',
      icon: '🏆',
      target: 20,
      type: AchievementType.levelsCompleted,
    ),
    Achievement(
      id: 'level_30',
      title: 'Master Sorter',
      description: 'Complete 30 levels',
      icon: '👑',
      target: 30,
      type: AchievementType.levelsCompleted,
    ),
    Achievement(
      id: 'three_star_1',
      title: 'Perfect Start',
      description: 'Get 3 stars on any level',
      icon: '✨',
      target: 1,
      type: AchievementType.threeStars,
    ),
    Achievement(
      id: 'three_star_5',
      title: 'Star Collector',
      description: 'Get 3 stars on 5 levels',
      icon: '🌟',
      target: 5,
      type: AchievementType.threeStars,
    ),
    Achievement(
      id: 'three_star_15',
      title: 'Star Hunter',
      description: 'Get 3 stars on 15 levels',
      icon: '💫',
      target: 15,
      type: AchievementType.threeStars,
    ),
    Achievement(
      id: 'perfect_3',
      title: 'Flawless',
      description: 'Complete 3 levels with 3 stars',
      icon: '💎',
      target: 3,
      type: AchievementType.perfectLevels,
    ),
    Achievement(
      id: 'total_stars_30',
      title: 'Star Power',
      description: 'Collect 30 total stars',
      icon: '🌠',
      target: 30,
      type: AchievementType.totalStars,
    ),
    Achievement(
      id: 'total_stars_60',
      title: 'Galaxy of Stars',
      description: 'Collect 60 total stars',
      icon: '🌌',
      target: 60,
      type: AchievementType.totalStars,
    ),
    Achievement(
      id: 'games_20',
      title: 'Dedicated Player',
      description: 'Play 20 games',
      icon: '🎮',
      target: 20,
      type: AchievementType.gamesPlayed,
    ),
    Achievement(
      id: 'level_50',
      title: 'Veteran',
      description: 'Complete 50 levels',
      icon: '🛡️',
      target: 50,
      type: AchievementType.levelsCompleted,
    ),
    Achievement(
      id: 'level_100',
      title: 'Century Club',
      description: 'Complete 100 levels',
      icon: '💯',
      target: 100,
      type: AchievementType.levelsCompleted,
    ),
    Achievement(
      id: 'level_200',
      title: 'Unstoppable',
      description: 'Complete 200 levels',
      icon: '🔥',
      target: 200,
      type: AchievementType.levelsCompleted,
    ),
    Achievement(
      id: 'level_300',
      title: 'Liquid Legend',
      description: 'Complete 300 levels',
      icon: '🌈',
      target: 300,
      type: AchievementType.levelsCompleted,
    ),
    Achievement(
      id: 'weekly_top',
      title: 'Top Player Badge',
      description: 'Hold the Top Player badge for 1 week',
      icon: '🥇',
      target: 1,
      type: AchievementType.weeklyTop,
      isWeekly: true,
    ),
    Achievement(
      id: 'no_hint_5',
      title: 'Self Reliant',
      description: 'Complete 5 levels without using hints',
      icon: '🧠',
      target: 5,
      type: AchievementType.special,
    ),
    Achievement(
      id: 'speed_demon',
      title: 'Speed Demon',
      description: 'Complete a level in under 10 moves',
      icon: '⚡',
      target: 1,
      type: AchievementType.special,
    ),
  ];
}
