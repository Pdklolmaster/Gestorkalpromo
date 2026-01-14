import 'package:hive/hive.dart';

part 'investment.g.dart';

/// Modelo de Investimento com rendimento automático
@HiveType(typeId: 10)
class Investment extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name; // Ex: "Caixinha Nubank", "CDB 100%"

  @HiveField(2)
  late double investedAmount; // Valor investido inicial

  @HiveField(3)
  late double currentAmount; // Valor atual (com rendimentos)

  @HiveField(4)
  late double interestRate; // Taxa de juros (ex: 0.10 = 10%)

  @HiveField(5)
  late InterestType interestType; // Mensal ou Anual

  @HiveField(6)
  late DateTime createdAt;

  @HiveField(7)
  late DateTime lastYieldDate; // Última data que rendeu

  @HiveField(8)
  late bool autoReinvest; // Reinveste automaticamente?

  @HiveField(9)
  late String icon;

  @HiveField(10)
  late int colorValue;

  @HiveField(11)
  late List<YieldRecord> yieldHistory; // Histórico de rendimentos

  Investment({
    required this.id,
    required this.name,
    required this.investedAmount,
    double? currentAmount,
    this.interestRate = 0.01, // 1% default
    this.interestType = InterestType.monthly,
    required this.createdAt,
    DateTime? lastYieldDate,
    this.autoReinvest = true,
    this.icon = '📈',
    this.colorValue = 0xFF4CAF50,
    List<YieldRecord>? yieldHistory,
  }) : currentAmount = currentAmount ?? investedAmount,
       lastYieldDate = lastYieldDate ?? createdAt,
       yieldHistory = yieldHistory ?? [];

  /// Calcula o rendimento total acumulado
  double get totalYield => currentAmount - investedAmount;

  /// Calcula a porcentagem de rendimento
  double get yieldPercentage => 
      investedAmount > 0 ? (totalYield / investedAmount) * 100 : 0;

  /// Taxa diária (baseada na taxa mensal ou anual)
  double get dailyRate {
    if (interestType == InterestType.monthly) {
      return interestRate / 30;
    } else {
      return interestRate / 365;
    }
  }

  /// Calcula o rendimento pro-rata para um período
  double calculateYield(int days) {
    return currentAmount * dailyRate * days;
  }

  /// Aplica rendimento e retorna o valor ganho
  double applyYield(int days) {
    double yield = calculateYield(days);
    if (autoReinvest) {
      currentAmount += yield;
    }
    return yield;
  }

  Investment copyWith({
    String? id,
    String? name,
    double? investedAmount,
    double? currentAmount,
    double? interestRate,
    InterestType? interestType,
    DateTime? createdAt,
    DateTime? lastYieldDate,
    bool? autoReinvest,
    String? icon,
    int? colorValue,
    List<YieldRecord>? yieldHistory,
  }) {
    return Investment(
      id: id ?? this.id,
      name: name ?? this.name,
      investedAmount: investedAmount ?? this.investedAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      interestRate: interestRate ?? this.interestRate,
      interestType: interestType ?? this.interestType,
      createdAt: createdAt ?? this.createdAt,
      lastYieldDate: lastYieldDate ?? this.lastYieldDate,
      autoReinvest: autoReinvest ?? this.autoReinvest,
      icon: icon ?? this.icon,
      colorValue: colorValue ?? this.colorValue,
      yieldHistory: yieldHistory ?? List.from(this.yieldHistory),
    );
  }
}

/// Tipo de juros
@HiveType(typeId: 11)
enum InterestType {
  @HiveField(0)
  monthly,
  
  @HiveField(1)
  annual,
}

/// Registro de rendimento
@HiveType(typeId: 12)
class YieldRecord {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final double balanceBefore;

  @HiveField(3)
  final double balanceAfter;

  @HiveField(4)
  final bool reinvested;

  YieldRecord({
    required this.date,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    this.reinvested = true,
  });
}
