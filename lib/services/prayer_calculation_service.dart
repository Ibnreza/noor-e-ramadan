/// Prayer Calculation Service
/// Uses adhan_dart library for accurate prayer time calculations
/// Supports Karachi method for Bangladesh

import 'package:adhan_dart/adhan_dart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../models/prayer_times_model.dart';
import '../models/user_settings_model.dart';

class PrayerCalculationService {
  static const String _boxName = 'prayer_times';
  
  /// Get prayer times for a specific date
  static PrayerTimesModel calculatePrayerTimes({
    required DateTime date,
    required double latitude,
    required double longitude,
    String calculationMethod = 'karachi',
    String madhab = 'hanafi',
  }) {
    // Create coordinates
    final coordinates = Coordinates(latitude, longitude);
    
    // Get calculation parameters based on method
    final params = _getCalculationParameters(calculationMethod, madhab);
    
    // Create date components
    final dateComponents = DateComponents.from(date);
    
    // Calculate prayer times
    final prayerTimes = PrayerTimes(coordinates, dateComponents, params);
    
    // Get timezone offset
    final timezoneOffset = date.timeZoneOffset;
    
    // Convert to local DateTime
    DateTime convertToLocal(DateTime utcTime) {
      return utcTime.add(timezoneOffset);
    }
    
    // Calculate Imsak (10 minutes before Fajr)
    final imsak = prayerTimes.fajr?.subtract(const Duration(minutes: 10));
    
    return PrayerTimesModel(
      date: date,
      fajr: convertToLocal(prayerTimes.fajr!),
      sunrise: convertToLocal(prayerTimes.sunrise!),
      dhuhr: convertToLocal(prayerTimes.dhuhr!),
      asr: convertToLocal(prayerTimes.asr!),
      maghrib: convertToLocal(prayerTimes.maghrib!),
      isha: convertToLocal(prayerTimes.isha!),
      imsak: convertToLocal(imsak!),
      latitude: latitude,
      longitude: longitude,
      timezone: date.timeZoneName,
    );
  }
  
  /// Get calculation parameters
  static CalculationParameters _getCalculationParameters(
    String method,
    String madhab,
  ) {
    CalculationParameters params;
    
    switch (method.toLowerCase()) {
      case 'karachi':
        params = CalculationMethod.karachi();
        break;
      case 'makkah':
        params = CalculationMethod.ummAlQura();
        break;
      case 'egypt':
        params = CalculationMethod.egyptian();
        break;
      case 'tehran':
        params = CalculationMethod.tehran();
        break;
      case 'isna':
        params = CalculationMethod.northAmerica();
        break;
      case 'muslim_world_league':
        params = CalculationMethod.muslimWorldLeague();
        break;
      default:
        params = CalculationMethod.karachi();
    }
    
    // Set madhab for Asr calculation
    if (madhab.toLowerCase() == 'hanafi') {
      params.madhab = Madhab.hanafi;
    } else {
      params.madhab = Madhab.shafi;
    }
    
    return params;
  }
  
  /// Calculate prayer times for the entire month
  static List<PrayerTimesModel> calculateMonthPrayerTimes({
    required int year,
    required int month,
    required double latitude,
    required double longitude,
    String calculationMethod = 'karachi',
    String madhab = 'hanafi',
  }) {
    final List<PrayerTimesModel> monthTimes = [];
    
    // Get number of days in month
    final daysInMonth = DateTime(year, month + 1, 0).day;
    
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final prayerTimes = calculatePrayerTimes(
        date: date,
        latitude: latitude,
        longitude: longitude,
        calculationMethod: calculationMethod,
        madhab: madhab,
      );
      monthTimes.add(prayerTimes);
    }
    
    return monthTimes;
  }
  
  /// Save prayer times to Hive
  static Future<void> savePrayerTimes(PrayerTimesModel prayerTimes) async {
    final box = Hive.box<PrayerTimesModel>(_boxName);
    final key = _getDateKey(prayerTimes.date);
    await box.put(key, prayerTimes);
  }
  
  /// Get prayer times from Hive
  static PrayerTimesModel? getPrayerTimes(DateTime date) {
    final box = Hive.box<PrayerTimesModel>(_boxName);
    final key = _getDateKey(date);
    return box.get(key);
  }
  
  /// Get or calculate prayer times (with caching)
  static Future<PrayerTimesModel> getOrCalculatePrayerTimes({
    required DateTime date,
    required UserSettings settings,
  }) async {
    // Try to get from cache first
    final cached = getPrayerTimes(date);
    if (cached != null) {
      return cached;
    }
    
    // Calculate new prayer times
    final prayerTimes = calculatePrayerTimes(
      date: date,
      latitude: settings.latitude,
      longitude: settings.longitude,
      calculationMethod: settings.calculationMethod,
      madhab: settings.madhab,
    );
    
    // Save to cache
    await savePrayerTimes(prayerTimes);
    
    return prayerTimes;
  }
  
  /// Get today's prayer times
  static Future<PrayerTimesModel> getTodayPrayerTimes(UserSettings settings) async {
    final now = DateTime.now();
    return getOrCalculatePrayerTimes(date: now, settings: settings);
  }
  
  /// Get tomorrow's prayer times
  static Future<PrayerTimesModel> getTomorrowPrayerTimes(UserSettings settings) async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return getOrCalculatePrayerTimes(date: tomorrow, settings: settings);
  }
  
  /// Get prayer times for date range
  static Future<List<PrayerTimesModel>> getPrayerTimesRange({
    required DateTime start,
    required DateTime end,
    required UserSettings settings,
  }) async {
    final List<PrayerTimesModel> results = [];
    
    var current = start;
    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      final prayerTimes = await getOrCalculatePrayerTimes(
        date: current,
        settings: settings,
      );
      results.add(prayerTimes);
      current = current.add(const Duration(days: 1));
    }
    
    return results;
  }
  
  /// Generate Ramadan calendar (for Bangladesh)
  static Future<List<PrayerTimesModel>> generateRamadanCalendar({
    required int year,
    required UserSettings settings,
  }) async {
    // Ramadan 2026 is expected to start around February 18, 2026
    // This is approximate and should be verified
    final ramadanStart2026 = DateTime(2026, 2, 18);
    
    // For other years, calculate based on Islamic calendar
    DateTime ramadanStart;
    if (year == 2026) {
      ramadanStart = ramadanStart2026;
    } else {
      // Approximate calculation (Islamic year is ~354 days)
      final yearsDiff = year - 2026;
      ramadanStart = ramadanStart2026.add(
        Duration(days: yearsDiff * 354),
      );
    }
    
    // Generate 30 days of Ramadan
    final List<PrayerTimesModel> ramadanCalendar = [];
    
    for (int day = 0; day < 30; day++) {
      final date = ramadanStart.add(Duration(days: day));
      final prayerTimes = await getOrCalculatePrayerTimes(
        date: date,
        settings: settings,
      );
      ramadanCalendar.add(prayerTimes);
    }
    
    return ramadanCalendar;
  }
  
  /// Get current Ramadan day (1-30)
  static int? getCurrentRamadanDay(int year) {
    final now = DateTime.now();
    
    // Ramadan 2026 start date
    final ramadanStart2026 = DateTime(2026, 2, 18);
    
    DateTime ramadanStart;
    if (year == 2026) {
      ramadanStart = ramadanStart2026;
    } else {
      final yearsDiff = year - 2026;
      ramadanStart = ramadanStart2026.add(
        Duration(days: yearsDiff * 354),
      );
    }
    
    final ramadanEnd = ramadanStart.add(const Duration(days: 29));
    
    if (now.isBefore(ramadanStart) || now.isAfter(ramadanEnd)) {
      return null;
    }
    
    return now.difference(ramadanStart).inDays + 1;
  }
  
  /// Check if currently in Ramadan
  static bool isRamadan(int year) {
    return getCurrentRamadanDay(year) != null;
  }
  
  /// Get next prayer notification time
  static DateTime? getNextNotificationTime({
    required PrayerTimesModel prayerTimes,
    required DateTime now,
    required int preNotificationMinutes,
  }) {
    final prayers = [
      ('fajr', prayerTimes.fajr),
      ('dhuhr', prayerTimes.dhuhr),
      ('asr', prayerTimes.asr),
      ('maghrib', prayerTimes.maghrib),
      ('isha', prayerTimes.isha),
    ];
    
    for (final (name, time) in prayers) {
      final notificationTime = time.subtract(
        Duration(minutes: preNotificationMinutes),
      );
      
      if (notificationTime.isAfter(now)) {
        return notificationTime;
      }
    }
    
    // All prayers passed, return tomorrow's Fajr
    return prayerTimes.fajr
        .add(const Duration(days: 1))
        .subtract(Duration(minutes: preNotificationMinutes));
  }
  
  /// Get Suhoor notification time (10 minutes before Imsak)
  static DateTime getSuhoorNotificationTime(PrayerTimesModel prayerTimes) {
    return prayerTimes.imsak.subtract(const Duration(minutes: 10));
  }
  
  /// Get Iftar notification time (at Maghrib)
  static DateTime getIftarNotificationTime(PrayerTimesModel prayerTimes) {
    return prayerTimes.maghrib;
  }
  
  /// Generate date key for Hive storage
  static String _getDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
  
  /// Clear old prayer times cache
  static Future<void> clearOldCache() async {
    final box = Hive.box<PrayerTimesModel>(_boxName);
    final now = DateTime.now();
    final keysToDelete = <String>[];
    
    for (final key in box.keys) {
      try {
        final date = DateFormat('yyyy-MM-dd').parse(key as String);
        // Delete entries older than 60 days
        if (now.difference(date).inDays > 60) {
          keysToDelete.add(key);
        }
      } catch (e) {
        // Invalid key format, delete it
        keysToDelete.add(key);
      }
    }
    
    for (final key in keysToDelete) {
      await box.delete(key);
    }
  }
  
  /// Get prayer direction (Qibla angle)
  static double getQiblaDirection(double latitude, double longitude) {
    final coordinates = Coordinates(latitude, longitude);
    final qibla = Qibla(coordinates);
    return qibla.qiblaDirection;
  }
}

/// Prayer time comparison extension
extension PrayerTimeComparison on DateTime {
  bool isSamePrayerTime(DateTime other) {
    return hour == other.hour && minute == other.minute;
  }
}

/// Prayer status enum
enum PrayerStatus {
  upcoming,
  current,
  completed,
  missed,
}

/// Prayer tracking model
class PrayerTracking {
  final String prayerName;
  final DateTime scheduledTime;
  DateTime? completedTime;
  PrayerStatus status;

  PrayerTracking({
    required this.prayerName,
    required this.scheduledTime,
    this.completedTime,
    this.status = PrayerStatus.upcoming,
  });

  /// Mark prayer as completed
  void markCompleted() {
    completedTime = DateTime.now();
    status = PrayerStatus.completed;
  }

  /// Mark prayer as missed
  void markMissed() {
    status = PrayerStatus.missed;
  }

  /// Check if prayer is on time
  bool get isOnTime {
    if (completedTime == null) return false;
    final diff = completedTime!.difference(scheduledTime);
    return diff.inMinutes <= 30; // Within 30 minutes
  }
}
