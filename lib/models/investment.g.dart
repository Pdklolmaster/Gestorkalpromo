// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InvestmentAdapter extends TypeAdapter<Investment> {
  @override
  final int typeId = 10;

  @override
  Investment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Investment(
      id: fields[0] as String,
      name: fields[1] as String,
      investedAmount: fields[2] as double,
      currentAmount: fields[3] as double?,
      interestRate: fields[4] as double,
      interestType: fields[5] as InterestType,
      createdAt: fields[6] as DateTime,
      lastYieldDate: fields[7] as DateTime?,
      autoReinvest: fields[8] as bool,
      icon: fields[9] as String,
      colorValue: fields[10] as int,
      yieldHistory: (fields[11] as List?)?.cast<YieldRecord>(),
    );
  }

  @override
  void write(BinaryWriter writer, Investment obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.investedAmount)
      ..writeByte(3)
      ..write(obj.currentAmount)
      ..writeByte(4)
      ..write(obj.interestRate)
      ..writeByte(5)
      ..write(obj.interestType)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.lastYieldDate)
      ..writeByte(8)
      ..write(obj.autoReinvest)
      ..writeByte(9)
      ..write(obj.icon)
      ..writeByte(10)
      ..write(obj.colorValue)
      ..writeByte(11)
      ..write(obj.yieldHistory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvestmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class YieldRecordAdapter extends TypeAdapter<YieldRecord> {
  @override
  final int typeId = 12;

  @override
  YieldRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return YieldRecord(
      date: fields[0] as DateTime,
      amount: fields[1] as double,
      balanceBefore: fields[2] as double,
      balanceAfter: fields[3] as double,
      reinvested: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, YieldRecord obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.balanceBefore)
      ..writeByte(3)
      ..write(obj.balanceAfter)
      ..writeByte(4)
      ..write(obj.reinvested);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YieldRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InterestTypeAdapter extends TypeAdapter<InterestType> {
  @override
  final int typeId = 11;

  @override
  InterestType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return InterestType.monthly;
      case 1:
        return InterestType.annual;
      default:
        return InterestType.monthly;
    }
  }

  @override
  void write(BinaryWriter writer, InterestType obj) {
    switch (obj) {
      case InterestType.monthly:
        writer.writeByte(0);
        break;
      case InterestType.annual:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InterestTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
