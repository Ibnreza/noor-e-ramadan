// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings_model.dart';

// Stub Hive adapter for web compatibility
class UserSettingsAdapter extends TypeAdapter<UserSettings> {
  @override
  final typeId = 3;

  @override
  UserSettings read(BinaryReader reader) {
    throw UnsupportedError('Hive persistence not supported on web');
  }

  @override
  void write(BinaryWriter writer, UserSettings obj) {
    throw UnsupportedError('Hive persistence not supported on web');
  }
}

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserSettingsAdapter extends TypeAdapter<UserSettings> {
  @override
  final int typeId = 3;

  @override
  UserSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSettings(
      languageCode: fields[0] as String,
      latitude: fields[1] as double,
      longitude: fields[2] as double,
      locationName: fields[3] as String,
      countryCode: fields[4] as String,
      calculationMethod: fields[5] as String,
      madhab: fields[6] as String,
      fajrAngle: fields[7] as int,
      ishaAngle: fields[8] as int,
      enablePrayerNotifications: fields[9] as bool,
      enablePrePrayerNotifications: fields[10] as bool,
      prePrayerNotificationMinutes: fields[11] as int,
      enableFastingNotifications: fields[12] as bool,
      enableSuhoorNotification: fields[13] as bool,
      enableIftarNotification: fields[14] as bool,
      enableVibration: fields[15] as bool,
      use24HourFormat: fields[16] as bool,
      showArabicInPrayerTimes: fields[17] as bool,
      showTransliteration: fields[18] as bool,
      hasCompletedOnboarding: fields[19] as bool,
      firstLaunchDate: fields[20] as DateTime?,
      themeMode: fields[21] as String,
      ramadanYear: fields[22] as int?,
      ramadanDay: fields[23] as int?,
      currentStreak: fields[24] as int,
      longestStreak: fields[25] as int,
      lastFastingDate: fields[26] as DateTime?,
      totalFastDays: fields[27] as int,
      enableTasbihHaptics: fields[28] as bool,
      enableTasbihSound: fields[29] as bool,
      defaultTasbihTarget: fields[30] as int,
    );
  }

  @override
  void write(BinaryWriter writer, UserSettings obj) {
    writer
      ..writeByte(31)
      ..writeByte(0)
      ..write(obj.languageCode)
      ..writeByte(1)
      ..write(obj.latitude)
      ..writeByte(2)
      ..write(obj.longitude)
      ..writeByte(3)
      ..write(obj.locationName)
      ..writeByte(4)
      ..write(obj.countryCode)
      ..writeByte(5)
      ..write(obj.calculationMethod)
      ..writeByte(6)
      ..write(obj.madhab)
      ..writeByte(7)
      ..write(obj.fajrAngle)
      ..writeByte(8)
      ..write(obj.ishaAngle)
      ..writeByte(9)
      ..write(obj.enablePrayerNotifications)
      ..writeByte(10)
      ..write(obj.enablePrePrayerNotifications)
      ..writeByte(11)
      ..write(obj.prePrayerNotificationMinutes)
      ..writeByte(12)
      ..write(obj.enableFastingNotifications)
      ..writeByte(13)
      ..write(obj.enableSuhoorNotification)
      ..writeByte(14)
      ..write(obj.enableIftarNotification)
      ..writeByte(15)
      ..write(obj.enableVibration)
      ..writeByte(16)
      ..write(obj.use24HourFormat)
      ..writeByte(17)
      ..write(obj.showArabicInPrayerTimes)
      ..writeByte(18)
      ..write(obj.showTransliteration)
      ..writeByte(19)
      ..write(obj.hasCompletedOnboarding)
      ..writeByte(20)
      ..write(obj.firstLaunchDate)
      ..writeByte(21)
      ..write(obj.themeMode)
      ..writeByte(22)
      ..write(obj.ramadanYear)
      ..writeByte(23)
      ..write(obj.ramadanDay)
      ..writeByte(24)
      ..write(obj.currentStreak)
      ..writeByte(25)
      ..write(obj.longestStreak)
      ..writeByte(26)
      ..write(obj.lastFastingDate)
      ..writeByte(27)
      ..write(obj.totalFastDays)
      ..writeByte(28)
      ..write(obj.enableTasbihHaptics)
      ..writeByte(29)
      ..write(obj.enableTasbihSound)
      ..writeByte(30)
      ..write(obj.defaultTasbihTarget);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
