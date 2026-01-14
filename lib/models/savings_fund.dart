import 'package:hive/hive.dart';

part 'savings_fund.g.dart';

@HiveType(typeId: 3)
class SavingsFund {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name; // Ex: "Reserva de Emergência", "Viagem"

  @HiveField(2)
  final double targetAmount; // Meta

  @HiveField(3)
  final double currentAmount; // Valor atual

  @HiveField(4)
  final String icon; // Emoji ou nome do ícone

  @HiveField(5)
  final int colorValue; // Cor em int

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime? targetDate; // Data meta para atingir

  SavingsFund({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0,
    this.icon = '💰',
    this.colorValue = 0xFF4CAF50,
    required this.createdAt,
    this.targetDate,
  });

  double get progressPercentage => 
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0, 1) : 0;

  double get remainingAmount => (targetAmount - currentAmount).clamp(0, double.infinity);

  SavingsFund copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    String? icon,
    int? colorValue,
    DateTime? createdAt,
    DateTime? targetDate,
  }) {
    return SavingsFund(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      icon: icon ?? this.icon,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
      targetDate: targetDate ?? this.targetDate,
    );
  }
}
