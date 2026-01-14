import 'package:hive/hive.dart';

part 'recurring_expense.g.dart';

@HiveType(typeId: 2)
class RecurringExpense {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final String subcategory;

  @HiveField(5)
  final int dayOfMonth; // Dia do mês para cobrança

  @HiveField(6)
  final bool isActive;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime? lastProcessed;

  RecurringExpense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    this.subcategory = '',
    required this.dayOfMonth,
    this.isActive = true,
    required this.createdAt,
    this.lastProcessed,
  });

  RecurringExpense copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    String? subcategory,
    int? dayOfMonth,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastProcessed,
  }) {
    return RecurringExpense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastProcessed: lastProcessed ?? this.lastProcessed,
    );
  }
}
