import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';

/// Serviço para gerenciar parcelamentos e contas fixas
class InstallmentService {
  static Box<Transaction> get _transactionBox => 
      Hive.box<Transaction>('transactions');

  /// Cria parcelas a partir de um gasto parcelado
  static Future<List<Transaction>> createInstallments({
    required String title,
    required double totalAmount,
    required int installments,
    required String category,
    required DateTime startDate,
  }) async {
    final installmentAmount = totalAmount / installments;
    final groupId = 'inst_${DateTime.now().millisecondsSinceEpoch}';
    final List<Transaction> createdTransactions = [];

    for (int i = 1; i <= installments; i++) {
      // Calcular data de cada parcela
      final installmentDate = DateTime(
        startDate.year,
        startDate.month + (i - 1),
        startDate.day,
      );

      final transaction = Transaction(
        title: title,
        amount: installmentAmount,
        category: category,
        date: installmentDate,
        isFixed: false,
        totalInstallments: installments,
        currentInstallment: i,
        installmentGroupId: groupId,
        totalAmount: totalAmount,
      );

      await _transactionBox.add(transaction);
      createdTransactions.add(transaction);
    }

    return createdTransactions;
  }

  /// Obtém todas as parcelas de um grupo
  static List<Transaction> getInstallmentsByGroup(String groupId) {
    return _transactionBox.values
        .where((t) => t.installmentGroupId == groupId)
        .toList()
      ..sort((a, b) => a.currentInstallment!.compareTo(b.currentInstallment!));
  }

  /// Obtém parcelas pendentes (futuras)
  static List<Transaction> getPendingInstallments() {
    final now = DateTime.now();
    return _transactionBox.values
        .where((t) => 
            t.isInstallment && 
            t.date.isAfter(DateTime(now.year, now.month, now.day)))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Cancela todas as parcelas futuras de um grupo
  static Future<int> cancelFutureInstallments(String groupId) async {
    final now = DateTime.now();
    final futureInstallments = _transactionBox.values
        .where((t) => 
            t.installmentGroupId == groupId && 
            t.date.isAfter(DateTime(now.year, now.month, now.day)))
        .toList();

    for (final transaction in futureInstallments) {
      await transaction.delete();
    }

    return futureInstallments.length;
  }

  /// Gera contas fixas para o mês atual
  static Future<List<Transaction>> generateFixedExpensesForMonth({
    required int year,
    required int month,
  }) async {
    final fixedExpenses = _transactionBox.values
        .where((t) => t.isFixed && t.dueDay != null)
        .toList();

    final List<Transaction> generated = [];
    
    // Agrupa por título para evitar duplicatas
    final Map<String, Transaction> uniqueFixed = {};
    for (final expense in fixedExpenses) {
      final key = '${expense.title}_${expense.dueDay}';
      if (!uniqueFixed.containsKey(key) || 
          expense.date.isAfter(uniqueFixed[key]!.date)) {
        uniqueFixed[key] = expense;
      }
    }

    for (final expense in uniqueFixed.values) {
      // Verifica se já existe para este mês
      final existsThisMonth = _transactionBox.values.any((t) =>
          t.title == expense.title &&
          t.isFixed &&
          t.date.year == year &&
          t.date.month == month);

      if (!existsThisMonth) {
        final newDate = DateTime(year, month, expense.dueDay!);
        final newExpense = Transaction(
          title: expense.title,
          amount: expense.amount,
          category: expense.category,
          date: newDate,
          isFixed: true,
          dueDay: expense.dueDay,
        );

        await _transactionBox.add(newExpense);
        generated.add(newExpense);
      }
    }

    return generated;
  }

  /// Obtém resumo de parcelamentos ativos
  static Map<String, dynamic> getInstallmentsSummary() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);

    final allInstallments = _transactionBox.values
        .where((t) => t.isInstallment)
        .toList();

    // Agrupa por groupId
    final Map<String, List<Transaction>> groups = {};
    for (final t in allInstallments) {
      if (t.installmentGroupId != null) {
        groups.putIfAbsent(t.installmentGroupId!, () => []).add(t);
      }
    }

    double thisMonthTotal = 0;
    double futureTotal = 0;
    int activeGroups = 0;

    for (final group in groups.values) {
      group.sort((a, b) => a.date.compareTo(b.date));
      
      // Verifica se ainda tem parcelas futuras
      if (group.any((t) => t.date.isAfter(now))) {
        activeGroups++;
      }

      for (final t in group) {
        if (t.date.isAfter(currentMonth) && t.date.isBefore(nextMonth)) {
          thisMonthTotal += t.amount;
        } else if (t.date.isAfter(nextMonth)) {
          futureTotal += t.amount;
        }
      }
    }

    return {
      'activeGroups': activeGroups,
      'thisMonthTotal': thisMonthTotal,
      'futureTotal': futureTotal,
      'totalGroups': groups.length,
    };
  }

  /// Obtém total de contas fixas do mês
  static double getFixedExpensesTotal({int? year, int? month}) {
    final now = DateTime.now();
    year ??= now.year;
    month ??= now.month;

    return _transactionBox.values
        .where((t) => 
            t.isFixed && 
            t.date.year == year && 
            t.date.month == month)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Lista contas fixas cadastradas (únicas)
  static List<Transaction> getUniqueFixedExpenses() {
    final fixedExpenses = _transactionBox.values
        .where((t) => t.isFixed)
        .toList();

    // Agrupa por título e pega o mais recente
    final Map<String, Transaction> unique = {};
    for (final expense in fixedExpenses) {
      if (!unique.containsKey(expense.title) || 
          expense.date.isAfter(unique[expense.title]!.date)) {
        unique[expense.title] = expense;
      }
    }

    return unique.values.toList();
  }
}
