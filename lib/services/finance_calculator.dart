import '../models/transaction_model.dart';

class FinanceCalculator {
  static const double necessityPercentage = 0.50;
  static const double desirePercentage = 0.30;
  static const double goalPercentage = 0.20;

  static double getTotalSpent(List<Transaction> transactions, String category) {
    return transactions
        .where((t) => t.category == category)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  static double getTotalSpentAllCategories(List<Transaction> transactions) {
    return transactions.fold(0.0, (sum, item) => sum + item.amount);
  }

  static Map<String, double> getBudgets(double income) {
    return {
      'Necessidade': income * necessityPercentage,
      'Desejos Lazer': income * desirePercentage,
      'Investimento': income * goalPercentage,
    };
  }

  static Map<String, double> getSpentByCategory(List<Transaction> transactions) {
    return {
      'Necessidade': getTotalSpent(transactions, 'Necessidade'),
      'Desejos Lazer': getTotalSpent(transactions, 'Desejos Lazer'),
      'Investimento': getTotalSpent(transactions, 'Investimento'),
    };
  }

  static Map<String, double> getProgressPercentage(
    double income,
    List<Transaction> transactions,
  ) {
    final budgets = getBudgets(income);
    final spent = getSpentByCategory(transactions);

    return {
      'Necessidade': spent['Necessidade']! / budgets['Necessidade']!,
      'Desejos Lazer': spent['Desejos Lazer']! / budgets['Desejos Lazer']!,
      'Investimento': spent['Investimento']! / budgets['Investimento']!,
    };
  }

  static double getRemainingBudget(
    double income,
    String category,
    List<Transaction> transactions,
  ) {
    final budgets = getBudgets(income);
    final spent = getTotalSpent(transactions, category);
    return (budgets[category] ?? 0) - spent;
  }
}
