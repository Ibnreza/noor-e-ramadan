// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_times_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrayerTimesModelAdapter extends TypeAdapter<PrayerTimesModel> {
  @override
  final int typeId = 1;

  @override
  PrayerTimesModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrayerTimesModel(
      date: fields[0] as DateTime,
      fajr: fields[1] as DateTime,
      sunrise: fields[2] as DateTime,
      dhuhr: fields[3] as DateTime,
      asr: fields[4] as DateTime,
      maghrib: fields[5] as DateTime,
      isha: fields[6] as DateTime,
      imsak: fields[7] as DateTime,
      latitude: fields[8] as double,
      longitude: fields[9] as double,
      timezone: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PrayerTimesModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.fajr)
      ..writeByte(2)
      ..write(obj.sunrise)
      ..writeByte(3)
      ..write(obj.dhuhr)
      ..writeByte(4)
      ..write(obj.asr)
      ..writeByte(5)
      ..write(obj.maghrib)
      ..writeByte(6)
      ..write(obj.isha)
      ..writeByte(7)
      ..write(obj.imsak)
      ..writeByte(8)
      ..write(obj.latitude)
      ..writeByte(9)
      ..write(obj.longitude)
      ..writeByte(10)
      ..write(obj.timezone);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerTimesModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
