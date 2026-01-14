import 'package:hive/hive.dart';

part 'achievement.g.dart';

@HiveType(typeId: 4)
class Achievement {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String icon;

  @HiveField(4)
  final bool isUnlocked;

  @HiveField(5)
  final DateTime? unlockedAt;

  @HiveField(6)
  final String type; // 'savings', 'budget', 'streak', 'milestone'

  @HiveField(7)
  final double targetValue;

  @HiveField(8)
  final double currentValue;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
    this.unlockedAt,
    required this.type,
    required this.targetValue,
    this.currentValue = 0,
  });

  double get progress => targetValue > 0 ? (currentValue / targetValue).clamp(0, 1) : 0;

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    bool? isUnlocked,
    DateTime? unlockedAt,
    String? type,
    double? targetValue,
    double? currentValue,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
    );
  }
}

// Conquistas pré-definidas
class AchievementTemplates {
  static List<Achievement> getDefaults() {
    return [
      Achievement(
        id: 'first_save',
        title: 'Primeira Economia',
        description: 'Economize seu primeiro real',
        icon: '🌱',
        type: 'savings',
        targetValue: 1,
      ),
      Achievement(
        id: 'budget_master',
        title: 'Mestre do Orçamento',
        description: 'Fique dentro do orçamento por 30 dias',
        icon: '🎯',
        type: 'streak',
        targetValue: 30,
      ),
      Achievement(
        id: 'saver_100',
        title: 'Poupador Bronze',
        description: 'Economize R\$ 100',
        icon: '🥉',
        type: 'savings',
        targetValue: 100,
      ),
      Achievement(
        id: 'saver_500',
        title: 'Poupador Prata',
        description: 'Economize R\$ 500',
        icon: '🥈',
        type: 'savings',
        targetValue: 500,
      ),
      Achievement(
        id: 'saver_1000',
        title: 'Poupador Ouro',
        description: 'Economize R\$ 1.000',
        icon: '🥇',
        type: 'savings',
        targetValue: 1000,
      ),
      Achievement(
        id: 'no_lazer_week',
        title: 'Controlado',
        description: 'Passe uma semana sem gastos de lazer',
        icon: '🧘',
        type: 'streak',
        targetValue: 7,
      ),
      Achievement(
        id: 'emergency_fund',
        title: 'Reserva de Emergência',
        description: 'Acumule 3 meses de despesas',
        icon: '🛡️',
        type: 'milestone',
        targetValue: 3,
      ),
      Achievement(
        id: 'tracker_30',
        title: 'Organizador',
        description: 'Registre gastos por 30 dias seguidos',
        icon: '📝',
        type: 'streak',
        targetValue: 30,
      ),
    ];
  }
}
