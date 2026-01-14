import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/advanced_finance_service.dart';

/// Widget de Heatmap Calendário
class SpendingHeatmap extends StatelessWidget {
  final List<Transaction> transactions;
  final DateTime selectedMonth;

  const SpendingHeatmap({super.key, 
    required this.transactions,
    required this.selectedMonth,
  });

  @override
  Widget build(BuildContext context) {
    final heatmapData = AdvancedFinanceService.generateHeatmapData(transactions);
    final maxSpent = heatmapData.values.isEmpty ? 0.0 : heatmapData.values.reduce((a, b) => a > b ? a : b);
    
    final firstDay = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final daysInMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday;

    return Card(
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mapa de Gastos',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                _buildLegend(),
              ],
            ),
            const SizedBox(height: 16),
            
            // Dias da semana
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['S', 'T', 'Q', 'Q', 'S', 'S', 'D']
                  .map((d) => SizedBox(
                        width: 36,
                        child: Text(d, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            
            // Grid de dias
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: 42, // 6 semanas
              itemBuilder: (context, index) {
                final dayOffset = index - (startWeekday - 1);
                
                if (dayOffset < 1 || dayOffset > daysInMonth) {
                  return Container();
                }
                
                final date = DateTime(selectedMonth.year, selectedMonth.month, dayOffset);
                final spent = heatmapData[date] ?? 0;
                final intensity = AdvancedFinanceService.getHeatIntensity(spent, maxSpent);
                final color = spent > 0 
                    ? AdvancedFinanceService.getHeatColor(intensity)
                    : Colors.grey[800]!;
                
                return Tooltip(
                  message: spent > 0 ? 'R\$ ${spent.toStringAsFixed(2)}' : 'Sem gastos',
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        '$dayOffset',
                        style: TextStyle(
                          fontSize: 11,
                          color: intensity > 0.5 ? Colors.white : Colors.white70,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _legendItem(Colors.grey[800]!, 'Nada'),
        const SizedBox(width: 4),
        _legendItem(Colors.green.shade200, 'Baixo'),
        const SizedBox(width: 4),
        _legendItem(Colors.orange.shade400, 'Médio'),
        const SizedBox(width: 4),
        _legendItem(Colors.red.shade500, 'Alto'),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 2),
        Text(label, style: const TextStyle(fontSize: 9)),
      ],
    );
  }
}

/// Widget de Comparação Mês Atual vs Anterior
class MonthComparisonCard extends StatelessWidget {
  final Map<String, ComparisonData> comparisonData;

  const MonthComparisonCard({super.key, required this.comparisonData});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comparativo Mensal',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            ...comparisonData.entries.map((entry) => _buildComparisonRow(entry.value)),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow(ComparisonData data) {
    final isIncrease = data.isIncrease;
    final color = isIncrease ? Colors.red : Colors.green;
    final icon = isIncrease ? Icons.trending_up : Icons.trending_down;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(data.category, style: const TextStyle(fontSize: 14)),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'R\$ ${data.currentValue.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  'ant: R\$ ${data.previousValue.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Text(
                  '${data.percentageChange.abs().toStringAsFixed(0)}%',
                  style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget de Projeção de Saldo
class BalanceProjectionCard extends StatelessWidget {
  final ProjectionResult projection;
  final double income;

  const BalanceProjectionCard({super.key, 
    required this.projection,
    required this.income,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Projeção para Fim do Mês',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Icon(
                  projection.isPositive ? Icons.thumb_up : Icons.warning,
                  color: projection.isPositive ? Colors.green : Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Saldo projetado grande
            Center(
              child: Column(
                children: [
                  Text(
                    projection.isPositive ? 'Saldo Projetado' : 'Déficit Projetado',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    'R\$ ${projection.projectedBalance.abs().toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: projection.isPositive ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            Divider(color: Colors.grey[700]),
            const SizedBox(height: 8),
            
            _buildProjectionRow('Já gasto', projection.totalSpentSoFar, Colors.orange),
            _buildProjectionRow('Contas pendentes', projection.pendingRecurring, Colors.red),
            _buildProjectionRow('Variável estimado', projection.projectedVariableSpend, Colors.blue),
            
            const SizedBox(height: 8),
            Divider(color: Colors.grey[700]),
            const SizedBox(height: 8),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Média diária:', style: TextStyle(fontSize: 12)),
                Text(
                  'R\$ ${projection.avgDailySpend.toStringAsFixed(2)}/dia',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Dias restantes:', style: TextStyle(fontSize: 12)),
                Text(
                  '${projection.remainingDays} dias',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectionRow(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, color: color),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
          Text(
            'R\$ ${value.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Widget de Padrões de Gastos
class SpendingPatternsCard extends StatelessWidget {
  final SpendingPattern pattern;

  const SpendingPatternsCard({super.key, required this.pattern});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seus Padrões',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Insights
            _buildInsightTile(
              icon: Icons.calendar_today,
              title: 'Dia mais caro',
              value: pattern.maxSpendDayName,
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            
            _buildInsightTile(
              icon: pattern.spendsMoreOnWeekends ? Icons.weekend : Icons.work,
              title: pattern.spendsMoreOnWeekends 
                  ? 'Você gasta mais nos finais de semana' 
                  : 'Você gasta mais durante a semana',
              value: '${pattern.weekendSpendPercentage.toStringAsFixed(0)}% no fim de semana',
              color: pattern.spendsMoreOnWeekends ? Colors.purple : Colors.blue,
            ),
            const SizedBox(height: 12),
            
            _buildInsightTile(
              icon: Icons.receipt,
              title: 'Gasto médio por transação',
              value: 'R\$ ${pattern.avgTransactionValue.toStringAsFixed(2)}',
              color: Colors.green,
            ),
            
            const SizedBox(height: 16),
            
            // Gráfico de barras por dia da semana
            const Text('Gastos por dia da semana', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            _buildWeekdayChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightTile({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdayChart() {
    final days = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
    final maxValue = pattern.spendsByWeekday.values.isEmpty 
        ? 1.0 
        : pattern.spendsByWeekday.values.reduce((a, b) => a > b ? a : b);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        final weekday = index + 1;
        final value = pattern.spendsByWeekday[weekday] ?? 0;
        final height = maxValue > 0 ? (value / maxValue) * 60 : 0.0;
        
        return Column(
          children: [
            Container(
              width: 24,
              height: height + 4,
              decoration: BoxDecoration(
                color: weekday >= 6 ? Colors.purple : Colors.blue,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Text(days[index], style: const TextStyle(fontSize: 10)),
          ],
        );
      }),
    );
  }
}
