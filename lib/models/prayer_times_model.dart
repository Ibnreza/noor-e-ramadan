/// Prayer Times Model
/// Stores calculated prayer times for a specific date
/// Uses Adhan Dart library for calculations

import 'package:hive/hive.dart';

part 'prayer_times_model.g.dart';

@HiveType(typeId: 1)
class PrayerTimesModel extends HiveObject {
  @HiveField(0)
  final DateTime date;
  
  @HiveField(1)
  final DateTime fajr;
  
  @HiveField(2)
  final DateTime sunrise;
  
  @HiveField(3)
  final DateTime dhuhr;
  
  @HiveField(4)
  final DateTime asr;
  
  @HiveField(5)
  final DateTime maghrib;
  
  @HiveField(6)
  final DateTime isha;
  
  @HiveField(7)
  final DateTime imsak; // Suhoor end time
  
  @HiveField(8)
  final double latitude;
  
  @HiveField(9)
  final double longitude;
  
  @HiveField(10)
  final String timezone;

  PrayerTimesModel({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.imsak,
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });

  /// Get current prayer time name
  String getCurrentPrayer(DateTime now) {
    if (now.isBefore(fajr)) return 'isha';
    if (now.isBefore(sunrise)) return 'fajr';
    if (now.isBefore(dhuhr)) return 'sunrise';
    if (now.isBefore(asr)) return 'dhuhr';
    if (now.isBefore(maghrib)) return 'asr';
    if (now.isBefore(isha)) return 'maghrib';
    return 'isha';
  }

  /// Get next prayer time
  DateTime getNextPrayerTime(DateTime now) {
    if (now.isBefore(fajr)) return fajr;
    if (now.isBefore(sunrise)) return sunrise;
    if (now.isBefore(dhuhr)) return dhuhr;
    if (now.isBefore(asr)) return asr;
    if (now.isBefore(maghrib)) return maghrib;
    if (now.isBefore(isha)) return isha;
    return fajr.add(const Duration(days: 1));
  }

  /// Get next prayer name
  String getNextPrayerName(DateTime now) {
    if (now.isBefore(fajr)) return 'fajr';
    if (now.isBefore(sunrise)) return 'sunrise';
    if (now.isBefore(dhuhr)) return 'dhuhr';
    if (now.isBefore(asr)) return 'asr';
    if (now.isBefore(maghrib)) return 'maghrib';
    if (now.isBefore(isha)) return 'isha';
    return 'fajr';
  }

  /// Get time until next prayer
  Duration getTimeUntilNextPrayer(DateTime now) {
    final nextPrayer = getNextPrayerTime(now);
    return nextPrayer.difference(now);
  }

  /// Get time until Iftar (Maghrib)
  Duration getTimeUntilIftar(DateTime now) {
    if (now.isBefore(maghrib)) {
      return maghrib.difference(now);
    }
    return Duration.zero;
  }

  /// Get time until Suhoor ends (Imsak)
  Duration getTimeUntilSuhoor(DateTime now) {
    if (now.isBefore(imsak)) {
      return imsak.difference(now);
    }
    return Duration.zero;
  }

  /// Check if currently fasting time
  bool isFastingTime(DateTime now) {
    return now.isAfter(imsak) && now.isBefore(maghrib);
  }

  /// Format time for display (e.g., "05:09 AM")
  static String formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  /// Format time in 24-hour format (e.g., "05:09")
  static String formatTime24(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Get prayer time by name
  DateTime? getPrayerTime(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return fajr;
      case 'sunrise':
        return sunrise;
      case 'dhuhr':
        return dhuhr;
      case 'asr':
        return asr;
      case 'maghrib':
        return maghrib;
      case 'isha':
        return isha;
      case 'imsak':
        return imsak;
      default:
        return null;
    }
  }

  @override
  String toString() {
    return 'PrayerTimesModel(date: $date, fajr: ${formatTime(fajr)}, '
        'dhuhr: ${formatTime(dhuhr)}, asr: ${formatTime(asr)}, '
        'maghrib: ${formatTime(maghrib)}, isha: ${formatTime(isha)})';
  }
}

/// Prayer names for UI display
class PrayerNames {
  static const String fajr = 'Fajr';
  static const String sunrise = 'Sunrise';
  static const String dhuhr = 'Dhuhr';
  static const String asr = 'Asr';
  static const String maghrib = 'Maghrib';
  static const String isha = 'Isha';
  static const String imsak = 'Imsak';
}

/// Prayer names in Arabic
class PrayerNamesArabic {
  static const String fajr = 'الفجر';
  static const String sunrise = 'الشروق';
  static const String dhuhr = 'الظهر';
  static const String asr = 'العصر';
  static const String maghrib = 'المغرب';
  static const String isha = 'العشاء';
  static const String imsak = 'الإمساك';
}

/// Prayer names in Bangla
class PrayerNamesBangla {
  static const String fajr = 'ফজর';
  static const String sunrise = 'সূর্যোদয়';
  static const String dhuhr = 'যোহর';
  static const String asr = 'আসর';
  static const String maghrib = 'মাগরিব';
  static const String isha = 'এশা';
  static const String imsak = 'ইমসাক';
}
