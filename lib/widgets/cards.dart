import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class CategoryProgressCard extends StatelessWidget {
  final String category;
  final double spent;
  final double budget;
  final Color color;

  const CategoryProgressCard({super.key, 
    required this.category,
    required this.spent,
    required this.budget,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = budget > 0 ? spent / budget : 0;
    final isOverBudget = spent > budget;
    final remaining = budget - spent;

    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isOverBudget ? Colors.red : color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'R\$ ${spent.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                Text(
                  'de R\$ ${budget.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress > 1 ? 1.0 : progress.toDouble(),
                backgroundColor: Colors.grey[800],
                color: isOverBudget ? Colors.red : color,
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isOverBudget
                  ? 'Ultrapassado em R\$ ${(-remaining).toStringAsFixed(2)}'
                  : 'Disponível R\$ ${remaining.toStringAsFixed(2)}',
              style: TextStyle(
                color: isOverBudget ? Colors.red : Colors.green[400],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IncomeCard extends StatelessWidget {
  final double monthlyIncome;
  final double extraIncome;
  final VoidCallback onEditExtra; // Callback para editar renda extra
  final VoidCallback? onEditSalary; // Callback para editar salário
  final int? salaryPaymentDay; // Dia do pagamento

  const IncomeCard({super.key, 
    required this.monthlyIncome,
    required this.extraIncome,
    required this.onEditExtra,
    this.onEditSalary,
    this.salaryPaymentDay,
  });

  double get totalIncome => monthlyIncome + extraIncome;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card Salário Mensal
        Card(
          color: Colors.grey[850],
          child: InkWell(
            onTap: onEditSalary,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Salário Mensal',
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                          if (salaryPaymentDay != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Dia $salaryPaymentDay',
                                style: const TextStyle(fontSize: 10, color: Colors.green),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.attach_money, color: Colors.green, size: 16),
                          if (onEditSalary != null) ...[
                            const SizedBox(width: 4),
                            Icon(Icons.edit, color: Colors.grey[600], size: 14),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'R\$ ${monthlyIncome.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  if (onEditSalary != null)
                    Text(
                      'Toque para configurar salário automático',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Card Renda Extra - Clicável para adicionar
        Card(
          color: Colors.grey[850],
          child: InkWell(
            onTap: onEditExtra, // Abre diálogo de adicionar renda extra
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Renda Extra',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.trending_up, color: Colors.orange, size: 16),
                          const SizedBox(width: 4),
                          Icon(Icons.add_circle_outline, color: Colors.grey[600], size: 14),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'R\$ ${extraIncome.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  Text(
                    'Toque para adicionar ou remover',
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Card Renda Total - Apenas visual (Salário + Extra)
        Card(
          color: Colors.grey[900],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Renda Total',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                    const Icon(Icons.calculate, color: Colors.blue, size: 18),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'R\$ ${totalIncome.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Salário: R\$ ${monthlyIncome.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    Text(
                      'Extra: R\$ ${extraIncome.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Salário Mensal + Renda Extra',
                    style: TextStyle(fontSize: 10, color: Colors.grey[500], fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Card para mostrar o Saldo Disponível (INDEPENDENTE - pode ser editado livremente)
class BalanceCard extends StatelessWidget {
  final double currentBalance; // Saldo atual (pode ser override ou calculado)
  final double totalIncome;    // Renda Total (Salário + Extra)
  final double totalSpent;     // Total de Gastos
  final bool isOverride;       // Se true, saldo foi editado manualmente
  final VoidCallback onEdit;   // Permite editar livremente

  const BalanceCard({super.key, 
    required this.currentBalance,
    required this.totalIncome,
    required this.totalSpent,
    this.isOverride = false,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isNegative = currentBalance < 0;
    final calculatedBalance = totalIncome - totalSpent;
    final difference = currentBalance - calculatedBalance;

    return Card(
      color: isNegative ? Colors.red[900] : Colors.teal[900],
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Saldo Disponível',
                        style: TextStyle(fontSize: 12, color: isNegative ? Colors.red[200] : Colors.teal[200]),
                      ),
                      if (isOverride) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'AJUSTADO',
                            style: TextStyle(fontSize: 8, color: Colors.orange, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.account_balance_wallet, 
                        color: isNegative ? Colors.red[300] : Colors.teal[300], size: 18),
                      const SizedBox(width: 4),
                      Icon(Icons.edit, color: isNegative ? Colors.red[400] : Colors.teal[400], size: 14),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'R\$ ${currentBalance.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isNegative ? Colors.red[100] : Colors.teal[100],
                ),
              ),
              const SizedBox(height: 8),
              // Mostrar referências
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Renda Total: R\$ ${totalIncome.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 11, color: Colors.green[300]),
                  ),
                  Text(
                    'Gastos: R\$ ${totalSpent.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 11, color: Colors.red[300]),
                  ),
                ],
              ),
              if (isOverride && difference.abs() > 0.01)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Diferença do cálculo: ${difference >= 0 ? "+" : ""}R\$ ${difference.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 10, color: Colors.orange[300]),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Toque para ajustar saldo',
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TransactionTile({super.key, 
    required this.transaction,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getCategoryColor() {
    switch (transaction.category) {
      case 'Necessidade':
        return Colors.blue;
      case 'Desejos Lazer':
        return Colors.orange;
      case 'Investimento':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon() {
    switch (transaction.category) {
      case 'Necessidade':
        return Icons.home;
      case 'Desejos Lazer':
        return Icons.shopping_cart;
      case 'Investimento':
        return Icons.savings;
      default:
        return Icons.attach_money;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isInstallment = transaction.isInstallment;
    final isFixed = transaction.isFixed;
    
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Stack(
          children: [
            Icon(
              _getCategoryIcon(),
              color: _getCategoryColor(),
            ),
            if (isFixed)
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.repeat, size: 12, color: Colors.blue),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(child: Text(transaction.displayTitle)),
            if (isInstallment)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  transaction.installmentLabel,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.purple[300],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Row(
          children: [
            Text(
              '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
              style: const TextStyle(fontSize: 12),
            ),
            if (isFixed) ...[
              const SizedBox(width: 8),
              Icon(Icons.event_repeat, size: 12, color: Colors.blue[300]),
              const SizedBox(width: 2),
              Text('Fixa', style: TextStyle(fontSize: 10, color: Colors.blue[300])),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'R\$ ${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: _getCategoryColor(),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: onEdit,
                  child: Text('Editar'),
                ),
                PopupMenuItem(
                  onTap: onDelete,
                  child: Text('Deletar', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final double income;
  final double totalSpent;
  final double? availableBalance; // Saldo disponível (pode ser override)

  const SummaryCard({super.key, 
    required this.income,
    required this.totalSpent,
    this.availableBalance,
  });

  @override
  Widget build(BuildContext context) {
    // Usa availableBalance se fornecido, senão calcula
    final remaining = availableBalance ?? (income - totalSpent);

    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text('Total Gasto', style: TextStyle(color: Colors.grey[400])),
                const SizedBox(height: 8),
                Text(
                  'R\$ ${totalSpent.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            Container(
              width: 1,
              height: 50,
              color: Colors.grey[700],
            ),
            Column(
              children: [
                Text('Restante', style: TextStyle(color: Colors.grey[400])),
                const SizedBox(height: 8),
                Text(
                  'R\$ ${remaining.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: remaining >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
