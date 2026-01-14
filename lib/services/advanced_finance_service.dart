import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

/// Serviço de cálculos financeiros avançados
class AdvancedFinanceService {
  
  /// Gera dados para o Heatmap de gastos (calendário)
  static Map<DateTime, double> generateHeatmapData(List<Transaction> transactions) {
    Map<DateTime, double> heatmap = {};
    
    for (var t in transactions) {
      DateTime dateKey = DateTime(t.date.year, t.date.month, t.date.day);
      heatmap[dateKey] = (heatmap[dateKey] ?? 0) + t.amount;
    }
    
    return heatmap;
  }

  /// Intensidade da cor baseado no gasto (0.0 a 1.0)
  static double getHeatIntensity(double spent, double maxSpent) {
    if (maxSpent == 0) return 0;
    return (spent / maxSpent).clamp(0.0, 1.0);
  }

  /// Cor do heatmap baseado na intensidade
  static Color getHeatColor(double intensity) {
    if (intensity < 0.25) return Colors.green.shade200;
    if (intensity < 0.5) return Colors.yellow.shade300;
    if (intensity < 0.75) return Colors.orange.shade400;
    return Colors.red.shade500;
  }

  /// Comparativo mês atual vs anterior
  static Map<String, ComparisonData> compareMonths(
    List<Transaction> currentMonth,
    List<Transaction> previousMonth,
  ) {
    Map<String, ComparisonData> comparison = {};
    
    // Agrupa por categoria no mês atual
    Map<String, double> currentByCategory = {};
    for (var t in currentMonth) {
      currentByCategory[t.category] = (currentByCategory[t.category] ?? 0) + t.amount;
    }
    
    // Agrupa por categoria no mês anterior
    Map<String, double> previousByCategory = {};
    for (var t in previousMonth) {
      previousByCategory[t.category] = (previousByCategory[t.category] ?? 0) + t.amount;
    }
    
    // Calcula comparativo
    Set<String> allCategories = {...currentByCategory.keys, ...previousByCategory.keys};
    
    for (var category in allCategories) {
      double current = currentByCategory[category] ?? 0;
      double previous = previousByCategory[category] ?? 0;
      double difference = current - previous;
      double percentageChange = previous > 0 ? ((difference / previous) * 100) : (current > 0 ? 100 : 0);
      
      comparison[category] = ComparisonData(
        category: category,
        currentValue: current,
        previousValue: previous,
        difference: difference,
        percentageChange: percentageChange,
      );
    }
    
    return comparison;
  }

  /// Projeção de saldo para o final do mês
  static ProjectionResult projectEndOfMonth({
    required double currentBalance,
    required double monthlyIncome,
    required List<Transaction> transactionsThisMonth,
    required List<RecurringExpenseData> recurringExpenses,
  }) {
    DateTime now = DateTime.now();
    int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    int remainingDays = daysInMonth - now.day;
    
    // Total já gasto
    double totalSpent = transactionsThisMonth.fold(0, (sum, t) => sum + t.amount);
    
    // Gastos recorrentes pendentes
    double pendingRecurring = 0;
    for (var expense in recurringExpenses) {
      if (expense.dayOfMonth > now.day && expense.isActive) {
        pendingRecurring += expense.amount;
      }
    }
    
    // Média diária de gastos (excluindo recorrentes já pagos)
    double avgDailySpend = now.day > 0 ? totalSpent / now.day : 0;
    
    // Projeção de gastos variáveis restantes
    double projectedVariableSpend = avgDailySpend * remainingDays;
    
    // Saldo projetado
    double projectedBalance = monthlyIncome - totalSpent - pendingRecurring - projectedVariableSpend;
    
    return ProjectionResult(
      projectedBalance: projectedBalance,
      totalSpentSoFar: totalSpent,
      pendingRecurring: pendingRecurring,
      projectedVariableSpend: projectedVariableSpend,
      avgDailySpend: avgDailySpend,
      remainingDays: remainingDays,
      isPositive: projectedBalance >= 0,
    );
  }

  /// Calcula rolagem de orçamento
  static Map<String, double> calculateBudgetRollover({
    required double income,
    required List<Transaction> transactions,
    required Map<String, double>? previousRollover,
  }) {
    Map<String, double> rollover = {};
    
    // Orçamentos padrão 50/30/20
    Map<String, double> budgets = {
      'Necessidade': income * 0.5,
      'Desejo': income * 0.3,
      'Meta': income * 0.2,
    };
    
    // Gastos por categoria
    Map<String, double> spent = {};
    for (var t in transactions) {
      spent[t.category] = (spent[t.category] ?? 0) + t.amount;
    }
    
    // Calcula sobra/falta + rollover anterior
    for (var category in budgets.keys) {
      double budget = budgets[category]!;
      double prevRoll = previousRollover?[category] ?? 0;
      double categorySpent = spent[category] ?? 0;
      
      // Budget ajustado = budget base + rollover anterior
      double adjustedBudget = budget + prevRoll;
      
      // Sobra para rolar
      rollover[category] = adjustedBudget - categorySpent;
    }
    
    return rollover;
  }

  /// Função para retirada de investimento/poupança de carteiras
  /// 
  /// Opções de retirada:
  /// 1 = "Conta Renda Extra" - Retira somente de extraIncome
  /// 2 = "Carteira Salarial" - Retira somente de monthlyIncome
  /// 3 = "Ambas Carteiras" - Retira proporcionalmente 50% de cada
  static WithdrawalResult withdrawForInvestment({
    required double monthlyIncome,
    required double extraIncome,
    required double amountNeeded,
    required int withdrawalOption, // 1, 2 ou 3
  }) {
    double withdrawn = 0;
    double fromMonthly = 0;
    double fromExtra = 0;
    String message = '';
    bool success = false;

    switch (withdrawalOption) {
      case 1: // Conta Renda Extra
        if (extraIncome >= amountNeeded) {
          withdrawn = amountNeeded;
          fromExtra = amountNeeded;
          success = true;
          message = 'Retirado R\$ ${amountNeeded.toStringAsFixed(2)} da Renda Extra';
        } else {
          message = 'Saldo insuficiente na Renda Extra. Precisa de R\$ ${amountNeeded.toStringAsFixed(2)}, disponível R\$ ${extraIncome.toStringAsFixed(2)}';
        }
        break;

      case 2: // Carteira Salarial
        if (monthlyIncome >= amountNeeded) {
          withdrawn = amountNeeded;
          fromMonthly = amountNeeded;
          success = true;
          message = 'Retirado R\$ ${amountNeeded.toStringAsFixed(2)} da Carteira Salarial';
        } else {
          message = 'Saldo insuficiente na Carteira Salarial. Precisa de R\$ ${amountNeeded.toStringAsFixed(2)}, disponível R\$ ${monthlyIncome.toStringAsFixed(2)}';
        }
        break;

      case 3: // Ambas Carteiras - 50% cada
        double needed50 = amountNeeded / 2;
        
        // Tenta retirar 50% de cada
        if (monthlyIncome >= needed50 && extraIncome >= needed50) {
          // Ambas têm o suficiente
          fromMonthly = needed50;
          fromExtra = needed50;
          withdrawn = amountNeeded;
          success = true;
          message = 'Retirado R\$ ${needed50.toStringAsFixed(2)} de cada carteira';
        } else if (monthlyIncome >= needed50) {
          // Mensal tem 50%, extra não - pega o que tiver de extra e completa com mensal
          fromExtra = extraIncome;
          double remaining = amountNeeded - fromExtra;
          if (monthlyIncome >= remaining) {
            fromMonthly = remaining;
            withdrawn = amountNeeded;
            success = true;
            message = 'Retirado R\$ ${fromExtra.toStringAsFixed(2)} de Renda Extra e R\$ ${fromMonthly.toStringAsFixed(2)} de Salarial';
          } else {
            // Não consegue nem com ambas
            withdrawn = 0;
            message = 'Saldo insuficiente. Precisa de R\$ ${amountNeeded.toStringAsFixed(2)}, disponível R\$ ${(monthlyIncome + extraIncome).toStringAsFixed(2)}';
          }
        } else if (extraIncome >= needed50) {
          // Extra tem 50%, mensal não
          fromMonthly = monthlyIncome;
          double remaining = amountNeeded - fromMonthly;
          if (extraIncome >= remaining) {
            fromExtra = remaining;
            withdrawn = amountNeeded;
            success = true;
            message = 'Retirado R\$ ${fromMonthly.toStringAsFixed(2)} de Salarial e R\$ ${fromExtra.toStringAsFixed(2)} de Renda Extra';
          } else {
            // Não consegue nem com ambas
            withdrawn = 0;
            message = 'Saldo insuficiente. Precisa de R\$ ${amountNeeded.toStringAsFixed(2)}, disponível R\$ ${(monthlyIncome + extraIncome).toStringAsFixed(2)}';
          }
        } else {
          // Nenhuma tem 50%
          withdrawn = 0;
          message = 'Saldo insuficiente. Precisa de R\$ ${amountNeeded.toStringAsFixed(2)}, disponível R\$ ${(monthlyIncome + extraIncome).toStringAsFixed(2)}';
        }
        break;

      default:
        message = 'Opção de retirada inválida';
    }

    return WithdrawalResult(
      success: success,
      amountWithdrawn: withdrawn,
      fromMonthlyIncome: fromMonthly,
      fromExtraIncome: fromExtra,
      message: message,
    );
  }

  /// Analisa padrões de gastos
  static SpendingPattern analyzePatterns(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return SpendingPattern.empty();
    }

    // Gastos por dia da semana
    Map<int, double> byWeekday = {};
    Map<int, int> countByWeekday = {};
    
    for (var t in transactions) {
      int weekday = t.date.weekday;
      byWeekday[weekday] = (byWeekday[weekday] ?? 0) + t.amount;
      countByWeekday[weekday] = (countByWeekday[weekday] ?? 0) + 1;
    }
    
    // Encontra dia com mais gastos
    int maxSpendDay = 1;
    double maxSpend = 0;
    byWeekday.forEach((day, amount) {
      if (amount > maxSpend) {
        maxSpend = amount;
        maxSpendDay = day;
      }
    });
    
    // Calcula se gasta mais no fim de semana
    double weekendSpend = (byWeekday[6] ?? 0) + (byWeekday[7] ?? 0);
    double weekdaySpend = (byWeekday[1] ?? 0) + (byWeekday[2] ?? 0) + 
                          (byWeekday[3] ?? 0) + (byWeekday[4] ?? 0) + 
                          (byWeekday[5] ?? 0);
    
    double total = weekendSpend + weekdaySpend;
    double weekendPercentage = total > 0 ? (weekendSpend / total) * 100 : 0;
    
    return SpendingPattern(
      maxSpendWeekday: maxSpendDay,
      weekendSpendPercentage: weekendPercentage,
      avgTransactionValue: transactions.fold(0.0, (sum, t) => sum + t.amount) / transactions.length,
      totalTransactions: transactions.length,
      spendsByWeekday: byWeekday,
    );
  }
}

class ComparisonData {
  final String category;
  final double currentValue;
  final double previousValue;
  final double difference;
  final double percentageChange;

  ComparisonData({
    required this.category,
    required this.currentValue,
    required this.previousValue,
    required this.difference,
    required this.percentageChange,
  });

  bool get isIncrease => difference > 0;
  bool get isDecrease => difference < 0;
}

class ProjectionResult {
  final double projectedBalance;
  final double totalSpentSoFar;
  final double pendingRecurring;
  final double projectedVariableSpend;
  final double avgDailySpend;
  final int remainingDays;
  final bool isPositive;

  ProjectionResult({
    required this.projectedBalance,
    required this.totalSpentSoFar,
    required this.pendingRecurring,
    required this.projectedVariableSpend,
    required this.avgDailySpend,
    required this.remainingDays,
    required this.isPositive,
  });
}

class RecurringExpenseData {
  final String title;
  final double amount;
  final int dayOfMonth;
  final bool isActive;

  RecurringExpenseData({
    required this.title,
    required this.amount,
    required this.dayOfMonth,
    required this.isActive,
  });
}

class SpendingPattern {
  final int maxSpendWeekday;
  final double weekendSpendPercentage;
  final double avgTransactionValue;
  final int totalTransactions;
  final Map<int, double> spendsByWeekday;

  SpendingPattern({
    required this.maxSpendWeekday,
    required this.weekendSpendPercentage,
    required this.avgTransactionValue,
    required this.totalTransactions,
    required this.spendsByWeekday,
  });

  factory SpendingPattern.empty() {
    return SpendingPattern(
      maxSpendWeekday: 1,
      weekendSpendPercentage: 0,
      avgTransactionValue: 0,
      totalTransactions: 0,
      spendsByWeekday: {},
    );
  }

  String get maxSpendDayName {
    const days = ['', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];
    return days[maxSpendWeekday];
  }

  bool get spendsMoreOnWeekends => weekendSpendPercentage > 40; // 2/7 = 28.5%, então >40% é significativo
}

/// Resultado da retirada de investimento de carteiras
class WithdrawalResult {
  final bool success;
  final double amountWithdrawn;
  final double fromMonthlyIncome;
  final double fromExtraIncome;
  final String message;

  WithdrawalResult({
    required this.success,
    required this.amountWithdrawn,
    required this.fromMonthlyIncome,
    required this.fromExtraIncome,
    required this.message,
  });

  double get totalWithdrawn => fromMonthlyIncome + fromExtraIncome;
}
