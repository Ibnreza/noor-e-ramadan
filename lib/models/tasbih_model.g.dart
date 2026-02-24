// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tasbih_model.dart';

// Stub Hive adapter for web compatibility
class TasbihSessionAdapter extends TypeAdapter<TasbihSession> {
  @override
  final typeId = 2;

  @override
  TasbihSession read(BinaryReader reader) {
    throw UnsupportedError('Hive persistence not supported on web');
  }

  @override
  void write(BinaryWriter writer, TasbihSession obj) {
    throw UnsupportedError('Hive persistence not supported on web');
  }
}

class DhikrTypeAdapter extends TypeAdapter<DhikrType> {
  @override
  final typeId = 4;

  @override
  DhikrType read(BinaryReader reader) {
    throw UnsupportedError('Hive persistence not supported on web');
  }

  @override
  void write(BinaryWriter writer, DhikrType obj) {
    throw UnsupportedError('Hive persistence not supported on web');
  }
}

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TasbihSessionAdapter extends TypeAdapter<TasbihSession> {
  @override
  final int typeId = 2;

  @override
  TasbihSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TasbihSession(
      id: fields[0] as String,
      dhikrType: fields[1] as DhikrType,
      startTime: fields[2] as DateTime,
      endTime: fields[3] as DateTime?,
      count: fields[4] as int,
      targetCount: fields[5] as int,
      customDhikrText: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TasbihSession obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.dhikrType)
      ..writeByte(2)
      ..write(obj.startTime)
      ..writeByte(3)
      ..write(obj.endTime)
      ..writeByte(4)
      ..write(obj.count)
      ..writeByte(5)
      ..write(obj.targetCount)
      ..writeByte(6)
      ..write(obj.customDhikrText);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TasbihSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DailyTasbihSummaryAdapter extends TypeAdapter<DailyTasbihSummary> {
  @override
  final int typeId = 5;

  @override
  DailyTasbihSummary read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyTasbihSummary(
      date: fields[0] as DateTime,
      dhikrCounts: (fields[1] as Map).cast<DhikrType, int>(),
      totalCount: fields[2] as int,
      sessionsCompleted: fields[3] as int,
      goalsReached: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DailyTasbihSummary obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.dhikrCounts)
      ..writeByte(2)
      ..write(obj.totalCount)
      ..writeByte(3)
      ..write(obj.sessionsCompleted)
      ..writeByte(4)
      ..write(obj.goalsReached);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyTasbihSummaryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DhikrTypeAdapter extends TypeAdapter<DhikrType> {
  @override
  final int typeId = 4;

  @override
  DhikrType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DhikrType.allah;
      case 1:
        return DhikrType.subhanAllah;
      case 2:
        return DhikrType.alhamdulillah;
      case 3:
        return DhikrType.allahuAkbar;
      case 4:
        return DhikrType.astaghfirullah;
      case 5:
        return DhikrType.laIlahaIllallah;
      case 6:
        return DhikrType.salawat;
      case 7:
        return DhikrType.hasbunallahu;
      case 8:
        return DhikrType.bismillah;
      case 9:
        return DhikrType.laHawla;
      case 10:
        return DhikrType.subhanAllahi;
      case 11:
        return DhikrType.rabbanaghfirli;
      case 12:
        return DhikrType.allahummaAmin;
      case 13:
        return DhikrType.tahmid;
      case 14:
        return DhikrType.takbir;
      case 15:
        return DhikrType.tasbih;
      case 16:
        return DhikrType.custom;
      default:
        return DhikrType.allah;
    }
  }

  @override
  void write(BinaryWriter writer, DhikrType obj) {
    switch (obj) {
      case DhikrType.allah:
        writer.writeByte(0);
        break;
      case DhikrType.subhanAllah:
        writer.writeByte(1);
        break;
      case DhikrType.alhamdulillah:
        writer.writeByte(2);
        break;
      case DhikrType.allahuAkbar:
        writer.writeByte(3);
        break;
      case DhikrType.astaghfirullah:
        writer.writeByte(4);
        break;
      case DhikrType.laIlahaIllallah:
        writer.writeByte(5);
        break;
      case DhikrType.salawat:
        writer.writeByte(6);
        break;
      case DhikrType.hasbunallahu:
        writer.writeByte(7);
        break;
      case DhikrType.bismillah:
        writer.writeByte(8);
        break;
      case DhikrType.laHawla:
        writer.writeByte(9);
        break;
      case DhikrType.subhanAllahi:
        writer.writeByte(10);
        break;
      case DhikrType.rabbanaghfirli:
        writer.writeByte(11);
        break;
      case DhikrType.allahummaAmin:
        writer.writeByte(12);
        break;
      case DhikrType.tahmid:
        writer.writeByte(13);
        break;
      case DhikrType.takbir:
        writer.writeByte(14);
        break;
      case DhikrType.tasbih:
        writer.writeByte(15);
        break;
      case DhikrType.custom:
        writer.writeByte(16);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DhikrTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
