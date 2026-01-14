import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';

/// Serviço de exportação de dados
class ExportService {
  
  /// Gera CSV com todas as transações
  static String generateCSV(List<Transaction> transactions) {
    StringBuffer csv = StringBuffer();
    
    // Header
    csv.writeln('Data,Título,Categoria,Valor');
    
    // Dados
    for (var t in transactions) {
      final date = DateFormat('dd/MM/yyyy').format(t.date);
      final title = _escapeCSV(t.title);
      final category = t.category;
      final amount = t.amount.toStringAsFixed(2);
      
      csv.writeln('$date,$title,$category,$amount');
    }
    
    return csv.toString();
  }

  /// Gera relatório em texto formatado (pode ser salvo como TXT)
  static String generateReport({
    required List<Transaction> transactions,
    required double income,
    required DateTime month,
  }) {
    StringBuffer report = StringBuffer();
    final formatter = DateFormat('MMMM yyyy', 'pt_BR');
    
    report.writeln('═══════════════════════════════════════════════════');
    report.writeln('       RELATÓRIO FINANCEIRO - ${formatter.format(month).toUpperCase()}');
    report.writeln('═══════════════════════════════════════════════════');
    report.writeln();
    
    // Resumo
    double totalSpent = transactions.fold(0, (sum, t) => sum + t.amount);
    double remaining = income - totalSpent;
    
    report.writeln('📊 RESUMO');
    report.writeln('─────────────────────────────────────────────────');
    report.writeln('Renda Mensal:       R\$ ${income.toStringAsFixed(2)}');
    report.writeln('Total Gasto:        R\$ ${totalSpent.toStringAsFixed(2)}');
    report.writeln('Saldo:              R\$ ${remaining.toStringAsFixed(2)}');
    report.writeln();
    
    // Por categoria
    Map<String, double> byCategory = {};
    for (var t in transactions) {
      byCategory[t.category] = (byCategory[t.category] ?? 0) + t.amount;
    }
    
    report.writeln('📈 GASTOS POR CATEGORIA');
    report.writeln('─────────────────────────────────────────────────');
    
    final budgets = {
      'Necessidade': income * 0.5,
      'Desejos Lazer': income * 0.3,
      'Investimento': income * 0.2,
    };
    
    for (var entry in budgets.entries) {
      double spent = byCategory[entry.key] ?? 0;
      double budget = entry.value;
      double percent = budget > 0 ? (spent / budget) * 100 : 0;
      String status = percent > 100 ? '⚠️ EXCEDIDO' : '✅';
      
      report.writeln('${entry.key}:');
      report.writeln('  Orçamento: R\$ ${budget.toStringAsFixed(2)}');
      report.writeln('  Gasto:     R\$ ${spent.toStringAsFixed(2)} (${percent.toStringAsFixed(0)}%) $status');
      report.writeln();
    }
    
    // Lista de transações
    report.writeln('📝 TRANSAÇÕES');
    report.writeln('─────────────────────────────────────────────────');
    
    transactions.sort((a, b) => b.date.compareTo(a.date));
    
    for (var t in transactions) {
      String date = DateFormat('dd/MM').format(t.date);
      String title = t.title.length > 20 ? '${t.title.substring(0, 17)}...' : t.title;
      String amount = 'R\$ ${t.amount.toStringAsFixed(2)}';
      report.writeln('$date | ${title.padRight(20)} | $amount');
    }
    
    report.writeln();
    report.writeln('═══════════════════════════════════════════════════');
    report.writeln('Gerado em ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}');
    report.writeln('App Gestor Financeiro 50/30/20');
    
    return report.toString();
  }

  /// Copia texto para área de transferência
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  /// Escapa texto para CSV
  static String _escapeCSV(String text) {
    if (text.contains(',') || text.contains('"') || text.contains('\n')) {
      return '"${text.replaceAll('"', '""')}"';
    }
    return text;
  }
}
