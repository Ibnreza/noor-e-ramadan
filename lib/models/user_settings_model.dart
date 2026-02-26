/// User Settings Model
/// Stores app preferences, location, and notification settings

import 'package:hive/hive.dart';

final Object _unset = Object();

part 'user_settings_model.g.dart';

@HiveType(typeId: 3)
class UserSettings extends HiveObject {
  // Language Settings
  @HiveField(0)
  String languageCode; // 'en' or 'bn'
  
  // Location Settings
  @HiveField(1)
  double latitude;
  
  @HiveField(2)
  double longitude;
  
  @HiveField(3)
  String locationName; // e.g., "Chandpur, Bangladesh"
  
  @HiveField(4)
  String countryCode;
  
  // Prayer Calculation Settings
  @HiveField(5)
  String calculationMethod; // 'karachi', 'makkah', 'egypt', etc.
  
  @HiveField(6)
  String madhab; // 'hanafi' or 'shafi'
  
  @HiveField(7)
  int fajrAngle;
  
  @HiveField(8)
  int ishaAngle;
  
  // Notification Settings
  @HiveField(9)
  bool enablePrayerNotifications;
  
  @HiveField(10)
  bool enablePrePrayerNotifications;
  
  @HiveField(11)
  int prePrayerNotificationMinutes; // Default: 10 minutes
  
  @HiveField(12)
  bool enableFastingNotifications;
  
  @HiveField(13)
  bool enableSuhoorNotification;
  
  @HiveField(14)
  bool enableIftarNotification;
  
  @HiveField(15)
  bool enableVibration;
  
  // Display Settings
  @HiveField(16)
  bool use24HourFormat;
  
  @HiveField(17)
  bool showArabicInPrayerTimes;
  
  @HiveField(18)
  bool showTransliteration;
  
  // App Settings
  @HiveField(19)
  bool hasCompletedOnboarding;
  
  @HiveField(20)
  DateTime? firstLaunchDate;
  
  @HiveField(21)
  String themeMode; // 'dark', 'light', 'system'
  
  // Ramadan Settings
  @HiveField(22)
  int? ramadanYear;
  
  @HiveField(23)
  int? ramadanDay; // Current day of Ramadan (1-30)
  
  // Gamification Settings
  @HiveField(24)
  int currentStreak;
  
  @HiveField(25)
  int longestStreak;
  
  @HiveField(26)
  DateTime? lastFastingDate;
  
  @HiveField(27)
  int totalFastDays;
  
  // Tasbih Settings
  @HiveField(28)
  bool enableTasbihHaptics;
  
  @HiveField(29)
  bool enableTasbihSound;
  
  @HiveField(30)
  int defaultTasbihTarget;

  UserSettings({
    this.languageCode = 'en',
    this.latitude = 23.2333, // Chandpur, Bangladesh default
    this.longitude = 90.6667,
    this.locationName = 'Chandpur, Bangladesh',
    this.countryCode = 'BD',
    this.calculationMethod = 'karachi',
    this.madhab = 'hanafi',
    this.fajrAngle = 18,
    this.ishaAngle = 18,
    this.enablePrayerNotifications = true,
    this.enablePrePrayerNotifications = true,
    this.prePrayerNotificationMinutes = 10,
    this.enableFastingNotifications = true,
    this.enableSuhoorNotification = true,
    this.enableIftarNotification = true,
    this.enableVibration = true,
    this.use24HourFormat = false,
    this.showArabicInPrayerTimes = true,
    this.showTransliteration = true,
    this.hasCompletedOnboarding = false,
    this.firstLaunchDate,
    this.themeMode = 'dark',
    this.ramadanYear,
    this.ramadanDay,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastFastingDate,
    this.totalFastDays = 0,
    this.enableTasbihHaptics = true,
    this.enableTasbihSound = false,
    this.defaultTasbihTarget = 33,
  });

  /// Create default settings
  factory UserSettings.defaultSettings() {
    return UserSettings(
      firstLaunchDate: DateTime.now(),
    );
  }

  /// Create settings for Bangladesh (Chandpur)
  factory UserSettings.bangladeshDefault() {
    return UserSettings(
      languageCode: 'bn',
      latitude: 23.2333,
      longitude: 90.6667,
      locationName: 'চাঁদপুর, বাংলাদেশ',
      countryCode: 'BD',
      calculationMethod: 'karachi',
      madhab: 'hanafi',
      firstLaunchDate: DateTime.now(),
    );
  }

  /// Check if location is set
  bool get hasLocation => latitude != 0.0 && longitude != 0.0;

  /// Get calculation method display name
  String get calculationMethodDisplay {
    switch (calculationMethod) {
      case 'karachi':
        return 'Islamic Society of North America (ISNA)';
      case 'makkah':
        return 'Umm al-Qura, Makkah';
      case 'egypt':
        return 'Egyptian General Authority';
      case 'tehran':
        return 'Institute of Geophysics, Tehran';
      case 'karachi':
        return 'University of Islamic Sciences, Karachi';
      default:
        return 'University of Islamic Sciences, Karachi';
    }
  }

  /// Get madhab display name
  String get madhabDisplay {
    switch (madhab) {
      case 'hanafi':
        return 'Hanafi';
      case 'shafi':
        return 'Shafi\'i';
      default:
        return 'Hanafi';
    }
  }

  /// Copy with method
  UserSettings copyWith({
    String? languageCode,
    double? latitude,
    double? longitude,
    String? locationName,
    String? countryCode,
    String? calculationMethod,
    String? madhab,
    int? fajrAngle,
    int? ishaAngle,
    bool? enablePrayerNotifications,
    bool? enablePrePrayerNotifications,
    int? prePrayerNotificationMinutes,
    bool? enableFastingNotifications,
    bool? enableSuhoorNotification,
    bool? enableIftarNotification,
    bool? enableVibration,
    bool? use24HourFormat,
    bool? showArabicInPrayerTimes,
    bool? showTransliteration,
    bool? hasCompletedOnboarding,
    Object? firstLaunchDate = _unset,
    String? themeMode,
    int? ramadanYear,
    int? ramadanDay,
    int? currentStreak,
    int? longestStreak,
    Object? lastFastingDate = _unset,
    int? totalFastDays,
    bool? enableTasbihHaptics,
    bool? enableTasbihSound,
    int? defaultTasbihTarget,
  }) {
    return UserSettings(
      languageCode: languageCode ?? this.languageCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      countryCode: countryCode ?? this.countryCode,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      madhab: madhab ?? this.madhab,
      fajrAngle: fajrAngle ?? this.fajrAngle,
      ishaAngle: ishaAngle ?? this.ishaAngle,
      enablePrayerNotifications: enablePrayerNotifications ?? this.enablePrayerNotifications,
      enablePrePrayerNotifications: enablePrePrayerNotifications ?? this.enablePrePrayerNotifications,
      prePrayerNotificationMinutes: prePrayerNotificationMinutes ?? this.prePrayerNotificationMinutes,
      enableFastingNotifications: enableFastingNotifications ?? this.enableFastingNotifications,
      enableSuhoorNotification: enableSuhoorNotification ?? this.enableSuhoorNotification,
      enableIftarNotification: enableIftarNotification ?? this.enableIftarNotification,
      enableVibration: enableVibration ?? this.enableVibration,
      use24HourFormat: use24HourFormat ?? this.use24HourFormat,
      showArabicInPrayerTimes: showArabicInPrayerTimes ?? this.showArabicInPrayerTimes,
      showTransliteration: showTransliteration ?? this.showTransliteration,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      firstLaunchDate: identical(firstLaunchDate, _unset) ? this.firstLaunchDate : firstLaunchDate as DateTime?,
      themeMode: themeMode ?? this.themeMode,
      ramadanYear: ramadanYear ?? this.ramadanYear,
      ramadanDay: ramadanDay ?? this.ramadanDay,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastFastingDate: identical(lastFastingDate, _unset) ? this.lastFastingDate : lastFastingDate as DateTime?,
      totalFastDays: totalFastDays ?? this.totalFastDays,
      enableTasbihHaptics: enableTasbihHaptics ?? this.enableTasbihHaptics,
      enableTasbihSound: enableTasbihSound ?? this.enableTasbihSound,
      defaultTasbihTarget: defaultTasbihTarget ?? this.defaultTasbihTarget,
    );
  }

  @override
  String toString() {
    return 'UserSettings(location: $locationName, lang: $languageCode)';
  }
}

/// Location presets for quick selection
class LocationPresets {
  static const List<Map<String, dynamic>> bangladeshCities = [
    {
      'name': 'Chandpur',
      'nameBn': 'চাঁদপুর',
      'latitude': 23.2333,
      'longitude': 90.6667,
    },
    {
      'name': 'Dhaka',
      'nameBn': 'ঢাকা',
      'latitude': 23.8103,
      'longitude': 90.4125,
    },
    {
      'name': 'Chittagong',
      'nameBn': 'চট্টগ্রাম',
      'latitude': 22.3569,
      'longitude': 91.7832,
    },
    {
      'name': 'Khulna',
      'nameBn': 'খুলনা',
      'latitude': 22.8456,
      'longitude': 89.5403,
    },
    {
      'name': 'Rajshahi',
      'nameBn': 'রাজশাহী',
      'latitude': 24.3745,
      'longitude': 88.6042,
    },
    {
      'name': 'Sylhet',
      'nameBn': 'সিলেট',
      'latitude': 24.8949,
      'longitude': 91.8687,
    },
    {
      'name': 'Barisal',
      'nameBn': 'বরিশাল',
      'latitude': 22.7010,
      'longitude': 90.3535,
    },
    {
      'name': 'Rangpur',
      'nameBn': 'রংপুর',
      'latitude': 25.7439,
      'longitude': 89.2752,
    },
    {
      'name': 'Mymensingh',
      'nameBn': 'ময়মনসিংহ',
      'latitude': 24.7471,
      'longitude': 90.4203,
    },
    {
      'name': 'Comilla',
      'nameBn': 'কুমিল্লা',
      'latitude': 23.4607,
      'longitude': 91.1809,
    },
  ];

  static Map<String, dynamic>? findCity(String name) {
    for (final city in bangladeshCities) {
      if (city['name'].toString().toLowerCase() == name.toLowerCase() ||
          city['nameBn'] == name) {
        return city;
      }
    }
    return null;
  }
}
