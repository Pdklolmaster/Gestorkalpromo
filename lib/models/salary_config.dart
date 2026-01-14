import 'package:hive/hive.dart';

part 'salary_config.g.dart';

/// Configuração do salário mensal recorrente
@HiveType(typeId: 7)
class SalaryConfig extends HiveObject {
  @HiveField(0)
  late double amount; // Valor do salário

  @HiveField(1)
  late int paymentDay; // Dia do mês para receber (1-31)

  @HiveField(2)
  late DateTime? lastPaymentDate; // Última data de pagamento processada

  @HiveField(3)
  late bool isActive; // Se está ativo

  @HiveField(4)
  late String description; // Descrição (ex: "Salário Empresa X")

  SalaryConfig({
    required this.amount,
    required this.paymentDay,
    this.lastPaymentDate,
    this.isActive = true,
    this.description = 'Salário Mensal',
  });

  SalaryConfig.empty()
      : amount = 0,
        paymentDay = 5,
        lastPaymentDate = null,
        isActive = false,
        description = 'Salário Mensal';

  /// Verifica se o salário deve ser pago hoje
  bool shouldPayToday() {
    if (!isActive || amount <= 0) return false;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Calcular o dia de pagamento deste mês
    int actualPaymentDay = paymentDay;
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    if (paymentDay > daysInMonth) {
      actualPaymentDay = daysInMonth;
    }
    
    // Verificar se hoje é dia de pagamento
    if (today.day != actualPaymentDay) return false;
    
    // Verificar se já foi pago este mês
    if (lastPaymentDate != null) {
      final lastPayment = DateTime(
        lastPaymentDate!.year, 
        lastPaymentDate!.month, 
        lastPaymentDate!.day
      );
      if (lastPayment.year == today.year && lastPayment.month == today.month) {
        return false; // Já foi pago este mês
      }
    }
    
    return true;
  }

  /// Marca como pago
  void markAsPaid() {
    lastPaymentDate = DateTime.now();
  }

  SalaryConfig copyWith({
    double? amount,
    int? paymentDay,
    DateTime? lastPaymentDate,
    bool? isActive,
    String? description,
  }) {
    return SalaryConfig(
      amount: amount ?? this.amount,
      paymentDay: paymentDay ?? this.paymentDay,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
    );
  }
}
