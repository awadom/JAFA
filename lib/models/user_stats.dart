class UserStats {
  final int? id;
  final int currentStreak;
  final int longestStreak;
  final int totalWorkouts;
  final DateTime? lastWorkoutDate;
  final int level;
  final int xp;

  UserStats({
    this.id,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalWorkouts,
    this.lastWorkoutDate,
    required this.level,
    required this.xp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalWorkouts': totalWorkouts,
      'lastWorkoutDate': lastWorkoutDate?.millisecondsSinceEpoch,
      'level': level,
      'xp': xp,
    };
  }

  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      id: map['id']?.toInt(),
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      totalWorkouts: map['totalWorkouts'] ?? 0,
      lastWorkoutDate: map['lastWorkoutDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['lastWorkoutDate'])
          : null,
      level: map['level'] ?? 1,
      xp: map['xp'] ?? 0,
    );
  }

  UserStats copyWith({
    int? id,
    int? currentStreak,
    int? longestStreak,
    int? totalWorkouts,
    DateTime? lastWorkoutDate,
    int? level,
    int? xp,
  }) {
    return UserStats(
      id: id ?? this.id,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      lastWorkoutDate: lastWorkoutDate ?? this.lastWorkoutDate,
      level: level ?? this.level,
      xp: xp ?? this.xp,
    );
  }

  // Calculate XP needed for next level (exponential curve)
  int get xpForNextLevel => (level * 100) + (level * level * 25);
  
  // Calculate XP progress to next level
  double get xpProgress {
    final xpForCurrentLevel = level > 1 ? ((level - 1) * 100) + ((level - 1) * (level - 1) * 25) : 0;
    final xpNeeded = xpForNextLevel - xpForCurrentLevel;
    final currentXpInLevel = xp - xpForCurrentLevel;
    return currentXpInLevel / xpNeeded;
  }

  // Get user title based on level
  String get title {
    if (level >= 50) return "Fitness Legend";
    if (level >= 40) return "Workout Master";
    if (level >= 30) return "Fitness Expert";
    if (level >= 20) return "Gym Warrior";
    if (level >= 15) return "Dedicated Athlete";
    if (level >= 10) return "Fitness Enthusiast";
    if (level >= 5) return "Rising Star";
    return "Fitness Rookie";
  }

  // Calculate if user can level up
  bool get canLevelUp => xp >= xpForNextLevel;

  // Level up and return new stats
  UserStats levelUp() {
    if (!canLevelUp) return this;
    return copyWith(level: level + 1);
  }
}
