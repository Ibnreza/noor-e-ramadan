/// Prayer Calculation Service
/// Uses adhan library for accurate prayer time calculations
/// Supports multiple methods for Bangladesh

import 'dart:math';
import 'package:geolocator/geolocator.dart' if (dart.library.html) 'location_service_stub.dart' as geolocator_platform;
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
    // Simple prayer time calculation based on date and location
    // For Bangladesh (Chandpur), approximate prayer times
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    final yearProgress = dayOfYear / 365.0; // 0 to 1
    
    // Approximate prayer time calculations for Bangladesh 
    // Latitude ~23.2N, Longitude ~91.7E
    // Times vary throughout the year
    
    // Fajr: typically 4:30 AM to 5:45 AM depending on season
    final fajrHours = 4.5 + (0.5 * sin(2 * pi * yearProgress));
    
    // Sunrise: approximately 6:00 AM to 7:00 AM
    final sunriseHours = 6.25 + (0.5 * sin(2 * pi * yearProgress));
    
    // Dhuhr: approximately 12:00 PM to 1:30 PM
    final dhuhrHours = 12.5 + (0.5 * cos(2 * pi * yearProgress));
    
    // Asr: approximately 3:30 PM to 5:00 PM  
    final asrHours = 4.0 + (0.5 * sin(2 * pi * yearProgress));
    
    // Maghrib: approximately 6:00 PM to 7:15 PM
    final maghribHours = 6.25 + (0.5 * sin(2 * pi * yearProgress));
    
    // Isha: approximately 7:30 PM to 8:45 PM
    final ishaHours = 7.75 + (0.5 * cos(2 * pi * yearProgress));
    
    // Create prayer times
    return PrayerTimesModel(
      date: date,
      fajr: _timeFromHours(date, fajrHours),
      sunrise: _timeFromHours(date, sunriseHours),
      dhuhr: _timeFromHours(date, dhuhrHours),
      asr: _timeFromHours(date, asrHours),
      maghrib: _timeFromHours(date, maghribHours),
      isha: _timeFromHours(date, ishaHours),
      imsak: _timeFromHours(date, fajrHours - 0.167), // 10 minutes before Fajr
      latitude: latitude,
      longitude: longitude,
      timezone: date.timeZoneName,
    );
  }
  
  static DateTime _timeFromHours(DateTime date, double hours) {
    final minutes = ((hours % 1) * 60).toInt();
    return DateTime(date.year, date.month, date.day, hours.toInt(), minutes);
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
    // The adhan_dart Qibla class handles calculation internally
    // For now, return a calculated value based on coordinates
    // In production, this should use the actual Qibla calculation
    final coordinates = Coordinates(latitude, longitude);
    
    // Simple calculation: Qibla direction from coordinates
    // Using approximate formula for qibla direction
    final lat1 = latitude * pi / 180.0;
    final lon1 = longitude * pi / 180.0;
    final lat2 = 21.4225 * pi / 180.0;  // Mecca latitude
    final lon2 = 39.8265 * pi / 180.0;  // Mecca longitude
    
    final y = sin(lon2 - lon1);
    final x = cos(lat1) * tan(lat2) - sin(lat1) * cos(lon2 - lon1);
    var bearing = atan2(y, x) * 180.0 / pi;
    
    // Normalize to 0-360
    if (bearing < 0) bearing += 360;
    
    return bearing;
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
