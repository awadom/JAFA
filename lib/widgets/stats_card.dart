import 'package:flutter/material.dart';
import '../models/user_stats.dart';

class StatsCard extends StatelessWidget {
  final UserStats stats;

  const StatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: _getLevelColor(stats.level),
                  size: 28,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stats.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Level ${stats.level}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStreakBadge(),
              ],
            ),
            const SizedBox(height: 16),
            
            // XP Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'XP: ${stats.xp}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      'Next: ${stats.xpForNextLevel}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: stats.xpProgress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(_getLevelColor(stats.level)),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.local_fire_department,
                  label: 'Streak',
                  value: '${stats.currentStreak}',
                  color: stats.currentStreak > 0 ? Colors.orange : Colors.grey,
                ),
                _buildStatItem(
                  icon: Icons.trending_up,
                  label: 'Best',
                  value: '${stats.longestStreak}',
                  color: Colors.green,
                ),
                _buildStatItem(
                  icon: Icons.fitness_center,
                  label: 'Total',
                  value: '${stats.totalWorkouts}',
                  color: Colors.blue,
                ),
              ],
            ),
            
            if (stats.currentStreak > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${stats.currentStreak} day${stats.currentStreak != 1 ? 's' : ''} streak! Keep it up!',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStreakBadge() {
    if (stats.currentStreak == 0) return const SizedBox.shrink();
    
    Color badgeColor;
    String badgeText;
    
    if (stats.currentStreak >= 30) {
      badgeColor = Colors.purple;
      badgeText = '🔥';
    } else if (stats.currentStreak >= 7) {
      badgeColor = Colors.orange;
      badgeText = '🔥';
    } else if (stats.currentStreak >= 3) {
      badgeColor = Colors.red;
      badgeText = '🔥';
    } else {
      badgeColor = Colors.orange;
      badgeText = '🔥';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$badgeText ${stats.currentStreak}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getLevelColor(int level) {
    if (level >= 50) return Colors.purple;
    if (level >= 40) return Colors.indigo;
    if (level >= 30) return Colors.blue;
    if (level >= 20) return Colors.green;
    if (level >= 10) return Colors.orange;
    if (level >= 5) return Colors.amber;
    return Colors.grey;
  }
}
