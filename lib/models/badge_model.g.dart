// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BadgeModelAdapter extends TypeAdapter<BadgeModel> {
  @override
  final int typeId = 6;

  @override
  BadgeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BadgeModel(
      id: fields[0] as String,
      name: fields[1] as String,
      nameBn: fields[2] as String,
      description: fields[3] as String,
      descriptionBn: fields[4] as String,
      iconName: fields[5] as String,
      category: fields[6] as String,
      rarity: fields[7] as String,
      requirement: fields[8] as int,
      requirementType: fields[9] as String,
      isUnlocked: fields[10] as bool,
      unlockedAt: fields[11] as DateTime?,
      points: fields[12] as int,
    );
  }

  @override
  void write(BinaryWriter writer, BadgeModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.nameBn)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.descriptionBn)
      ..writeByte(5)
      ..write(obj.iconName)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.rarity)
      ..writeByte(8)
      ..write(obj.requirement)
      ..writeByte(9)
      ..write(obj.requirementType)
      ..writeByte(10)
      ..write(obj.isUnlocked)
      ..writeByte(11)
      ..write(obj.unlockedAt)
      ..writeByte(12)
      ..write(obj.points);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BadgeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
