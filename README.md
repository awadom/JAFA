# JAFA - Just Another Fitness App 🏋️‍♂️

A gamified workout diary that motivates you to maintain daily fitness streaks with XP, levels, and achievements.

## Features 🎮

### Workout Diary
- **Photo Capture**: Take or import photos from your workout sessions
- **Workout Notes**: Write detailed notes about your exercises, sets, reps, and how you felt
- **12-Hour Time Format**: All timestamps display in North American standard format (AM/PM)
- **Persistent Storage**: All entries are saved locally using SQLite

### Gamification System
- **XP System**: Earn 50 XP for each workout entry
- **Streak Bonuses**: Get extra XP for maintaining daily workout streaks
  - +25 XP for consecutive daily workouts
  - +50 XP for 7-day streaks
  - +100 XP for 30-day streaks
- **Level Progression**: Advance through levels with exponential XP requirements
- **Dynamic Titles**: Unlock new titles as you level up:
  - Level 1-4: Fitness Rookie
  - Level 5-9: Rising Star
  - Level 10-14: Fitness Enthusiast
  - Level 15-19: Dedicated Athlete
  - Level 20-29: Gym Warrior
  - Level 30-39: Fitness Expert
  - Level 40-49: Workout Master
  - Level 50+: Fitness Legend

### Streak Tracking
- **Current Streak**: Track consecutive days of workouts
- **Longest Streak**: Remember your personal best
- **Visual Indicators**: Fire emojis and colored badges for active streaks
- **Motivational Messages**: Encouraging feedback after each workout

### Stats Dashboard
- **Progress Bar**: Visual XP progress toward next level
- **Achievement Badges**: Display current streak with fire badges
- **Total Statistics**: Track total workouts completed
- **Level-Based Colors**: Different color schemes for different achievement levels

## Getting Started 🚀

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the app
4. Start logging your workouts and watch your fitness journey unfold!

## Permissions 📱

The app requires the following permissions:
- **Camera**: To take photos of your workouts
- **Photo Library**: To import existing photos
- **Storage**: To save workout images locally

## Motivation Features 💪

- **Level Up Celebrations**: Special dialogs when you reach new levels
- **Streak Encouragement**: Visual feedback for maintaining workout consistency
- **Progress Visualization**: Clear indicators of your fitness journey
- **Achievement System**: Unlockable titles and badges
- **Daily Motivation**: Encouraging messages after each workout entry

Start your fitness journey today and build lasting habits with JAFA!
