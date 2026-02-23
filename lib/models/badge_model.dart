/// Badge Model - Gamification System
/// Tracks achievements and badges for user engagement

import 'package:hive/hive.dart';

part 'badge_model.g.dart';

/// Badge categories
enum BadgeCategory {
  fasting,
  prayer,
  tasbih,
  qibla,
  streak,
  special,
}

/// Badge rarity levels
enum BadgeRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
}

/// Badge model for gamification
@HiveType(typeId: 6)
class BadgeModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String nameBn;
  
  @HiveField(3)
  final String description;
  
  @HiveField(4)
  final String descriptionBn;
  
  @HiveField(5)
  final String iconName;
  
  @HiveField(6)
  final String category;
  
  @HiveField(7)
  final String rarity;
  
  @HiveField(8)
  final int requirement;
  
  @HiveField(9)
  final String requirementType;
  
  @HiveField(10)
  bool isUnlocked;
  
  @HiveField(11)
  DateTime? unlockedAt;
  
  @HiveField(12)
  final int points;

  BadgeModel({
    required this.id,
    required this.name,
    required this.nameBn,
    required this.description,
    required this.descriptionBn,
    required this.iconName,
    required this.category,
    required this.rarity,
    required this.requirement,
    required this.requirementType,
    this.isUnlocked = false,
    this.unlockedAt,
    required this.points,
  });

  /// Unlock the badge
  void unlock() {
    if (!isUnlocked) {
      isUnlocked = true;
      unlockedAt = DateTime.now();
    }
  }

  /// Get rarity color
  String get rarityColor {
    switch (rarity) {
      case 'legendary':
        return '#FFD700'; // Gold
      case 'epic':
        return '#FF6B9D'; // Pink
      case 'rare':
        return '#00E5C0'; // Teal
      case 'uncommon':
        return '#4ECDC4'; // Light teal
      default:
        return '#9CA3AF'; // Gray
    }
  }

  /// Get category icon
  String get categoryIcon {
    switch (category) {
      case 'fasting':
        return '🌙';
      case 'prayer':
        return '🕌';
      case 'tasbih':
        return '📿';
      case 'qibla':
        return '🧭';
      case 'streak':
        return '🔥';
      case 'special':
        return '✨';
      default:
        return '🏆';
    }
  }

  @override
  String toString() {
    return 'BadgeModel(name: $name, unlocked: $isUnlocked)';
  }
}

/// All available badges
class AllBadges {
  static List<BadgeModel> get all => [
    // Fasting Badges
    BadgeModel(
      id: 'fasting_1',
      name: 'First Fast',
      nameBn: 'প্রথম রোজা',
      description: 'Complete your first fast of Ramadan',
      descriptionBn: 'রমজানের প্রথম রোজা সম্পন্ন করুন',
      iconName: 'moon_1',
      category: 'fasting',
      rarity: 'common',
      requirement: 1,
      requirementType: 'fast_days',
      points: 10,
    ),
    BadgeModel(
      id: 'fasting_7',
      name: 'Week Warrior',
      nameBn: 'সপ্তাহের যোদ্ধা',
      description: 'Fast for 7 consecutive days',
      descriptionBn: '৭ দিন ধারাবাহিকভাবে রোজা রাখুন',
      iconName: 'moon_7',
      category: 'fasting',
      rarity: 'uncommon',
      requirement: 7,
      requirementType: 'consecutive_fast_days',
      points: 50,
    ),
    BadgeModel(
      id: 'fasting_15',
      name: 'Halfway Hero',
      nameBn: 'অর্ধেক নায়ক',
      description: 'Complete 15 days of fasting',
      descriptionBn: '১৫ দিন রোজা সম্পন্ন করুন',
      iconName: 'moon_15',
      category: 'fasting',
      rarity: 'rare',
      requirement: 15,
      requirementType: 'fast_days',
      points: 100,
    ),
    BadgeModel(
      id: 'fasting_30',
      name: 'Ramadan Champion',
      nameBn: 'রমজান চ্যাম্পিয়ন',
      description: 'Complete the entire month of Ramadan',
      descriptionBn: 'পুরো রমজান মাস রোজা রাখুন',
      iconName: 'moon_30',
      category: 'fasting',
      rarity: 'legendary',
      requirement: 30,
      requirementType: 'fast_days',
      points: 500,
    ),
    
    // Prayer Badges
    BadgeModel(
      id: 'prayer_1',
      name: 'First Prayer',
      nameBn: 'প্রথম নামাজ',
      description: 'Track your first prayer',
      descriptionBn: 'আপনার প্রথম নামাজ ট্র্যাক করুন',
      iconName: 'prayer_1',
      category: 'prayer',
      rarity: 'common',
      requirement: 1,
      requirementType: 'prayers_tracked',
      points: 10,
    ),
    BadgeModel(
      id: 'prayer_5',
      name: 'Daily Devotee',
      nameBn: 'দৈনিক ভক্ত',
      description: 'Complete all 5 daily prayers',
      descriptionBn: 'দৈনিক ৫ ওয়াক্ত নামাজ আদায় করুন',
      iconName: 'prayer_5',
      category: 'prayer',
      rarity: 'uncommon',
      requirement: 5,
      requirementType: 'prayers_in_day',
      points: 30,
    ),
    BadgeModel(
      id: 'prayer_100',
      name: 'Century of Prayers',
      nameBn: 'শত নামাজ',
      description: 'Track 100 prayers',
      descriptionBn: '১০০টি নামাজ ট্র্যাক করুন',
      iconName: 'prayer_100',
      category: 'prayer',
      rarity: 'rare',
      requirement: 100,
      requirementType: 'prayers_tracked',
      points: 150,
    ),
    
    // Tasbih Badges
    BadgeModel(
      id: 'tasbih_33',
      name: 'Dhikr Beginner',
      nameBn: 'জিকির শিক্ষার্থী',
      description: 'Complete 33 dhikr in one session',
      descriptionBn: 'এক অধিবেশনে ৩৩ জিকির সম্পন্ন করুন',
      iconName: 'tasbih_33',
      category: 'tasbih',
      rarity: 'common',
      requirement: 33,
      requirementType: 'tasbih_count',
      points: 15,
    ),
    BadgeModel(
      id: 'tasbih_100',
      name: 'Dhikr Devotee',
      nameBn: 'জিকির ভক্ত',
      description: 'Complete 100 dhikr in one session',
      descriptionBn: 'এক অধিবেশনে ১০০ জিকির সম্পন্ন করুন',
      iconName: 'tasbih_100',
      category: 'tasbih',
      rarity: 'uncommon',
      requirement: 100,
      requirementType: 'tasbih_count',
      points: 40,
    ),
    BadgeModel(
      id: 'tasbih_1000',
      name: 'Dhikr Master',
      nameBn: 'জিকির মাস্টার',
      description: 'Complete 1000 dhikr in one day',
      descriptionBn: 'একদিনে ১০০০ জিকির সম্পন্ন করুন',
      iconName: 'tasbih_1000',
      category: 'tasbih',
      rarity: 'rare',
      requirement: 1000,
      requirementType: 'tasbih_daily',
      points: 100,
    ),
    BadgeModel(
      id: 'tasbih_all',
      name: 'Dhikr Collector',
      nameBn: 'জিকির সংগ্রাহক',
      description: 'Use all 15+ dhikr types',
      descriptionBn: 'সব ১৫+ জিকির প্রকার ব্যবহার করুন',
      iconName: 'tasbih_all',
      category: 'tasbih',
      rarity: 'epic',
      requirement: 15,
      requirementType: 'dhikr_types_used',
      points: 200,
    ),
    
    // Streak Badges
    BadgeModel(
      id: 'streak_3',
      name: '3-Day Streak',
      nameBn: '৩-দিনের ধারাবাহিকতা',
      description: 'Maintain a 3-day fasting streak',
      descriptionBn: '৩ দিনের রোজা ধারাবাহিকতা বজায় রাখুন',
      iconName: 'streak_3',
      category: 'streak',
      rarity: 'common',
      requirement: 3,
      requirementType: 'fasting_streak',
      points: 20,
    ),
    BadgeModel(
      id: 'streak_7',
      name: 'Week Streak',
      nameBn: 'সপ্তাহের ধারাবাহিকতা',
      description: 'Maintain a 7-day fasting streak',
      descriptionBn: '৭ দিনের রোজা ধারাবাহিকতা বজায় রাখুন',
      iconName: 'streak_7',
      category: 'streak',
      rarity: 'uncommon',
      requirement: 7,
      requirementType: 'fasting_streak',
      points: 50,
    ),
    BadgeModel(
      id: 'streak_14',
      name: 'Fortnight Flame',
      nameBn: 'পক্ষকালের আগুন',
      description: 'Maintain a 14-day fasting streak',
      descriptionBn: '১৪ দিনের রোজা ধারাবাহিকতা বজায় রাখুন',
      iconName: 'streak_14',
      category: 'streak',
      rarity: 'rare',
      requirement: 14,
      requirementType: 'fasting_streak',
      points: 100,
    ),
    BadgeModel(
      id: 'streak_30',
      name: 'Unstoppable',
      nameBn: 'অপ্রতিরোধ্য',
      description: 'Maintain a 30-day fasting streak',
      descriptionBn: '৩০ দিনের রোজা ধারাবাহিকতা বজায় রাখুন',
      iconName: 'streak_30',
      category: 'streak',
      rarity: 'legendary',
      requirement: 30,
      requirementType: 'fasting_streak',
      points: 1000,
    ),
    
    // Qibla Badges
    BadgeModel(
      id: 'qibla_1',
      name: 'First Direction',
      nameBn: 'প্রথম দিকনির্ণয়',
      description: 'Find Qibla for the first time',
      descriptionBn: 'প্রথমবার কিবলা খুঁজুন',
      iconName: 'qibla_1',
      category: 'qibla',
      rarity: 'common',
      requirement: 1,
      requirementType: 'qibla_found',
      points: 10,
    ),
    BadgeModel(
      id: 'qibla_10',
      name: 'Direction Master',
      nameBn: 'দিকনির্ণয় মাস্টার',
      description: 'Find Qibla 10 times',
      descriptionBn: '১০ বার কিবলা খুঁজুন',
      iconName: 'qibla_10',
      category: 'qibla',
      rarity: 'uncommon',
      requirement: 10,
      requirementType: 'qibla_found',
      points: 30,
    ),
    
    // Special Badges
    BadgeModel(
      id: 'special_laylatul',
      name: 'Night of Power',
      nameBn: 'লাইলাতুল কদর',
      description: 'Pray on Laylatul Qadr',
      descriptionBn: 'লাইলাতুল কদরে নামাজ আদায় করুন',
      iconName: 'laylatul',
      category: 'special',
      rarity: 'legendary',
      requirement: 1,
      requirementType: 'laylatul_qadr',
      points: 1000,
    ),
    BadgeModel(
      id: 'special_jumuah',
      name: 'Jumuah Mubarak',
      nameBn: 'জুমুআহ মুবারক',
      description: 'Complete Jumuah prayer during Ramadan',
      descriptionBn: 'রমজানে জুমুআহ নামাজ আদায় করুন',
      iconName: 'jumuah',
      category: 'special',
      rarity: 'rare',
      requirement: 1,
      requirementType: 'jumuah_ramadan',
      points: 50,
    ),
    BadgeModel(
      id: 'special_early',
      name: 'Early Bird',
      nameBn: 'ভোরের পাখি',
      description: 'Use the app before Fajr for 7 days',
      descriptionBn: '৭ দিন ফজরের আগে অ্যাপ ব্যবহার করুন',
      iconName: 'early',
      category: 'special',
      rarity: 'uncommon',
      requirement: 7,
      requirementType: 'early_usage',
      points: 40,
    ),
    BadgeModel(
      id: 'special_share',
      name: 'Spread the Blessing',
      nameBn: 'বরকত ছড়ান',
      description: 'Share your progress with friends',
      descriptionBn: 'আপনার অগ্রগতি বন্ধুদের সাথে শেয়ার করুন',
      iconName: 'share',
      category: 'special',
      rarity: 'common',
      requirement: 1,
      requirementType: 'share_progress',
      points: 20,
    ),
  ];

  /// Get badge by ID
  static BadgeModel? getById(String id) {
    try {
      return all.firstWhere((badge) => badge.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get badges by category
  static List<BadgeModel> getByCategory(String category) {
    return all.where((badge) => badge.category == category).toList();
  }

  /// Get unlocked badges
  static List<BadgeModel> getUnlocked(List<String> unlockedIds) {
    return all.where((badge) => unlockedIds.contains(badge.id)).toList();
  }

  /// Get locked badges
  static List<BadgeModel> getLocked(List<String> unlockedIds) {
    return all.where((badge) => !unlockedIds.contains(badge.id)).toList();
  }

  /// Calculate total points
  static int calculateTotalPoints(List<String> unlockedIds) {
    return getUnlocked(unlockedIds).fold(0, (sum, badge) => sum + badge.points);
  }
}

/// User progress tracking
class UserProgress {
  final int totalPoints;
  final int unlockedBadgesCount;
  final int totalBadgesCount;
  final List<BadgeModel> unlockedBadges;
  final List<BadgeModel> lockedBadges;
  final Map<String, int> categoryProgress;

  UserProgress({
    required this.totalPoints,
    required this.unlockedBadgesCount,
    required this.totalBadgesCount,
    required this.unlockedBadges,
    required this.lockedBadges,
    required this.categoryProgress,
  });

  /// Calculate progress percentage
  double get progressPercentage {
    return (unlockedBadgesCount / totalBadgesCount * 100);
  }

  /// Get next badge to unlock
  BadgeModel? getNextBadge() {
    if (lockedBadges.isEmpty) return null;
    
    // Sort by rarity and requirement
    final sorted = lockedBadges.toList()
      ..sort((a, b) {
        final rarityOrder = {
          'common': 0,
          'uncommon': 1,
          'rare': 2,
          'epic': 3,
          'legendary': 4,
        };
        return rarityOrder[a.rarity]!.compareTo(rarityOrder[b.rarity]!);
      });
    
    return sorted.first;
  }
}
