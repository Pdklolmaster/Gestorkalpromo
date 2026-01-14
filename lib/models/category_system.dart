/// Sistema de categorias e subcategorias profissionais
class CategorySystem {
  static const Map<String, CategoryInfo> categories = {
    'Necessidade': CategoryInfo(
      name: 'Necessidade',
      icon: '🏠',
      color: 0xFF2196F3,
      percentage: 50,
      subcategories: {
        'Moradia': SubcategoryInfo(name: 'Moradia', icon: '🏠', keywords: ['aluguel', 'condomínio', 'iptu']),
        'Alimentação': SubcategoryInfo(name: 'Alimentação', icon: '🍽️', keywords: ['mercado', 'supermercado', 'feira', 'açougue']),
        'Saúde': SubcategoryInfo(name: 'Saúde', icon: '💊', keywords: ['farmácia', 'médico', 'hospital', 'plano', 'remédio']),
        'Transporte': SubcategoryInfo(name: 'Transporte', icon: '🚗', keywords: ['uber', '99', 'gasolina', 'combustível', 'ônibus', 'metrô']),
        'Educação': SubcategoryInfo(name: 'Educação', icon: '📚', keywords: ['escola', 'faculdade', 'curso', 'livro']),
        'Contas': SubcategoryInfo(name: 'Contas', icon: '📄', keywords: ['luz', 'água', 'gás', 'internet', 'telefone', 'celular']),
        'Seguros': SubcategoryInfo(name: 'Seguros', icon: '🛡️', keywords: ['seguro', 'proteção']),
      },
    ),
    'Desejos Lazer': CategoryInfo(
      name: 'Desejos Lazer',
      icon: '🛒',
      color: 0xFFFF9800,
      percentage: 30,
      subcategories: {
        'Lazer': SubcategoryInfo(name: 'Lazer', icon: '🎮', keywords: ['cinema', 'teatro', 'show', 'festa', 'bar']),
        'Restaurantes': SubcategoryInfo(name: 'Restaurantes', icon: '🍔', keywords: ['restaurante', 'lanchonete', 'pizzaria', 'ifood', 'delivery']),
        'Compras': SubcategoryInfo(name: 'Compras', icon: '🛍️', keywords: ['roupa', 'shopping', 'loja', 'presente']),
        'Assinaturas': SubcategoryInfo(name: 'Assinaturas', icon: '📺', keywords: ['netflix', 'spotify', 'disney', 'amazon', 'hbo', 'youtube']),
        'Viagem': SubcategoryInfo(name: 'Viagem', icon: '✈️', keywords: ['viagem', 'hotel', 'passagem', 'airbnb']),
        'Beleza': SubcategoryInfo(name: 'Beleza', icon: '💅', keywords: ['salão', 'cabelo', 'unha', 'estética']),
        'Hobbies': SubcategoryInfo(name: 'Hobbies', icon: '🎨', keywords: ['hobby', 'esporte', 'academia', 'crossfit']),
      },
    ),
    'Investimento': CategoryInfo(
      name: 'Investimento',
      icon: '🎯',
      color: 0xFF4CAF50,
      percentage: 20,
      subcategories: {
        'Investimentos': SubcategoryInfo(name: 'Investimentos', icon: '📈', keywords: ['investimento', 'ação', 'fundo', 'tesouro', 'cdb']),
        'Poupança': SubcategoryInfo(name: 'Poupança', icon: '🐷', keywords: ['poupança', 'reserva', 'guardar']),
        'Emergência': SubcategoryInfo(name: 'Emergência', icon: '🚨', keywords: ['emergência', 'imprevisto']),
        'Aposentadoria': SubcategoryInfo(name: 'Aposentadoria', icon: '👴', keywords: ['aposentadoria', 'previdência', 'inss']),
        'Objetivos': SubcategoryInfo(name: 'Objetivos', icon: '🎯', keywords: ['objetivo', 'meta', 'sonho']),
      },
    ),
  };

  /// Categoriza automaticamente baseado em texto usando NLP básico
  static CategoryResult categorize(String text) {
    String lowerText = text.toLowerCase();
    
    // Primeiro, verifica subcategorias (mais específico)
    for (var category in categories.entries) {
      for (var sub in category.value.subcategories.entries) {
        for (var keyword in sub.value.keywords) {
          if (lowerText.contains(keyword)) {
            return CategoryResult(
              category: category.key,
              subcategory: sub.key,
              confidence: 0.9,
            );
          }
        }
      }
    }

    // Análise semântica básica
    if (_isFood(lowerText)) {
      return CategoryResult(category: 'Necessidade', subcategory: 'Alimentação', confidence: 0.7);
    }
    if (_isEntertainment(lowerText)) {
      return CategoryResult(category: 'Desejo', subcategory: 'Lazer', confidence: 0.7);
    }
    if (_isTransport(lowerText)) {
      return CategoryResult(category: 'Necessidade', subcategory: 'Transporte', confidence: 0.7);
    }

    // Default
    return CategoryResult(category: 'Necessidade', subcategory: '', confidence: 0.3);
  }

  static bool _isFood(String text) {
    final foodWords = ['almoço', 'jantar', 'café', 'lanche', 'comida', 'refeição', 'comer'];
    return foodWords.any((word) => text.contains(word));
  }

  static bool _isEntertainment(String text) {
    final entertainmentWords = ['diversão', 'passeio', 'rolê', 'sair', 'encontro', 'festa'];
    return entertainmentWords.any((word) => text.contains(word));
  }

  static bool _isTransport(String text) {
    final transportWords = ['corrida', 'carro', 'moto', 'taxi', 'viagem', 'deslocamento'];
    return transportWords.any((word) => text.contains(word));
  }

  /// Detecta local no texto e ajusta categoria
  static CategoryResult categorizeWithContext(String text, String? location) {
    var result = categorize(text);
    
    if (location != null) {
      String lowerLoc = location.toLowerCase();
      
      // Shopping geralmente é lazer/compras
      if (lowerLoc.contains('shopping') || lowerLoc.contains('mall')) {
        if (result.category == 'Necessidade' && result.subcategory == 'Alimentação') {
          // Comida no shopping pode ser considerada lazer
          return CategoryResult(category: 'Desejo', subcategory: 'Restaurantes', confidence: 0.8);
        }
      }
      
      // Hospital/Farmácia é sempre necessidade
      if (lowerLoc.contains('hospital') || lowerLoc.contains('farmácia') || lowerLoc.contains('clínica')) {
        return CategoryResult(category: 'Necessidade', subcategory: 'Saúde', confidence: 0.95);
      }
    }
    
    return result;
  }

  static List<String> getCategoryNames() {
    return categories.keys.toList();
  }

  static List<String> getSubcategoriesFor(String category) {
    return categories[category]?.subcategories.keys.toList() ?? [];
  }

  static String getIcon(String category, [String? subcategory]) {
    if (subcategory != null && subcategory.isNotEmpty) {
      return categories[category]?.subcategories[subcategory]?.icon ?? '💰';
    }
    return categories[category]?.icon ?? '💰';
  }

  static int getColor(String category) {
    return categories[category]?.color ?? 0xFF9E9E9E;
  }
}

class CategoryInfo {
  final String name;
  final String icon;
  final int color;
  final int percentage;
  final Map<String, SubcategoryInfo> subcategories;

  const CategoryInfo({
    required this.name,
    required this.icon,
    required this.color,
    required this.percentage,
    required this.subcategories,
  });
}

class SubcategoryInfo {
  final String name;
  final String icon;
  final List<String> keywords;

  const SubcategoryInfo({
    required this.name,
    required this.icon,
    required this.keywords,
  });
}

class CategoryResult {
  final String category;
  final String subcategory;
  final double confidence; // 0.0 a 1.0

  CategoryResult({
    required this.category,
    this.subcategory = '',
    this.confidence = 0.5,
  });
}
