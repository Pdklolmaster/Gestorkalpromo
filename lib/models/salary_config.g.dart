// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'salary_config.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SalaryConfigAdapter extends TypeAdapter<SalaryConfig> {
  @override
  final int typeId = 7;

  @override
  SalaryConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SalaryConfig(
      amount: fields[0] as double,
      paymentDay: fields[1] as int,
      lastPaymentDate: fields[2] as DateTime?,
      isActive: fields[3] as bool,
      description: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SalaryConfig obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.amount)
      ..writeByte(1)
      ..write(obj.paymentDay)
      ..writeByte(2)
      ..write(obj.lastPaymentDate)
      ..writeByte(3)
      ..write(obj.isActive)
      ..writeByte(4)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SalaryConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
