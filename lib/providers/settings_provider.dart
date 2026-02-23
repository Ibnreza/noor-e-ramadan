/// Settings Provider
/// Manages user settings and preferences using Riverpod

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/user_settings_model.dart';

/// Settings state notifier
class SettingsNotifier extends StateNotifier<UserSettings> {
  final Box<UserSettings> _box;
  
  SettingsNotifier(this._box) : super(UserSettings.defaultSettings()) {
    _loadSettings();
  }

  /// Load settings from Hive
  void _loadSettings() {
    final settings = _box.get('settings');
    if (settings != null) {
      state = settings;
    }
  }

  /// Save settings to Hive
  Future<void> _saveSettings() async {
    await _box.put('settings', state);
  }

  /// Update language
  Future<void> setLanguage(String languageCode) async {
    state = state.copyWith(languageCode: languageCode);
    await _saveSettings();
  }

  /// Update location
  Future<void> setLocation({
    required double latitude,
    required double longitude,
    required String locationName,
  }) async {
    state = state.copyWith(
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
    );
    await _saveSettings();
  }

  /// Update calculation method
  Future<void> setCalculationMethod(String method) async {
    state = state.copyWith(calculationMethod: method);
    await _saveSettings();
  }

  /// Update madhab
  Future<void> setMadhab(String madhab) async {
    state = state.copyWith(madhab: madhab);
    await _saveSettings();
  }

  /// Toggle prayer notifications
  Future<void> togglePrayerNotifications() async {
    state = state.copyWith(
      enablePrayerNotifications: !state.enablePrayerNotifications,
    );
    await _saveSettings();
  }

  /// Toggle pre-prayer notifications
  Future<void> togglePrePrayerNotifications() async {
    state = state.copyWith(
      enablePrePrayerNotifications: !state.enablePrePrayerNotifications,
    );
    await _saveSettings();
  }

  /// Set pre-prayer notification minutes
  Future<void> setPrePrayerMinutes(int minutes) async {
    state = state.copyWith(prePrayerNotificationMinutes: minutes);
    await _saveSettings();
  }

  /// Toggle fasting notifications
  Future<void> toggleFastingNotifications() async {
    state = state.copyWith(
      enableFastingNotifications: !state.enableFastingNotifications,
    );
    await _saveSettings();
  }

  /// Toggle Suhoor notification
  Future<void> toggleSuhoorNotification() async {
    state = state.copyWith(
      enableSuhoorNotification: !state.enableSuhoorNotification,
    );
    await _saveSettings();
  }

  /// Toggle Iftar notification
  Future<void> toggleIftarNotification() async {
    state = state.copyWith(
      enableIftarNotification: !state.enableIftarNotification,
    );
    await _saveSettings();
  }

  /// Toggle vibration
  Future<void> toggleVibration() async {
    state = state.copyWith(enableVibration: !state.enableVibration);
    await _saveSettings();
  }

  /// Toggle 24-hour format
  Future<void> toggle24HourFormat() async {
    state = state.copyWith(use24HourFormat: !state.use24HourFormat);
    await _saveSettings();
  }

  /// Toggle Arabic in prayer times
  Future<void> toggleArabicInPrayerTimes() async {
    state = state.copyWith(
      showArabicInPrayerTimes: !state.showArabicInPrayerTimes,
    );
    await _saveSettings();
  }

  /// Toggle transliteration
  Future<void> toggleTransliteration() async {
    state = state.copyWith(showTransliteration: !state.showTransliteration);
    await _saveSettings();
  }

  /// Update streak
  Future<void> updateStreak({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastFastingDate,
    int? totalFastDays,
  }) async {
    state = state.copyWith(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastFastingDate: lastFastingDate,
      totalFastDays: totalFastDays,
    );
    await _saveSettings();
  }

  /// Complete onboarding
  Future<void> completeOnboarding() async {
    state = state.copyWith(hasCompletedOnboarding: true);
    await _saveSettings();
  }

  /// Toggle Tasbih haptics
  Future<void> toggleTasbihHaptics() async {
    state = state.copyWith(enableTasbihHaptics: !state.enableTasbihHaptics);
    await _saveSettings();
  }

  /// Toggle Tasbih sound
  Future<void> toggleTasbihSound() async {
    state = state.copyWith(enableTasbihSound: !state.enableTasbihSound);
    await _saveSettings();
  }

  /// Set default Tasbih target
  Future<void> setDefaultTasbihTarget(int target) async {
    state = state.copyWith(defaultTasbihTarget: target);
    await _saveSettings();
  }

  /// Update Ramadan day
  Future<void> setRamadanDay(int? day) async {
    state = state.copyWith(
      ramadanDay: day,
      ramadanYear: day != null ? DateTime.now().year : null,
    );
    await _saveSettings();
  }

  /// Reset all settings
  Future<void> resetSettings() async {
    state = UserSettings.defaultSettings();
    await _saveSettings();
  }
}

/// Settings provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, UserSettings>((ref) {
  final box = Hive.box<UserSettings>('user_settings');
  return SettingsNotifier(box);
});

/// Language provider
final languageProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider).languageCode;
});

/// Location provider
final locationProvider = Provider<Map<String, dynamic>>((ref) {
  final settings = ref.watch(settingsProvider);
  return {
    'latitude': settings.latitude,
    'longitude': settings.longitude,
    'locationName': settings.locationName,
  };
});

/// Notification settings provider
final notificationSettingsProvider = Provider<Map<String, dynamic>>((ref) {
  final settings = ref.watch(settingsProvider);
  return {
    'enablePrayerNotifications': settings.enablePrayerNotifications,
    'enablePrePrayerNotifications': settings.enablePrePrayerNotifications,
    'prePrayerNotificationMinutes': settings.prePrayerNotificationMinutes,
    'enableFastingNotifications': settings.enableFastingNotifications,
    'enableSuhoorNotification': settings.enableSuhoorNotification,
    'enableIftarNotification': settings.enableIftarNotification,
    'enableVibration': settings.enableVibration,
  };
});

/// Display settings provider
final displaySettingsProvider = Provider<Map<String, dynamic>>((ref) {
  final settings = ref.watch(settingsProvider);
  return {
    'use24HourFormat': settings.use24HourFormat,
    'showArabicInPrayerTimes': settings.showArabicInPrayerTimes,
    'showTransliteration': settings.showTransliteration,
  };
});

/// Streak provider
final streakProvider = Provider<Map<String, dynamic>>((ref) {
  final settings = ref.watch(settingsProvider);
  return {
    'currentStreak': settings.currentStreak,
    'longestStreak': settings.longestStreak,
    'lastFastingDate': settings.lastFastingDate,
    'totalFastDays': settings.totalFastDays,
  };
});

/// Is Bangladesh location provider
final isBangladeshProvider = Provider<bool>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.countryCode == 'BD';
});

/// Settings stream provider (for real-time updates)
final settingsStreamProvider = StreamProvider<UserSettings>((ref) async* {
  final box = Hive.box<UserSettings>('user_settings');
  
  // Yield initial value
  yield box.get('settings') ?? UserSettings.defaultSettings();
  
  // Listen to changes
  await for (final _ in box.watch(key: 'settings')) {
    yield box.get('settings') ?? UserSettings.defaultSettings();
  }
});
