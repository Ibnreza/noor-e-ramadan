/// Badge/Gamification Provider
/// Manages badges, achievements, and user progress using Riverpod

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/badge_model.dart';
import '../models/user_settings_model.dart';
import 'settings_provider.dart';

final Object _unset = Object();

/// Badge state
class BadgeState {
  final List<BadgeModel> allBadges;
  final List<String> unlockedIds;
  final bool isLoading;
  final String? error;
  final BadgeModel? newlyUnlocked;

  BadgeState({
    this.allBadges = const [],
    this.unlockedIds = const [],
    this.isLoading = false,
    this.error,
    this.newlyUnlocked,
  });

  BadgeState copyWith({
    List<BadgeModel>? allBadges,
    List<String>? unlockedIds,
    bool? isLoading,
    Object? error = _unset,
    Object? newlyUnlocked = _unset,
  }) {
    return BadgeState(
      allBadges: allBadges ?? this.allBadges,
      unlockedIds: unlockedIds ?? this.unlockedIds,
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _unset) ? this.error : error as String?,
      newlyUnlocked: identical(newlyUnlocked, _unset)
          ? this.newlyUnlocked
          : newlyUnlocked as BadgeModel?,
    );
  }

  /// Get unlocked badges
  List<BadgeModel> get unlockedBadges {
    return allBadges.where((badge) => unlockedIds.contains(badge.id)).toList();
  }

  /// Get locked badges
  List<BadgeModel> get lockedBadges {
    return allBadges.where((badge) => !unlockedIds.contains(badge.id)).toList();
  }

  /// Get total points
  int get totalPoints {
    return unlockedBadges.fold(0, (sum, badge) => sum + badge.points);
  }

  /// Get progress percentage
  double get progressPercentage {
    if (allBadges.isEmpty) return 0.0;
    return unlockedIds.length / allBadges.length;
  }

  /// Get badges by category
  List<BadgeModel> getBadgesByCategory(String category) {
    return allBadges.where((badge) => badge.category == category).toList();
  }

  /// Get unlocked count for category
  int getUnlockedCountForCategory(String category) {
    return unlockedBadges.where((badge) => badge.category == category).length;
  }

  /// Get total count for category
  int getTotalCountForCategory(String category) {
    return allBadges.where((badge) => badge.category == category).length;
  }

  /// Check if badge is unlocked
  bool isUnlocked(String badgeId) {
    return unlockedIds.contains(badgeId);
  }

  /// Get recently unlocked badges
  List<BadgeModel> get recentlyUnlocked {
    final sorted = unlockedBadges.toList()
      ..sort((a, b) {
        if (a.unlockedAt == null || b.unlockedAt == null) return 0;
        return b.unlockedAt!.compareTo(a.unlockedAt!);
      });
    return sorted.take(5).toList();
  }

  /// Get next badge to unlock
  BadgeModel? get nextBadge {
    if (lockedBadges.isEmpty) return null;
    
    // Sort by rarity
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

/// Badge notifier
class BadgeNotifier extends StateNotifier<BadgeState> {
  final Ref _ref;
  final Box<BadgeModel> _badgeBox;
  final Box _metadataBox;

  BadgeNotifier(this._ref, this._badgeBox, this._metadataBox) : super(BadgeState()) {
    _initialize();
  }

  /// Initialize badges
  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      // Initialize badges if needed
      if (_badgeBox.isEmpty) {
        for (final badge in AllBadges.all) {
          await _badgeBox.put(badge.id, badge);
        }
      }

      // Load unlocked IDs
      final unlockedIds = _getUnlockedIds();

      state = state.copyWith(
        allBadges: _badgeBox.values.toList(),
        unlockedIds: unlockedIds,
        isLoading: false,
      );

      // Check for automatic unlocks based on current stats
      await _checkAutomaticUnlocks();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load badges: $e',
      );
    }
  }

  /// Get unlocked IDs from metadata box
  List<String> _getUnlockedIds() {
    final ids = _metadataBox.get('unlocked_badge_ids');
    if (ids == null) return [];
    return List<String>.from(ids);
  }

  /// Save unlocked IDs
  Future<void> _saveUnlockedIds(List<String> ids) async {
    await _metadataBox.put('unlocked_badge_ids', ids);
  }

  /// Unlock a badge
  Future<bool> unlockBadge(String badgeId) async {
    if (state.isUnlocked(badgeId)) {
      return false; // Already unlocked
    }

    final badge = _badgeBox.get(badgeId);
    if (badge == null) return false;

    // Update badge
    badge.unlock();
    await _badgeBox.put(badgeId, badge);

    // Update unlocked IDs
    final unlockedIds = [...state.unlockedIds, badgeId];
    await _saveUnlockedIds(unlockedIds);

    // Update state
    state = state.copyWith(
      unlockedIds: unlockedIds,
      newlyUnlocked: badge,
    );

    return true;
  }

  /// Clear newly unlocked
  void clearNewlyUnlocked() {
    state = state.copyWith(newlyUnlocked: null);
  }

  /// Check for automatic unlocks based on user stats
  Future<void> _checkAutomaticUnlocks() async {
    final settings = _ref.read(settingsProvider);

    // Check fasting badges
    await _checkFastingBadges(settings);

    // Check streak badges
    await _checkStreakBadges(settings);

    // Check prayer badges
    await _checkPrayerBadges(settings);
  }

  /// Check fasting-related badges
  Future<void> _checkFastingBadges(UserSettings settings) async {
    final totalFastDays = settings.totalFastDays;
    final currentStreak = settings.currentStreak;

    // First Fast
    if (totalFastDays >= 1) {
      await unlockBadge('fasting_1');
    }

    // Week Warrior (7 consecutive days)
    if (currentStreak >= 7) {
      await unlockBadge('fasting_7');
    }

    // Halfway Hero (15 days)
    if (totalFastDays >= 15) {
      await unlockBadge('fasting_15');
    }

    // Ramadan Champion (30 days)
    if (totalFastDays >= 30) {
      await unlockBadge('fasting_30');
    }
  }

  /// Check streak-related badges
  Future<void> _checkStreakBadges(UserSettings settings) async {
    final currentStreak = settings.currentStreak;

    if (currentStreak >= 3) await unlockBadge('streak_3');
    if (currentStreak >= 7) await unlockBadge('streak_7');
    if (currentStreak >= 14) await unlockBadge('streak_14');
    if (currentStreak >= 30) await unlockBadge('streak_30');
  }

  /// Check prayer-related badges
  Future<void> _checkPrayerBadges(UserSettings settings) async {
    // These would be checked based on prayer tracking data
    // For now, just placeholder
  }

  /// Record fast day and check badges
  Future<void> recordFastDay() async {
    final settings = _ref.read(settingsProvider);
    final now = DateTime.now();

    // Calculate new streak
    int newStreak = settings.currentStreak;
    DateTime? lastDate = settings.lastFastingDate;

    if (lastDate != null) {
      final difference = now.difference(lastDate).inDays;
      if (difference == 1) {
        newStreak++;
      } else if (difference > 1) {
        newStreak = 1;
      }
    } else {
      newStreak = 1;
    }

    final newLongestStreak = newStreak > settings.longestStreak 
        ? newStreak 
        : settings.longestStreak;

    // Update settings
    await _ref.read(settingsProvider.notifier).updateStreak(
      currentStreak: newStreak,
      longestStreak: newLongestStreak,
      lastFastingDate: now,
      totalFastDays: settings.totalFastDays + 1,
    );

    // Re-check badges
    await _checkAutomaticUnlocks();
  }

  /// Get progress for a badge
  double getBadgeProgress(BadgeModel badge) {
    final settings = _ref.read(settingsProvider);

    switch (badge.requirementType) {
      case 'fast_days':
        return (settings.totalFastDays / badge.requirement).clamp(0.0, 1.0);
      case 'consecutive_fast_days':
        return (settings.currentStreak / badge.requirement).clamp(0.0, 1.0);
      case 'fasting_streak':
        return (settings.currentStreak / badge.requirement).clamp(0.0, 1.0);
      default:
        return 0.0;
    }
  }

  /// Reset all badges (for testing)
  Future<void> resetAllBadges() async {
    await _metadataBox.delete('unlocked_badge_ids');
    await _badgeBox.clear();
    
    // Re-initialize
    await _initialize();
  }

  /// Refresh badges
  Future<void> refresh() async {
    await _checkAutomaticUnlocks();
  }
}

/// Badge provider
final badgeProvider = StateNotifierProvider<BadgeNotifier, BadgeState>((ref) {
  final badgeBox = Hive.box<BadgeModel>('badges');
  final metadataBox = Hive.box('badge_metadata');
  return BadgeNotifier(ref, badgeBox, metadataBox);
});

/// Unlocked badges provider
final unlockedBadgesProvider = Provider<List<BadgeModel>>((ref) {
  return ref.watch(badgeProvider).unlockedBadges;
});

/// Locked badges provider
final lockedBadgesProvider = Provider<List<BadgeModel>>((ref) {
  return ref.watch(badgeProvider).lockedBadges;
});

/// Total points provider
final totalPointsProvider = Provider<int>((ref) {
  return ref.watch(badgeProvider).totalPoints;
});

/// Badge progress provider
final badgeProgressProvider = Provider<double>((ref) {
  return ref.watch(badgeProvider).progressPercentage;
});

/// Recently unlocked badges provider
final recentlyUnlockedBadgesProvider = Provider<List<BadgeModel>>((ref) {
  return ref.watch(badgeProvider).recentlyUnlocked;
});

/// Next badge provider
final nextBadgeProvider = Provider<BadgeModel?>((ref) {
  return ref.watch(badgeProvider).nextBadge;
});

/// Newly unlocked badge provider
final newlyUnlockedBadgeProvider = Provider<BadgeModel?>((ref) {
  return ref.watch(badgeProvider).newlyUnlocked;
});

/// Badges by category provider
final badgesByCategoryProvider = Provider.family<List<BadgeModel>, String>((ref, category) {
  return ref.watch(badgeProvider).getBadgesByCategory(category);
});

/// Category progress provider
final categoryProgressProvider = Provider.family<Map<String, dynamic>, String>((ref, category) {
  final state = ref.watch(badgeProvider);
  return {
    'unlocked': state.getUnlockedCountForCategory(category),
    'total': state.getTotalCountForCategory(category),
    'progress': state.getTotalCountForCategory(category) > 0
        ? state.getUnlockedCountForCategory(category) / state.getTotalCountForCategory(category)
        : 0.0,
  };
});

/// User progress provider (comprehensive)
final userProgressProvider = Provider<Map<String, dynamic>>((ref) {
  final state = ref.watch(badgeProvider);
  final settings = ref.watch(settingsProvider);

  return {
    'totalPoints': state.totalPoints,
    'unlockedBadges': state.unlockedIds.length,
    'totalBadges': state.allBadges.length,
    'progressPercentage': state.progressPercentage,
    'currentStreak': settings.currentStreak,
    'longestStreak': settings.longestStreak,
    'totalFastDays': settings.totalFastDays,
    'level': _calculateLevel(state.totalPoints),
  };
});

/// Calculate user level based on points
int _calculateLevel(int points) {
  if (points >= 5000) return 10;
  if (points >= 4000) return 9;
  if (points >= 3000) return 8;
  if (points >= 2000) return 7;
  if (points >= 1500) return 6;
  if (points >= 1000) return 5;
  if (points >= 700) return 4;
  if (points >= 400) return 3;
  if (points >= 200) return 2;
  return 1;
}

/// Level info provider
final levelInfoProvider = Provider.family<Map<String, dynamic>, int>((ref, level) {
  final titles = {
    1: {'en': 'Seeker', 'bn': 'সন্ধানী'},
    2: {'en': 'Learner', 'bn': 'শিক্ষার্থী'},
    3: {'en': 'Practitioner', 'bn': 'অনুশীলনকারী'},
    4: {'en': 'Devotee', 'bn': 'ভক্ত'},
    5: {'en': 'Dedicated', 'bn': 'নিবেদিতপ্রাণ'},
    6: {'en': 'Committed', 'bn': 'প্রতিশ্রুতিবদ্ধ'},
    7: {'en': 'Righteous', 'bn': 'সৎ'},
    8: {'en': 'Pious', 'bn': 'ধার্মিক'},
    9: {'en': 'Virtuous', 'bn': 'গুণী'},
    10: {'en': 'Enlightened', 'bn': 'আলোকপ্রাপ্ত'},
  };

  final pointsNeeded = {
    1: 0,
    2: 200,
    3: 400,
    4: 700,
    5: 1000,
    6: 1500,
    7: 2000,
    8: 3000,
    9: 4000,
    10: 5000,
  };

  return {
    'level': level,
    'titleEn': titles[level]?['en'] ?? 'Seeker',
    'titleBn': titles[level]?['bn'] ?? 'সন্ধানী',
    'pointsNeeded': pointsNeeded[level] ?? 0,
    'nextLevelPoints': pointsNeeded[level + 1],
  };
});
