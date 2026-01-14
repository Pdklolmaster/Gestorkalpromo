import 'package:hive_flutter/hive_flutter.dart';
import '../models/investment.dart';
import '../services/data_service.dart'; // Import necessário

class InvestmentService {
  static const String _boxName = 'investments';
  static Box<Investment> get _box => Hive.box<Investment>(_boxName);
  
  // ... (métodos getAll, getById, add, update, delete mantidos)
  static List<Investment> getAll() => _box.values.toList();
  static Investment? getById(String id) {
     try { return _box.values.firstWhere((i) => i.id == id); } catch (_) { return null; }
  }
  static Future<void> add(Investment i) async => await _box.put(i.id, i);
  static Future<void> update(Investment i) async => await _box.put(i.id, i);
  static Future<void> delete(String id) async => await _box.delete(id);
  static String generateId() => 'inv_${DateTime.now().millisecondsSinceEpoch}';

  // ... (deposit mantido)
  static Future<Investment> deposit(String id, double amount) async {
    final investment = getById(id);
    if (investment == null) throw Exception('Investimento não encontrado');
    final updated = investment.copyWith(
      investedAmount: investment.investedAmount + amount,
      currentAmount: investment.currentAmount + amount,
    );
    await update(updated);
    return updated;
  }

  /// CORREÇÃO DO SAQUE
  static Future<Investment> withdraw(String id, double amount) async {
    final investment = getById(id);
    if (investment == null) throw Exception('Investimento não encontrado');
    if (investment.currentAmount < amount) {
      throw Exception('Saldo insuficiente');
    }

    // 1. CORREÇÃO: Subtrair em vez de somar (-)
    final updated = investment.copyWith(
      currentAmount: investment.currentAmount - amount,
    );
    await update(updated);

    // 2. Adicionar ao Saldo Disponível como "Resgatado"
    final dataService = DataService();
    // Como init() é async e static methods são sincronos na chamada, instanciamos direto
    // Assumindo que o Hive já está aberto no main
    await dataService.init(); 
    await dataService.addRedeemedBalance(amount);

    return updated;
  }
  
  // ... (restante do código applyYield, etc mantido)
   static Future<double> applyAllYields() async {
    // ... código existente
    return 0.0; // placeholder
  }
}