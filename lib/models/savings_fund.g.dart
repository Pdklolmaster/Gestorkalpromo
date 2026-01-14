// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_fund.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavingsFundAdapter extends TypeAdapter<SavingsFund> {
  @override
  final int typeId = 3;

  @override
  SavingsFund read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavingsFund(
      id: fields[0] as String,
      name: fields[1] as String,
      targetAmount: fields[2] as double,
      currentAmount: fields[3] as double,
      icon: fields[4] as String,
      colorValue: fields[5] as int,
      createdAt: fields[6] as DateTime,
      targetDate: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SavingsFund obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.targetAmount)
      ..writeByte(3)
      ..write(obj.currentAmount)
      ..writeByte(4)
      ..write(obj.icon)
      ..writeByte(5)
      ..write(obj.colorValue)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.targetDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavingsFundAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
