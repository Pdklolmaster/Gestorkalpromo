import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/transaction_model.dart';
import '../theme/app_theme.dart';

/// Card de Progresso de Categoria
class CategoryProgressCard extends StatefulWidget {
  final String category;
  final String? subtitle;
  final double spent;
  final double budget;
  final Color color;
  final IconData? icon;

  const CategoryProgressCard({
    required this.category,
    this.subtitle,
    required this.spent,
    required this.budget,
    required this.color,
    this.icon,
  });

  @override
  State<CategoryProgressCard> createState() => _CategoryProgressCardState();
}

class _CategoryProgressCardState extends State<CategoryProgressCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  @override
  void didUpdateWidget(CategoryProgressCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.spent != widget.spent) {
      _animController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.budget > 0 ? widget.spent / widget.budget : 0.0;
    final isOverBudget = widget.spent > widget.budget;
    final remaining = widget.budget - widget.spent;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(
          color: widget.color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.icon ?? _getCategoryIcon(widget.category),
                      color: widget.color,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.category,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (widget.subtitle != null)
                        Text(
                          widget.subtitle!,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                          ),
                        )
                      else
                        Text(
                          'R\$ ${widget.spent.toStringAsFixed(2)} gasto',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Disponível',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  Text(
                    'R\$ ${remaining.abs().toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isOverBudget ? AppTheme.errorRed : AppTheme.successGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              final animatedProgress = progress * _progressAnimation.value;
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(animatedProgress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isOverBudget ? AppTheme.errorRed : widget.color,
                        ),
                      ),
                      Text(
                        'de R\$ ${widget.budget.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Stack(
                    children: [
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: widget.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: (animatedProgress > 1 ? 1.0 : animatedProgress).toDouble(),
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isOverBudget
                                  ? [AppTheme.errorRed, AppTheme.errorRed.withOpacity(0.8)]
                                  : [widget.color, widget.color.withOpacity(0.7)],
                            ),
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(
                                color: (isOverBudget ? AppTheme.errorRed : widget.color)
                                    .withOpacity(0.4),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    if (category.contains('Necessidade')) return Icons.home_rounded;
    if (category.contains('Desejo')) return Icons.shopping_bag_rounded;
    if (category.contains('Investimento')) return Icons.trending_up_rounded;
    return Icons.attach_money_rounded;
  }
}

/// Card de Renda
class IncomeCard extends StatelessWidget {
  final double monthlyIncome;
  final double extraIncome;
  final VoidCallback onEditExtra;
  final VoidCallback? onEditSalary;
  final int? salaryPaymentDay;

  const IncomeCard({
    required this.monthlyIncome,
    required this.extraIncome,
    required this.onEditExtra,
    this.onEditSalary,
    this.salaryPaymentDay,
  });

  double get totalIncome => monthlyIncome + extraIncome;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.cardBackgroundLight,
            AppTheme.cardBackground,
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.account_balance_wallet_rounded, 
                        color: AppTheme.primaryBlue, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'RENDA TOTAL',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMuted,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'R\$ ${totalIncome.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white10,
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildIncomeItem(
                    icon: Icons.work_rounded,
                    label: 'Salário',
                    value: monthlyIncome,
                    color: AppTheme.successGreen,
                    badge: salaryPaymentDay != null ? 'Dia $salaryPaymentDay' : null,
                    onTap: onEditSalary,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildIncomeItem(
                    icon: Icons.add_circle_rounded,
                    label: 'Renda Extra',
                    value: extraIncome,
                    color: AppTheme.warningOrange,
                    onTap: onEditExtra,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeItem({
    required IconData icon,
    required String label,
    required double value,
    required Color color,
    String? badge,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: color, size: 16),
                      SizedBox(width: 6),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  if (badge != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 9,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'R\$ ${value.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (onTap != null)
                Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'Toque para editar',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card de Saldo Disponível
class BalanceCard extends StatefulWidget {
  final double currentBalance;
  final double totalIncome;
  final double totalSpent;
  final bool isOverride;
  final VoidCallback onEdit;

  const BalanceCard({
    required this.currentBalance,
    required this.totalIncome,
    required this.totalSpent,
    this.isOverride = false,
    required this.onEdit,
  });

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNegative = widget.currentBalance < 0;
    final accentColor = isNegative ? AppTheme.errorRed : AppTheme.investimentoColor;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _pulseController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _pulseController.reverse();
        widget.onEdit();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _pulseController.reverse();
      },
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final scale = 1.0 - (_pulseController.value * 0.02);
          return Transform.scale(
            scale: scale,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accentColor.withOpacity(0.2),
                    accentColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                border: Border.all(
                  color: accentColor.withOpacity(_isPressed ? 0.4 : 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(_isPressed ? 0.3 : 0.15),
                    blurRadius: _isPressed ? 20 : 12,
                    offset: Offset(0, _isPressed ? 8 : 4),
                  ),
                ],
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.account_balance_wallet_rounded,
                              color: accentColor,
                              size: 18,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Saldo Disponível',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (widget.isOverride)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              margin: EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.warningOrange.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.edit_rounded, 
                                      size: 12, color: AppTheme.warningOrange),
                                  SizedBox(width: 4),
                                  Text(
                                    'Ajustado',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.warningOrange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Icon(
                            Icons.touch_app_rounded,
                            color: accentColor.withOpacity(0.5),
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'R\$ ${widget.currentBalance.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: isNegative ? AppTheme.errorRed : AppTheme.textPrimary,
                      letterSpacing: -1,
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.arrow_upward_rounded, 
                                size: 14, color: AppTheme.successGreen),
                            SizedBox(width: 4),
                            Text(
                              'R\$ ${widget.totalIncome.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.successGreen,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 1,
                          height: 16,
                          color: Colors.white10,
                        ),
                        Row(
                          children: [
                            Icon(Icons.arrow_downward_rounded, 
                                size: 14, color: AppTheme.errorRed),
                            SizedBox(width: 4),
                            Text(
                              'R\$ ${widget.totalSpent.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.errorRed,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Card de Saldo Resgatado
class RedeemedCard extends StatelessWidget {
  final double redeemedBalance;

  const RedeemedCard({required this.redeemedBalance});

  @override
  Widget build(BuildContext context) {
    if (redeemedBalance <= 0) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.download_done_rounded, color: Colors.purpleAccent, size: 20),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Saldo Resgatado (Invest/Poup)',
                style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
              ),
              Text(
                'R\$ ${redeemedBalance.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.purpleAccent,
                ),
              ),
            ],
          ),
          Spacer(),
          Icon(Icons.check_circle_outline, color: Colors.purple.withOpacity(0.5), size: 18),
        ],
      ),
    );
  }
}

/// Card de Transação
class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TransactionTile({
    required this.transaction,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  Color get _categoryColor => AppTheme.getCategoryColor(transaction.category);
  IconData get _categoryIcon => AppTheme.getCategoryIcon(transaction.category);

  @override
  Widget build(BuildContext context) {
    final isInstallment = transaction.isInstallment;
    final isFixed = transaction.isFixed;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _categoryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _categoryColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(_categoryIcon, color: _categoryColor, size: 22),
                      if (isFixed)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: AppTheme.cardBackgroundLight,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.repeat_rounded,
                              size: 12,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              transaction.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isInstallment)
                            Container(
                              margin: EdgeInsets.only(left: 8),
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                transaction.installmentLabel,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.purple[300],
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, 
                              size: 12, color: AppTheme.textMuted),
                          SizedBox(width: 4),
                          Text(
                            '${transaction.date.day.toString().padLeft(2, '0')}/${transaction.date.month.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          if (isFixed) ...[
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Fixa',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'R\$ ${transaction.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _categoryColor,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      transaction.category.split(' ').first,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, 
                      color: AppTheme.textMuted, size: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: AppTheme.cardBackground,
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_rounded, size: 18, color: AppTheme.textSecondary),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_rounded, size: 18, color: AppTheme.errorRed),
                          SizedBox(width: 8),
                          Text('Excluir', style: TextStyle(color: AppTheme.errorRed)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Card de Resumo
class SummaryCard extends StatelessWidget {
  final double income;
  final double totalSpent;
  final double? availableBalance;

  const SummaryCard({
    required this.income,
    required this.totalSpent,
    this.availableBalance,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = availableBalance ?? (income - totalSpent);
    final isPositive = remaining >= 0;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              icon: Icons.arrow_downward_rounded,
              label: 'Total Gasto',
              value: totalSpent,
              color: AppTheme.errorRed,
            ),
          ),
          Container(
            width: 1,
            height: 60,
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.white10,
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Expanded(
            child: _buildSummaryItem(
              icon: isPositive ? Icons.savings_rounded : Icons.warning_rounded,
              label: 'Restante',
              value: remaining.abs(),
              color: isPositive ? AppTheme.successGreen : AppTheme.errorRed,
              prefix: isPositive ? '' : '-',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required double value,
    required Color color,
    String prefix = '',
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textMuted,
          ),
        ),
        SizedBox(height: 4),
        Text(
          '${prefix}R\$ ${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}