import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  late String title;

  @HiveField(1)
  late double amount;

  @HiveField(2)
  late String category;

  @HiveField(3)
  late DateTime date;

  @HiveField(4)
  bool isFixed;

  @HiveField(5)
  int? totalInstallments;

  @HiveField(6)
  int? currentInstallment;

  @HiveField(7)
  String? installmentGroupId;

  @HiveField(8)
  double? totalAmount;

  @HiveField(9)
  int? dueDay;

  @HiveField(10)
  String? source; // NOVO: 'main' ou 'redeemed'

  Transaction({
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.isFixed = false,
    this.totalInstallments,
    this.currentInstallment,
    this.installmentGroupId,
    this.totalAmount,
    this.dueDay,
    this.source = 'main',
  });

  Transaction.empty()
      : title = '',
        amount = 0,
        category = 'Necessidade',
        date = DateTime.now(),
        isFixed = false,
        source = 'main';

  bool get isInstallment => totalInstallments != null && totalInstallments! > 1;

  String get installmentLabel => 
      isInstallment ? '$currentInstallment/$totalInstallments' : '';

  String get displayTitle => 
      isInstallment ? '$title ($installmentLabel)' : title;

  Transaction copyWith({
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    bool? isFixed,
    int? totalInstallments,
    int? currentInstallment,
    String? installmentGroupId,
    double? totalAmount,
    int? dueDay,
    String? source,
  }) {
    return Transaction(
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      isFixed: isFixed ?? this.isFixed,
      totalInstallments: totalInstallments ?? this.totalInstallments,
      currentInstallment: currentInstallment ?? this.currentInstallment,
      installmentGroupId: installmentGroupId ?? this.installmentGroupId,
      totalAmount: totalAmount ?? this.totalAmount,
      dueDay: dueDay ?? this.dueDay,
      source: source ?? this.source,
    );
  }
}

@HiveType(typeId: 1)
class UserData extends HiveObject {
  @HiveField(0)
  late double monthlyIncome;

  @HiveField(1)
  late DateTime lastUpdated;

  @HiveField(2)
  late double extraIncome;

  @HiveField(3)
  late double currentBalance;

  @HiveField(4)
  late double redeemedBalance; // NOVO: Saldo de resgates

  UserData({
    required this.monthlyIncome,
    required this.lastUpdated,
    this.extraIncome = 0,
    this.currentBalance = 0,
    this.redeemedBalance = 0,
  });

  UserData.empty()
      : monthlyIncome = 0,
        extraIncome = 0,
        currentBalance = 0,
        redeemedBalance = 0,
        lastUpdated = DateTime.now();

  double get expectedIncome => monthlyIncome + extraIncome;
  double get totalIncome => currentBalance;
}