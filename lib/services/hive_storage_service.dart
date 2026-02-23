/// Hive Storage Service
/// Handles all local data persistence
/// Uses Hive for fast, lightweight local storage

import 'package:hive/hive.dart';

import '../models/prayer_times_model.dart';
import '../models/tasbih_model.dart';
import '../models/user_settings_model.dart';
import '../models/badge_model.dart';

/// Generic Hive storage service
class HiveStorageService<T> {
  final String boxName;
  Box<T>? _box;

  HiveStorageService(this.boxName);

  /// Initialize the box
  Future<void> init() async {
    _box = Hive.box<T>(boxName);
  }

  /// Get the box
  Box<T> get box {
    if (_box == null) {
      throw StateError('HiveStorageService not initialized. Call init() first.');
    }
    return _box!;
  }

  /// Get all items
  List<T> getAll() {
    return box.values.toList();
  }

  /// Get item by key
  T? get(String key) {
    return box.get(key);
  }

  /// Get item by index
  T? getAt(int index) {
    return box.getAt(index);
  }

  /// Save item
  Future<void> put(String key, T value) async {
    await box.put(key, value);
  }

  /// Save item at index
  Future<void> putAt(int index, T value) async {
    await box.putAt(index, value);
  }

  /// Add item (auto-generate key)
  Future<String> add(T value) async {
    final key = await box.add(value);
    return key.toString();
  }

  /// Delete item by key
  Future<void> delete(String key) async {
    await box.delete(key);
  }

  /// Delete item at index
  Future<void> deleteAt(int index) async {
    await box.deleteAt(index);
  }

  /// Delete all items
  Future<void> clear() async {
    await box.clear();
  }

  /// Check if key exists
  bool containsKey(String key) {
    return box.containsKey(key);
  }

  /// Get all keys
  List<dynamic> get keys => box.keys.toList();

  /// Get count
  int get count => box.length;

  /// Listen to changes
  Stream<BoxEvent> watch({dynamic key}) {
    return box.watch(key: key);
  }

  /// Close the box
  Future<void> close() async {
    await box.close();
    _box = null;
  }
}

/// User Settings Storage
class UserSettingsStorage {
  static const String _boxName = 'user_settings';
  static const String _settingsKey = 'settings';
  
  Box<UserSettings>? _box;

  Future<void> init() async {
    _box = Hive.box<UserSettings>(_boxName);
  }

  Box<UserSettings> get box {
    if (_box == null) {
      throw StateError('UserSettingsStorage not initialized');
    }
    return _box!;
  }

  /// Get user settings
  UserSettings getSettings() {
    return box.get(_settingsKey) ?? UserSettings.defaultSettings();
  }

  /// Save user settings
  Future<void> saveSettings(UserSettings settings) async {
    await box.put(_settingsKey, settings);
  }

  /// Update specific fields
  Future<void> updateSettings({
    String? languageCode,
    double? latitude,
    double? longitude,
    String? locationName,
    bool? enablePrayerNotifications,
    bool? enablePrePrayerNotifications,
    int? prePrayerNotificationMinutes,
    bool? enableFastingNotifications,
    bool? enableVibration,
    bool? use24HourFormat,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastFastingDate,
    int? totalFastDays,
  }) async {
    final settings = getSettings();
    final updatedSettings = settings.copyWith(
      languageCode: languageCode,
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
      enablePrayerNotifications: enablePrayerNotifications,
      enablePrePrayerNotifications: enablePrePrayerNotifications,
      prePrayerNotificationMinutes: prePrayerNotificationMinutes,
      enableFastingNotifications: enableFastingNotifications,
      enableVibration: enableVibration,
      use24HourFormat: use24HourFormat,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastFastingDate: lastFastingDate,
      totalFastDays: totalFastDays,
    );
    await saveSettings(updatedSettings);
  }

  /// Watch for changes
  Stream<BoxEvent> watch() {
    return box.watch(key: _settingsKey);
  }
}

/// Tasbih Session Storage
class TasbihStorage {
  static const String _boxName = 'tasbih_sessions';
  
  Box<TasbihSession>? _box;

  Future<void> init() async {
    _box = Hive.box<TasbihSession>(_boxName);
  }

  Box<TasbihSession> get box {
    if (_box == null) {
      throw StateError('TasbihStorage not initialized');
    }
    return _box!;
  }

  /// Save session
  Future<void> saveSession(TasbihSession session) async {
    await box.put(session.id, session);
  }

  /// Get session by ID
  TasbihSession? getSession(String id) {
    return box.get(id);
  }

  /// Get all sessions
  List<TasbihSession> getAllSessions() {
    return box.values.toList();
  }

  /// Get sessions for a specific date
  List<TasbihSession> getSessionsForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return box.values.where((session) {
      return session.startTime.isAfter(startOfDay) &&
             session.startTime.isBefore(endOfDay);
    }).toList();
  }

  /// Get today's sessions
  List<TasbihSession> getTodaySessions() {
    return getSessionsForDate(DateTime.now());
  }

  /// Get daily summary
  DailyTasbihSummary getDailySummary(DateTime date) {
    final sessions = getSessionsForDate(date);
    
    if (sessions.isEmpty) {
      return DailyTasbihSummary.empty(date);
    }

    final Map<DhikrType, int> dhikrCounts = {};
    int totalCount = 0;
    int goalsReached = 0;

    for (final session in sessions) {
      dhikrCounts[session.dhikrType] = 
          (dhikrCounts[session.dhikrType] ?? 0) + session.count;
      totalCount += session.count;
      if (session.isTargetReached) goalsReached++;
    }

    return DailyTasbihSummary(
      date: date,
      dhikrCounts: dhikrCounts,
      totalCount: totalCount,
      sessionsCompleted: sessions.length,
      goalsReached: goalsReached,
    );
  }

  /// Get total count for dhikr type
  int getTotalCountForDhikr(DhikrType type) {
    return box.values
        .where((session) => session.dhikrType == type)
        .fold(0, (sum, session) => sum + session.count);
  }

  /// Get all-time total count
  int getAllTimeTotalCount() {
    return box.values.fold(0, (sum, session) => sum + session.count);
  }

  /// Delete old sessions (keep last 90 days)
  Future<void> cleanupOldSessions() async {
    final cutoffDate = DateTime.now().subtract(const Duration(days: 90));
    final keysToDelete = <String>[];

    for (final entry in box.toMap().entries) {
      if (entry.value.startTime.isBefore(cutoffDate)) {
        keysToDelete.add(entry.key as String);
      }
    }

    for (final key in keysToDelete) {
      await box.delete(key);
    }
  }

  /// Get sessions for date range
  List<TasbihSession> getSessionsForRange(DateTime start, DateTime end) {
    return box.values.where((session) {
      return session.startTime.isAfter(start) &&
             session.startTime.isBefore(end);
    }).toList();
  }
}

/// Badge Storage
class BadgeStorage {
  static const String _boxName = 'badges';
  static const String _unlockedKey = 'unlocked_badge_ids';
  
  Box<BadgeModel>? _box;
  Box? _metadataBox;

  Future<void> init() async {
    _box = Hive.box<BadgeModel>(_boxName);
    _metadataBox = Hive.box('badge_metadata');
    
    // Initialize badges if not already done
    await _initializeBadges();
  }

  Box<BadgeModel> get box {
    if (_box == null) {
      throw StateError('BadgeStorage not initialized');
    }
    return _box!;
  }

  Box get metadataBox {
    if (_metadataBox == null) {
      throw StateError('BadgeStorage not initialized');
    }
    return _metadataBox!;
  }

  /// Initialize all badges
  Future<void> _initializeBadges() async {
    if (box.isEmpty) {
      for (final badge in AllBadges.all) {
        await box.put(badge.id, badge);
      }
    }
  }

  /// Get all badges
  List<BadgeModel> getAllBadges() {
    return box.values.toList();
  }

  /// Get unlocked badge IDs
  List<String> getUnlockedBadgeIds() {
    final ids = metadataBox.get(_unlockedKey);
    if (ids == null) return [];
    return List<String>.from(ids);
  }

  /// Get unlocked badges
  List<BadgeModel> getUnlockedBadges() {
    final unlockedIds = getUnlockedBadgeIds();
    return box.values
        .where((badge) => unlockedIds.contains(badge.id))
        .toList();
  }

  /// Get locked badges
  List<BadgeModel> getLockedBadges() {
    final unlockedIds = getUnlockedBadgeIds();
    return box.values
        .where((badge) => !unlockedIds.contains(badge.id))
        .toList();
  }

  /// Unlock a badge
  Future<bool> unlockBadge(String badgeId) async {
    final unlockedIds = getUnlockedBadgeIds();
    
    if (unlockedIds.contains(badgeId)) {
      return false; // Already unlocked
    }

    unlockedIds.add(badgeId);
    await metadataBox.put(_unlockedKey, unlockedIds);

    // Update badge in box
    final badge = box.get(badgeId);
    if (badge != null) {
      badge.unlock();
      await box.put(badgeId, badge);
    }

    return true;
  }

  /// Check if badge is unlocked
  bool isUnlocked(String badgeId) {
    return getUnlockedBadgeIds().contains(badgeId);
  }

  /// Get total points
  int getTotalPoints() {
    final unlockedBadges = getUnlockedBadges();
    return unlockedBadges.fold(0, (sum, badge) => sum + badge.points);
  }

  /// Get progress
  double getProgress() {
    final total = box.length;
    final unlocked = getUnlockedBadgeIds().length;
    return total > 0 ? unlocked / total : 0.0;
  }

  /// Get badges by category
  List<BadgeModel> getBadgesByCategory(String category) {
    return box.values
        .where((badge) => badge.category == category)
        .toList();
  }

  /// Get recently unlocked badges
  List<BadgeModel> getRecentlyUnlocked({int limit = 5}) {
    final unlocked = getUnlockedBadges();
    unlocked.sort((a, b) {
      if (a.unlockedAt == null || b.unlockedAt == null) return 0;
      return b.unlockedAt!.compareTo(a.unlockedAt!);
    });
    return unlocked.take(limit).toList();
  }

  /// Reset all badges (for testing)
  Future<void> resetAllBadges() async {
    await metadataBox.delete(_unlockedKey);
    await box.clear();
    await _initializeBadges();
  }
}

/// Fasting Streak Storage
class FastingStreakStorage {
  static const String _boxName = 'fasting_streak';
  
  Box? _box;

  Future<void> init() async {
    _box = Hive.box(_boxName);
  }

  Box get box {
    if (_box == null) {
      throw StateError('FastingStreakStorage not initialized');
    }
    return _box!;
  }

  /// Get current streak
  int getCurrentStreak() {
    return box.get('current_streak', defaultValue: 0);
  }

  /// Get longest streak
  int getLongestStreak() {
    return box.get('longest_streak', defaultValue: 0);
  }

  /// Get last fasting date
  DateTime? getLastFastingDate() {
    final timestamp = box.get('last_fasting_date');
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Get total fast days
  int getTotalFastDays() {
    return box.get('total_fast_days', defaultValue: 0);
  }

  /// Get fasted dates
  List<DateTime> getFastedDates() {
    final timestamps = box.get('fasted_dates', defaultValue: <int>[]);
    return List<int>.from(timestamps)
        .map((ts) => DateTime.fromMillisecondsSinceEpoch(ts))
        .toList();
  }

  /// Record a fast day
  Future<void> recordFastDay(DateTime date) async {
    final fastedDates = getFastedDates();
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    // Check if already recorded
    if (fastedDates.any((d) => 
        d.year == dateOnly.year && 
        d.month == dateOnly.month && 
        d.day == dateOnly.day)) {
      return;
    }

    // Add to fasted dates
    fastedDates.add(dateOnly);
    await box.put('fasted_dates', 
        fastedDates.map((d) => d.millisecondsSinceEpoch).toList());

    // Update streak
    final lastDate = getLastFastingDate();
    int currentStreak = getCurrentStreak();

    if (lastDate != null) {
      final difference = dateOnly.difference(lastDate).inDays;
      if (difference == 1) {
        currentStreak++;
      } else if (difference > 1) {
        currentStreak = 1; // Reset streak
      }
    } else {
      currentStreak = 1;
    }

    await box.put('current_streak', currentStreak);
    await box.put('last_fasting_date', dateOnly.millisecondsSinceEpoch);

    // Update longest streak
    final longestStreak = getLongestStreak();
    if (currentStreak > longestStreak) {
      await box.put('longest_streak', currentStreak);
    }

    // Update total
    await box.put('total_fast_days', fastedDates.length);
  }

  /// Check if fasted on specific date
  bool hasFastedOn(DateTime date) {
    final fastedDates = getFastedDates();
    return fastedDates.any((d) => 
        d.year == date.year && 
        d.month == date.month && 
        d.day == date.day);
  }

  /// Get streak for date range
  List<bool> getStreakForRange(DateTime start, int days) {
    return List.generate(days, (index) {
      final date = start.add(Duration(days: index));
      return hasFastedOn(date);
    });
  }

  /// Reset all data (for testing)
  Future<void> resetAll() async {
    await box.clear();
  }
}

/// Global storage instances
late final UserSettingsStorage userSettingsStorage;
late final TasbihStorage tasbihStorage;
late final BadgeStorage badgeStorage;
late final FastingStreakStorage fastingStreakStorage;

/// Initialize all storage services
Future<void> initializeStorage() async {
  userSettingsStorage = UserSettingsStorage();
  await userSettingsStorage.init();

  tasbihStorage = TasbihStorage();
  await tasbihStorage.init();

  badgeStorage = BadgeStorage();
  await badgeStorage.init();

  fastingStreakStorage = FastingStreakStorage();
  await fastingStreakStorage.init();
}
