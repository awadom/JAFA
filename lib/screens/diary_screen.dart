import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/diary_entry.dart';
import '../models/user_stats.dart';
import '../database/database_helper.dart';
import '../widgets/stats_card.dart';
import 'add_edit_diary_entry_screen.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<DiaryEntry> _diaryEntries = [];
  UserStats? _userStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final entries = await _dbHelper.getAllDiaryEntries();
      final stats = await _dbHelper.getUserStats();
      setState(() {
        _diaryEntries = entries;
        _userStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        // Provide default stats if there's an error
        _userStats = UserStats(
          id: 1,
          currentStreak: 0,
          longestStreak: 0,
          totalWorkouts: 0,
          level: 1,
          xp: 0,
        );
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _loadDiaryEntries() async {
    _loadData(); // Load both entries and stats
  }

  Future<void> _deleteDiaryEntry(DiaryEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this diary entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && entry.id != null) {
      try {
        await _dbHelper.deleteDiaryEntry(entry.id!);
        // Delete the image file if it exists
        if (entry.imagePath != null) {
          final file = File(entry.imagePath!);
          if (await file.exists()) {
            await file.delete();
          }
        }
        _loadDiaryEntries();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Diary entry deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting entry: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Diary'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Temporary debug button to recalculate stats
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                await _dbHelper.recalculateStats();
                await _loadData();
                if (mounted) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Stats recalculated!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Stats Card
                if (_userStats != null) StatsCard(stats: _userStats!),
                
                // Diary Entries
                Expanded(
                  child: _diaryEntries.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.book_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No diary entries yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap the + button to add your first workout entry',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _diaryEntries.length,
                          itemBuilder: (context, index) {
                            final entry = _diaryEntries[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddEditDiaryEntryScreen(
                                        entry: entry,
                                      ),
                                    ),
                                  );
                                  if (result == true) {
                                    _loadDiaryEntries();
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              entry.title,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline),
                                            onPressed: () => _deleteDiaryEntry(entry),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        DateFormat('M/d/yyyy - h:mm a').format(entry.date),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      if (entry.imagePath != null) ...[
                                        const SizedBox(height: 12),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.file(
                                            File(entry.imagePath!),
                                            height: 150,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                height: 150,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.broken_image,
                                                    size: 48,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 12),
                                      Text(
                                        entry.notes,
                                        style: const TextStyle(fontSize: 16),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final navigator = Navigator.of(context);
          final messenger = ScaffoldMessenger.of(context);
          
          final result = await navigator.push(
            MaterialPageRoute(
              builder: (context) => const AddEditDiaryEntryScreen(),
            ),
          );
          if (result == true) {
            await _loadDiaryEntries();
            
            // Check for level up (temporarily disabled to avoid async context issues)
            // if (previousStats != null && _userStats != null && _userStats!.level > previousStats.level && mounted) {
            //   if (mounted) {
            //     await LevelUpDialog.show(currentContext, _userStats!, previousStats.level);
            //   }
            // }
            
            // Show motivational message for new workout
            if (mounted) {
              final messages = [
                'Great workout! Keep building that streak! 🔥',
                'You\'re crushing it! Another day, another victory! 💪',
                'Consistency is key! You\'re doing amazing! ⭐',
                'Your future self will thank you! 🚀',
                'Progress over perfection! Well done! 🎯',
              ];
              final message = messages[DateTime.now().millisecond % messages.length];
              
              messenger.showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Workout'),
      ),
    );
  }
}
