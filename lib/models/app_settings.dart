import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 5)
class BudgetRollover {
  @HiveField(0)
  final String category;

  @HiveField(1)
  final int month; // 1-12

  @HiveField(2)
  final int year;

  @HiveField(3)
  final double rolledAmount; // Valor que sobrou/faltou

  @HiveField(4)
  final DateTime createdAt;

  BudgetRollover({
    required this.category,
    required this.month,
    required this.year,
    required this.rolledAmount,
    required this.createdAt,
  });
}

@HiveType(typeId: 6)
class AppSettings {
  @HiveField(0)
  final bool biometricEnabled;

  @HiveField(1)
  final bool budgetRolloverEnabled;

  @HiveField(2)
  final bool notificationsEnabled;

  @HiveField(3)
  final String currency;

  @HiveField(4)
  final int themeMode; // 0 = system, 1 = light, 2 = dark

  @HiveField(5)
  final List<String> favoriteCategories;

  @HiveField(6)
  final int lastLoginStreak; // Dias seguidos de uso

  @HiveField(7)
  final DateTime? lastActiveDate;

  AppSettings({
    this.biometricEnabled = false,
    this.budgetRolloverEnabled = true,
    this.notificationsEnabled = true,
    this.currency = 'BRL',
    this.themeMode = 2,
    this.favoriteCategories = const [],
    this.lastLoginStreak = 0,
    this.lastActiveDate,
  });

  AppSettings copyWith({
    bool? biometricEnabled,
    bool? budgetRolloverEnabled,
    bool? notificationsEnabled,
    String? currency,
    int? themeMode,
    List<String>? favoriteCategories,
    int? lastLoginStreak,
    DateTime? lastActiveDate,
  }) {
    return AppSettings(
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      budgetRolloverEnabled: budgetRolloverEnabled ?? this.budgetRolloverEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      currency: currency ?? this.currency,
      themeMode: themeMode ?? this.themeMode,
      favoriteCategories: favoriteCategories ?? this.favoriteCategories,
      lastLoginStreak: lastLoginStreak ?? this.lastLoginStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }
}
