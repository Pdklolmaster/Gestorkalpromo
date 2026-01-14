import '../models/transaction_model.dart';

/// Parser inteligente para extrair dados financeiros de texto natural
class SmartInputParser {
  /// Resultado do parsing
  static SmartParseResult parse(String input) {
    final result = SmartParseResult();
    final lowerInput = input.toLowerCase();
    
    // 1. Extrair valor monetário
    result.amount = _extractAmount(input);
    
    // 2. Extrair data
    result.date = _extractDate(lowerInput);
    
    // 3. Extrair parcelamento
    final installmentInfo = _extractInstallments(lowerInput);
    result.totalInstallments = installmentInfo['count'];
    result.installmentAmount = installmentInfo['amount'] != null && result.amount != null
        ? result.amount! / installmentInfo['count']!
        : null;
    
    // 4. Extrair descrição (remove valor, data, parcelamento do texto)
    result.description = _extractDescription(input, lowerInput);
    
    // 5. Detectar categoria automática
    result.category = _detectCategory(lowerInput);
    
    // 6. Detectar se é conta fixa
    result.isFixed = _detectFixed(lowerInput);
    
    return result;
  }

  /// Extrai valor monetário do texto
  static double? _extractAmount(String input) {
    // Padrões de valor: "R$ 300", "300 reais", "300,50", "trezentos"
    final patterns = [
      // R$ 300,00 ou R$300.00
      RegExp(r'R\$\s*(\d+(?:[.,]\d{1,2})?)', caseSensitive: false),
      // 300 reais, 300 real, 300 conto(s)
      RegExp(r'(\d+(?:[.,]\d{1,2})?)\s*(?:reais?|contos?)', caseSensitive: false),
      // Número isolado (último recurso)
      RegExp(r'(\d+(?:[.,]\d{1,2})?)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(input);
      if (match != null) {
        String valueStr = match.group(1)!.replaceAll(',', '.');
        return double.tryParse(valueStr);
      }
    }
    return null;
  }

  /// Extrai data do texto (relativa ou absoluta)
  static DateTime _extractDate(String input) {
    final now = DateTime.now();
    
    // Ontem
    if (input.contains('ontem')) {
      return DateTime(now.year, now.month, now.day - 1);
    }
    
    // Anteontem
    if (input.contains('anteontem') || input.contains('antes de ontem')) {
      return DateTime(now.year, now.month, now.day - 2);
    }
    
    // Hoje
    if (input.contains('hoje')) {
      return DateTime(now.year, now.month, now.day);
    }
    
    // Dia específico: "dia 8", "no dia 15"
    final dayMatch = RegExp(r'(?:no\s+)?dia\s+(\d{1,2})').firstMatch(input);
    if (dayMatch != null) {
      int day = int.parse(dayMatch.group(1)!).clamp(1, 31);
      // Se o dia já passou neste mês, assume este mês mesmo
      return DateTime(now.year, now.month, day);
    }
    
    // Data completa: "15/01", "15/01/2026"
    final fullDateMatch = RegExp(r'(\d{1,2})/(\d{1,2})(?:/(\d{2,4}))?').firstMatch(input);
    if (fullDateMatch != null) {
      int day = int.parse(fullDateMatch.group(1)!).clamp(1, 31);
      int month = int.parse(fullDateMatch.group(2)!).clamp(1, 12);
      int year = fullDateMatch.group(3) != null 
          ? int.parse(fullDateMatch.group(3)!) 
          : now.year;
      if (year < 100) year += 2000;
      return DateTime(year, month, day);
    }
    
    // Dias da semana
    final weekdays = {
      'segunda': DateTime.monday,
      'terça': DateTime.tuesday,
      'terca': DateTime.tuesday,
      'quarta': DateTime.wednesday,
      'quinta': DateTime.thursday,
      'sexta': DateTime.friday,
      'sábado': DateTime.saturday,
      'sabado': DateTime.saturday,
      'domingo': DateTime.sunday,
    };
    
    for (final entry in weekdays.entries) {
      if (input.contains(entry.key)) {
        // Encontra a última ocorrência deste dia da semana
        int daysAgo = (now.weekday - entry.value + 7) % 7;
        if (daysAgo == 0) daysAgo = 7; // Se for hoje, pega semana passada
        return DateTime(now.year, now.month, now.day - daysAgo);
      }
    }
    
    // Semana passada
    if (input.contains('semana passada')) {
      return DateTime(now.year, now.month, now.day - 7);
    }
    
    // Mês passado
    if (input.contains('mês passado') || input.contains('mes passado')) {
      return DateTime(now.year, now.month - 1, now.day);
    }
    
    // Default: hoje
    return DateTime(now.year, now.month, now.day);
  }

  /// Extrai informações de parcelamento
  static Map<String, int?> _extractInstallments(String input) {
    // Padrões: "parcelei em 6x", "em 3 vezes", "6 parcelas", "dividir em 4x"
    final patterns = [
      RegExp(r'(?:parcel\w+|divid\w+)\s*(?:em\s+)?(\d+)\s*(?:x|vezes|parcelas?)', caseSensitive: false),
      RegExp(r'em\s+(\d+)\s*(?:x|vezes|parcelas?)', caseSensitive: false),
      RegExp(r'(\d+)\s*(?:x|parcelas?)\s', caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(input);
      if (match != null) {
        int count = int.tryParse(match.group(1)!) ?? 1;
        if (count > 1) {
          return {'count': count, 'amount': null};
        }
      }
    }
    
    return {'count': null, 'amount': null};
  }

  /// Extrai descrição limpa do texto
  static String _extractDescription(String original, String lower) {
    String description = original;
    
    // Remove padrões de valor
    description = description.replaceAll(
        RegExp(r'R\$\s*\d+(?:[.,]\d{1,2})?', caseSensitive: false), '');
    description = description.replaceAll(
        RegExp(r'\d+(?:[.,]\d{1,2})?\s*(?:reais?|contos?)', caseSensitive: false), '');
    
    // Remove padrões de data
    description = description.replaceAll(
        RegExp(r'\b(?:ontem|anteontem|hoje|antes de ontem)\b', caseSensitive: false), '');
    description = description.replaceAll(
        RegExp(r'(?:no\s+)?dia\s+\d{1,2}', caseSensitive: false), '');
    description = description.replaceAll(
        RegExp(r'\d{1,2}/\d{1,2}(?:/\d{2,4})?'), '');
    description = description.replaceAll(
        RegExp(r'\b(?:segunda|terça|terca|quarta|quinta|sexta|sábado|sabado|domingo)(?:-feira)?\b', 
            caseSensitive: false), '');
    
    // Remove padrões de parcelamento
    description = description.replaceAll(
        RegExp(r'(?:parcel\w+|divid\w+)\s*(?:em\s+)?\d+\s*(?:x|vezes|parcelas?)', 
            caseSensitive: false), '');
    description = description.replaceAll(
        RegExp(r'em\s+\d+\s*(?:x|vezes|parcelas?)', caseSensitive: false), '');
    
    // Remove palavras comuns
    description = description.replaceAll(
        RegExp(r'\b(?:gastei|comprei|paguei|no|na|de|com|em|e|o|a|um|uma)\b', 
            caseSensitive: false), '');
    
    // Limpa espaços extras
    description = description.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    // Capitaliza primeira letra
    if (description.isNotEmpty) {
      description = description[0].toUpperCase() + description.substring(1);
    }
    
    return description.isEmpty ? 'Gasto' : description;
  }

  /// Detecta categoria baseado em palavras-chave
  static String _detectCategory(String input) {
    // Necessidades (50%)
    final necessidades = [
      'luz', 'água', 'agua', 'aluguel', 'condomínio', 'condominio',
      'mercado', 'supermercado', 'farmácia', 'farmacia', 'remédio', 'remedio',
      'combustível', 'combustivel', 'gasolina', 'ônibus', 'onibus', 'metrô', 'metro',
      'internet', 'telefone', 'celular', 'plano', 'saúde', 'saude',
      'escola', 'faculdade', 'curso', 'mensalidade',
    ];
    
    // Desejos/Lazer (30%)
    final desejos = [
      'netflix', 'spotify', 'disney', 'prime', 'streaming',
      'cinema', 'filme', 'show', 'teatro', 'festa',
      'restaurante', 'lanche', 'pizza', 'hamburguer', 'ifood', 'delivery',
      'roupa', 'sapato', 'tênis', 'tenis', 'shopping',
      'viagem', 'hotel', 'passeio', 'uber', '99',
      'jogo', 'game', 'eletrônico', 'eletronico',
      'bar', 'cerveja', 'bebida', 'balada',
    ];
    
    // Investimentos/Metas (20%)
    final investimentos = [
      'investimento', 'poupança', 'poupanca', 'reserva',
      'ação', 'acao', 'fundo', 'tesouro', 'cdb', 'lci', 'lca',
      'caixinha', 'guardar', 'economizar',
    ];
    
    for (final word in necessidades) {
      if (input.contains(word)) return 'Necessidade';
    }
    
    for (final word in desejos) {
      if (input.contains(word)) return 'Desejos Lazer';
    }
    
    for (final word in investimentos) {
      if (input.contains(word)) return 'Investimento';
    }
    
    return 'Necessidade'; // Default
  }

  /// Detecta se é conta fixa
  static bool _detectFixed(String input) {
    final fixedKeywords = [
      'todo mês', 'todo mes', 'mensal', 'mensalmente',
      'fixo', 'fixa', 'recorrente', 'sempre',
      'assinatura', 'plano',
    ];
    
    for (final keyword in fixedKeywords) {
      if (input.contains(keyword)) return true;
    }
    
    return false;
  }

  /// Cria transações a partir do resultado do parsing
  static List<Transaction> createTransactions(SmartParseResult result) {
    if (result.amount == null || result.amount! <= 0) {
      return [];
    }

    final List<Transaction> transactions = [];
    final groupId = 'inst_${DateTime.now().millisecondsSinceEpoch}';

    if (result.totalInstallments != null && result.totalInstallments! > 1) {
      // Criar parcelas
      final installmentAmount = result.amount! / result.totalInstallments!;
      
      for (int i = 1; i <= result.totalInstallments!; i++) {
        // Calcular data de cada parcela (meses futuros)
        final installmentDate = DateTime(
          result.date.year,
          result.date.month + (i - 1),
          result.date.day,
        );

        transactions.add(Transaction(
          title: result.description,
          amount: installmentAmount,
          category: result.category,
          date: installmentDate,
          isFixed: false,
          totalInstallments: result.totalInstallments,
          currentInstallment: i,
          installmentGroupId: groupId,
          totalAmount: result.amount,
        ));
      }
    } else {
      // Transação única
      transactions.add(Transaction(
        title: result.description,
        amount: result.amount!,
        category: result.category,
        date: result.date,
        isFixed: result.isFixed,
        dueDay: result.isFixed ? result.date.day : null,
      ));
    }

    return transactions;
  }
}

/// Resultado do parsing de texto inteligente
class SmartParseResult {
  double? amount;
  DateTime date = DateTime.now();
  String description = '';
  String category = 'Necessidade';
  int? totalInstallments;
  double? installmentAmount;
  bool isFixed = false;

  bool get isValid => amount != null && amount! > 0;
  
  bool get hasInstallments => totalInstallments != null && totalInstallments! > 1;

  @override
  String toString() {
    return 'SmartParseResult(amount: $amount, date: $date, desc: $description, '
           'category: $category, installments: $totalInstallments, fixed: $isFixed)';
  }
}
