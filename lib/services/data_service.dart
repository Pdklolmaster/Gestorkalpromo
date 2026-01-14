import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';
import '../models/salary_config.dart';
import '../models/app_settings.dart';
import '../models/investment.dart';
import '../models/recurring_expense.dart';
import '../models/savings_fund.dart';
import '../models/achievement.dart';

class DataService {
  static const String transactionsBoxName = 'transactions';
  static const String userDataBoxName = 'userData';
  static const String salaryConfigBoxName = 'salaryConfig';
  static const String appSettingsBoxName = 'appSettings';
  
  // Boxes para backup
  static const String investmentsBoxName = 'investments';
  static const String recurringExpensesBoxName = 'recurringExpenses';
  static const String savingsFundsBoxName = 'savingsFunds';
  static const String achievementsBoxName = 'achievements';

  late Box<Transaction> _transactionsBox;
  late Box<UserData> _userDataBox;
  late Box<SalaryConfig> _salaryConfigBox;
  late Box<AppSettings> _appSettingsBox;
  
  // Boxes extras
  late Box<Investment> _investmentsBox;
  late Box<RecurringExpense> _recurringExpensesBox;
  late Box<SavingsFund> _savingsFundsBox;
  late Box<Achievement> _achievementsBox;

  Future<void> init() async {
    _transactionsBox = await Hive.openBox<Transaction>(transactionsBoxName);
    _userDataBox = await Hive.openBox<UserData>(userDataBoxName);
    _salaryConfigBox = await Hive.openBox<SalaryConfig>(salaryConfigBoxName);
    _appSettingsBox = await Hive.openBox<AppSettings>(appSettingsBoxName);
    
    _investmentsBox = await Hive.openBox<Investment>(investmentsBoxName);
    _recurringExpensesBox = await Hive.openBox<RecurringExpense>(recurringExpensesBoxName);
    _savingsFundsBox = await Hive.openBox<SavingsFund>(savingsFundsBoxName);
    _achievementsBox = await Hive.openBox<Achievement>(achievementsBoxName);
    
    await _checkAndProcessSalary();
  }

  // --- MÉTODOS DE TRANSAÇÃO ---

  Future<void> addTransaction(Transaction transaction) async {
    await _transactionsBox.add(transaction);
  }

  List<Transaction> getAllTransactions() {
    return _transactionsBox.values.toList();
  }

  List<Transaction> getTransactionsByMonth(DateTime month) {
    return _transactionsBox.values
        .where((t) =>
            t.date.year == month.year && t.date.month == month.month)
        .toList();
  }

  Future<void> updateTransaction(int index, Transaction transaction) async {
    await _transactionsBox.putAt(index, transaction);
  }

  Future<void> deleteTransaction(int index) async {
    await _transactionsBox.deleteAt(index);
  }

  // --- MÉTODOS DE USUÁRIO (SALDO E RENDA) ---

  Future<void> setUserData(UserData userData) async {
    if (_userDataBox.isEmpty) {
      await _userDataBox.add(userData);
    } else {
      await _userDataBox.putAt(0, userData);
    }
  }

  UserData? getUserData() {
    return _userDataBox.isEmpty ? null : _userDataBox.getAt(0);
  }
  
  // --- MÉTODOS NOVOS (SALDO RESGATADO) ---

  /// Adiciona valor resgatado (Investimento/Poupança -> Saldo Disponível)
  Future<void> addRedeemedBalance(double amount) async {
    final userData = getUserData() ?? UserData.empty();
    final newUserData = UserData(
      monthlyIncome: userData.monthlyIncome,
      extraIncome: userData.extraIncome,
      // Soma ao saldo total E ao saldo específico de resgate
      currentBalance: userData.currentBalance + amount, 
      redeemedBalance: userData.redeemedBalance + amount,
      lastUpdated: DateTime.now(),
    );
    await setUserData(newUserData);
  }

  /// Consome valor do saldo resgatado (se a fonte for 'redeemed')
  Future<void> consumeBalance(double amount, String source) async {
    final userData = getUserData() ?? UserData.empty();
    
    double newRedeemed = userData.redeemedBalance;
    
    if (source == 'redeemed') {
      newRedeemed = (userData.redeemedBalance - amount).clamp(0.0, double.infinity);
    }
    
    final newUserData = UserData(
      monthlyIncome: userData.monthlyIncome,
      extraIncome: userData.extraIncome,
      currentBalance: userData.currentBalance, 
      redeemedBalance: newRedeemed,
      lastUpdated: DateTime.now(),
    );
    await setUserData(newUserData);
  }

  // --- CONFIGURAÇÃO DE SALÁRIO ---

  Future<void> setSalaryConfig(SalaryConfig config) async {
    if (_salaryConfigBox.isEmpty) {
      await _salaryConfigBox.add(config);
    } else {
      await _salaryConfigBox.putAt(0, config);
    }
    // Atualiza UserData para refletir novo salário
    final userData = getUserData() ?? UserData.empty();
    final updatedUserData = UserData(
      monthlyIncome: config.amount,
      extraIncome: userData.extraIncome,
      currentBalance: userData.currentBalance,
      redeemedBalance: userData.redeemedBalance,
      lastUpdated: DateTime.now(),
    );
    await setUserData(updatedUserData);
  }

  SalaryConfig? getSalaryConfig() {
    return _salaryConfigBox.isEmpty ? null : _salaryConfigBox.getAt(0);
  }

  Future<bool> _checkAndProcessSalary() async {
    final salaryConfig = getSalaryConfig();
    if (salaryConfig == null || !salaryConfig.shouldPayToday()) {
      return false;
    }
    UserData userData = getUserData() ?? UserData.empty();
    final newUserData = UserData(
      monthlyIncome: userData.monthlyIncome,
      extraIncome: userData.extraIncome,
      currentBalance: userData.currentBalance + salaryConfig.amount,
      redeemedBalance: userData.redeemedBalance,
      lastUpdated: DateTime.now(),
    );
    await setUserData(newUserData);
    salaryConfig.markAsPaid();
    await setSalaryConfig(salaryConfig);
    return true;
  }

  // --- CONFIGURAÇÕES DO APP ---
  
  AppSettings getAppSettings() {
    if (_appSettingsBox.isEmpty) {
      return AppSettings(budgetRolloverEnabled: true); 
    }
    return _appSettingsBox.getAt(0)!;
  }

  Future<void> saveAppSettings(AppSettings settings) async {
    final fixedSettings = settings.copyWith(budgetRolloverEnabled: true);
    if (_appSettingsBox.isEmpty) {
      await _appSettingsBox.add(fixedSettings);
    } else {
      await _appSettingsBox.putAt(0, fixedSettings);
    }
  }

  // --- BACKUP E RESTAURAÇÃO ---

  Future<String> createBackupJson() async {
    final Map<String, dynamic> backup = {
      'version': '1.0',
      'timestamp': DateTime.now().toIso8601String(),
      'transactions': _transactionsBox.values.map((e) => _transactionToMap(e)).toList(),
      'userData': _userDataBox.values.map((e) => _userDataToMap(e)).toList(),
      'salaryConfig': _salaryConfigBox.values.map((e) => _salaryConfigToMap(e)).toList(),
      'appSettings': _appSettingsToMap(getAppSettings()),
    };
    return jsonEncode(backup);
  }

  Future<bool> restoreBackupJson(String jsonString) async {
    try {
      final Map<String, dynamic> backup = jsonDecode(jsonString);
      await clearAllData();

      if (backup['transactions'] != null) {
        for (var tMap in backup['transactions']) {
          await _transactionsBox.add(_mapToTransaction(tMap));
        }
      }
      if (backup['userData'] != null) {
        for (var uMap in backup['userData']) {
          await _userDataBox.add(_mapToUserData(uMap));
        }
      }
      if (backup['salaryConfig'] != null) {
        for (var sMap in backup['salaryConfig']) {
          await _salaryConfigBox.add(_mapToSalaryConfig(sMap));
        }
      }
      if (backup['appSettings'] != null) {
        await _appSettingsBox.add(_mapToAppSettings(backup['appSettings']));
      }

      return true;
    } catch (e) {
      print('Erro ao restaurar backup: $e');
      return false;
    }
  }

  // Helpers de Mapeamento
  Map<String, dynamic> _transactionToMap(Transaction t) => {
    'title': t.title,
    'amount': t.amount,
    'category': t.category,
    'date': t.date.toIso8601String(),
    'isFixed': t.isFixed,
    'totalInstallments': t.totalInstallments,
    'currentInstallment': t.currentInstallment,
    'source': t.source,
  };

  Transaction _mapToTransaction(Map<String, dynamic> m) => Transaction(
    title: m['title'],
    amount: (m['amount'] as num).toDouble(),
    category: m['category'],
    date: DateTime.parse(m['date']),
    isFixed: m['isFixed'] ?? false,
    totalInstallments: m['totalInstallments'],
    currentInstallment: m['currentInstallment'],
    source: m['source'] ?? 'main',
  );

  Map<String, dynamic> _userDataToMap(UserData u) => {
    'monthlyIncome': u.monthlyIncome,
    'extraIncome': u.extraIncome,
    'currentBalance': u.currentBalance,
    'redeemedBalance': u.redeemedBalance,
    'lastUpdated': u.lastUpdated.toIso8601String(),
  };

  UserData _mapToUserData(Map<String, dynamic> m) => UserData(
    monthlyIncome: (m['monthlyIncome'] as num).toDouble(),
    extraIncome: (m['extraIncome'] as num).toDouble(),
    currentBalance: (m['currentBalance'] as num).toDouble(),
    redeemedBalance: (m['redeemedBalance'] as num?)?.toDouble() ?? 0.0,
    lastUpdated: DateTime.parse(m['lastUpdated']),
  );

  Map<String, dynamic> _salaryConfigToMap(SalaryConfig s) => {
    'amount': s.amount,
    'paymentDay': s.paymentDay,
    'isActive': s.isActive,
    'lastPaymentDate': s.lastPaymentDate?.toIso8601String(),
  };

  SalaryConfig _mapToSalaryConfig(Map<String, dynamic> m) => SalaryConfig(
    amount: (m['amount'] as num).toDouble(),
    paymentDay: m['paymentDay'],
    isActive: m['isActive'],
    lastPaymentDate: m['lastPaymentDate'] != null ? DateTime.parse(m['lastPaymentDate']) : null,
  );

  Map<String, dynamic> _appSettingsToMap(AppSettings a) => {
    'biometricEnabled': a.biometricEnabled,
    'themeMode': a.themeMode,
    'currency': a.currency,
  };

  AppSettings _mapToAppSettings(Map<String, dynamic> m) => AppSettings(
    biometricEnabled: m['biometricEnabled'] ?? false,
    themeMode: m['themeMode'] ?? 2,
    currency: m['currency'] ?? 'BRL',
    budgetRolloverEnabled: true,
  );

  Future<void> clearAllData() async {
    await _transactionsBox.clear();
    await _userDataBox.clear();
    await _salaryConfigBox.clear();
    await _investmentsBox.clear();
    await _recurringExpensesBox.clear();
    await _savingsFundsBox.clear();
    await _achievementsBox.clear();
  }
}