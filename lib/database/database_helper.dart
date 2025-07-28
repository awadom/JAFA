import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/diary_entry.dart';
import '../models/user_stats.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'jafa_diary.db');

    return await openDatabase(
      path,
      version: 2, // Increment version to trigger onUpgrade
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add user_stats table if it doesn't exist
      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_stats(
          id INTEGER PRIMARY KEY,
          currentStreak INTEGER NOT NULL DEFAULT 0,
          longestStreak INTEGER NOT NULL DEFAULT 0,
          totalWorkouts INTEGER NOT NULL DEFAULT 0,
          lastWorkoutDate INTEGER,
          level INTEGER NOT NULL DEFAULT 1,
          xp INTEGER NOT NULL DEFAULT 0
        )
      ''');

      // Insert initial user stats if table is empty
      final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM user_stats'));
      if (count == 0) {
        await db.insert('user_stats', {
          'id': 1,
          'currentStreak': 0,
          'longestStreak': 0,
          'totalWorkouts': 0,
          'lastWorkoutDate': null,
          'level': 1,
          'xp': 0,
        });
      }
    }
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE diary_entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        notes TEXT NOT NULL,
        imagePath TEXT,
        date INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE user_stats(
        id INTEGER PRIMARY KEY,
        currentStreak INTEGER NOT NULL DEFAULT 0,
        longestStreak INTEGER NOT NULL DEFAULT 0,
        totalWorkouts INTEGER NOT NULL DEFAULT 0,
        lastWorkoutDate INTEGER,
        level INTEGER NOT NULL DEFAULT 1,
        xp INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Insert initial user stats
    await db.insert('user_stats', {
      'id': 1,
      'currentStreak': 0,
      'longestStreak': 0,
      'totalWorkouts': 0,
      'lastWorkoutDate': null,
      'level': 1,
      'xp': 0,
    });
  }

  Future<int> insertDiaryEntry(DiaryEntry entry) async {
    final db = await database;
    final result = await db.insert('diary_entries', entry.toMap());
    
    // Update user stats after adding entry
    await _updateUserStatsAfterWorkout(entry.date);
    
    return result;
  }

  Future<UserStats> getUserStats() async {
    final db = await database;
    
    try {
      // Check if user_stats table exists
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='user_stats'"
      );
      
      if (tables.isEmpty) {
        // Table doesn't exist, create it
        await _upgradeDatabase(db, 1, 2);
      }
      
      final List<Map<String, dynamic>> maps = await db.query(
        'user_stats',
        where: 'id = ?',
        whereArgs: [1],
      );

      if (maps.isNotEmpty) {
        return UserStats.fromMap(maps.first);
      }
      
      // If no stats exist, create default stats
      await db.insert('user_stats', {
        'id': 1,
        'currentStreak': 0,
        'longestStreak': 0,
        'totalWorkouts': 0,
        'lastWorkoutDate': null,
        'level': 1,
        'xp': 0,
      });
      
      return UserStats(
        id: 1,
        currentStreak: 0,
        longestStreak: 0,
        totalWorkouts: 0,
        level: 1,
        xp: 0,
      );
    } catch (e) {
      // If there's any error, return default stats
      return UserStats(
        id: 1,
        currentStreak: 0,
        longestStreak: 0,
        totalWorkouts: 0,
        level: 1,
        xp: 0,
      );
    }
  }

  Future<void> _updateUserStatsAfterWorkout(DateTime workoutDate) async {
    final db = await database;
    final currentStats = await getUserStats();
    
    final workoutDay = DateTime(workoutDate.year, workoutDate.month, workoutDate.day);
    
    int newCurrentStreak = currentStats.currentStreak;
    int newXp = currentStats.xp + 50; // Base XP for workout
    
    // Check if this is a new day workout
    bool isNewDayWorkout = true;
    if (currentStats.lastWorkoutDate != null) {
      final lastWorkoutDay = DateTime(
        currentStats.lastWorkoutDate!.year,
        currentStats.lastWorkoutDate!.month,
        currentStats.lastWorkoutDate!.day,
      );
      isNewDayWorkout = !workoutDay.isAtSameMomentAs(lastWorkoutDay);
    }
    
    if (isNewDayWorkout) {
      // Calculate streak
      if (currentStats.lastWorkoutDate == null) {
        // First workout ever
        newCurrentStreak = 1;
      } else {
        final lastWorkoutDay = DateTime(
          currentStats.lastWorkoutDate!.year,
          currentStats.lastWorkoutDate!.month,
          currentStats.lastWorkoutDate!.day,
        );
        final daysDifference = workoutDay.difference(lastWorkoutDay).inDays;
        
        if (daysDifference == 1) {
          // Consecutive day
          newCurrentStreak = currentStats.currentStreak + 1;
          newXp += 25; // Bonus XP for streak
        } else if (daysDifference == 0) {
          // Same day - don't change streak but don't break it
          newCurrentStreak = currentStats.currentStreak;
        } else {
          // Streak broken
          newCurrentStreak = 1;
        }
      }
    }
    
    final newLongestStreak = newCurrentStreak > currentStats.longestStreak 
        ? newCurrentStreak 
        : currentStats.longestStreak;
    
    // Streak bonuses
    if (newCurrentStreak >= 7) newXp += 50; // Weekly streak bonus
    if (newCurrentStreak >= 30) newXp += 100; // Monthly streak bonus
    
    var updatedStats = currentStats.copyWith(
      currentStreak: newCurrentStreak,
      longestStreak: newLongestStreak,
      totalWorkouts: currentStats.totalWorkouts + 1,
      lastWorkoutDate: workoutDate,
      xp: newXp,
    );
    
    // Check for level up
    while (updatedStats.canLevelUp) {
      updatedStats = updatedStats.levelUp();
    }
    
    await db.update(
      'user_stats',
      updatedStats.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<List<DiaryEntry>> getAllDiaryEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'diary_entries',
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return DiaryEntry.fromMap(maps[i]);
    });
  }

  Future<DiaryEntry?> getDiaryEntry(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'diary_entries',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return DiaryEntry.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateDiaryEntry(DiaryEntry entry) async {
    final db = await database;
    return await db.update(
      'diary_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteDiaryEntry(int id) async {
    final db = await database;
    return await db.delete(
      'diary_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }

  // Method to reset the database (useful for development/debugging)
  Future<void> resetDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'jafa_diary.db');
    
    // Close existing connection
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    
    // Delete the database file
    await deleteDatabase(path);
    
    // Reinitialize
    _database = await _initDatabase();
  }
}
