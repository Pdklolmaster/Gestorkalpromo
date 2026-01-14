import 'package:flutter/material.dart';
import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction_model.dart';
import '../models/recurring_expense.dart';
import '../services/finance_calculator.dart';
import '../services/advanced_finance_service.dart';
import '../widgets/charts.dart';

/// Página de Relatórios com Gráficos Avançados
class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Transaction> _transactions = [];
  List<RecurringExpense> _recurringExpenses = [];
  double _income = 0; // Renda Total (Salário + Extra)
  DateTime _selectedMonth = DateTime.now();

  // Watchers
  Box<Transaction>? _transactionsBox;
  Box<UserData>? _userDataBox;
  StreamSubscription<BoxEvent>? _transactionsSub;
  StreamSubscription<BoxEvent>? _userDataSub;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _transactionsSub?.cancel();
    _userDataSub?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final transactionBox = Hive.box<Transaction>('transactions');
    final userBox = Hive.box<UserData>('userData');
    final recurringBox = Hive.box<RecurringExpense>('recurringExpenses');

    setState(() {
      _transactions = transactionBox.values.toList();
      _recurringExpenses = recurringBox.values.toList();
      if (userBox.isNotEmpty) {
        final user = userBox.values.first;
        _income = user.monthlyIncome + user.extraIncome; // Renda Total
      }
    });

    // Setup watchers lazily
    _transactionsBox ??= transactionBox;
    _userDataBox ??= userBox;

    _transactionsSub ??= _transactionsBox!.watch().listen((event) {
      setState(() {
        _transactions = transactionBox.values.toList();
      });
    });

    _userDataSub ??= _userDataBox!.watch().listen((event) {
      if (userBox.isNotEmpty) {
        final user = userBox.values.first;
        setState(() {
          _income = user.monthlyIncome + user.extraIncome;
        });
      }
    });
  }

  List<Transaction> get _monthTransactions {
    return _transactions.where((t) =>
        t.date.month == _selectedMonth.month &&
        t.date.year == _selectedMonth.year).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Visão Geral', icon: Icon(Icons.pie_chart)),
            Tab(text: 'Tendências', icon: Icon(Icons.show_chart)),
            Tab(text: 'Projeções', icon: Icon(Icons.trending_up)),
            Tab(text: 'Padrões', icon: Icon(Icons.insights)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildTrendsTab(),
          _buildProjectionsTab(),
          _buildPatternsTab(),
        ],
      ),
    );
  }

  /// Tab 1: Visão Geral com gráficos de pizza e barras
  Widget _buildOverviewTab() {
    final spentByCategory = FinanceCalculator.getSpentByCategory(_monthTransactions);
    final totalSpent = spentByCategory.values.fold(0.0, (a, b) => a + b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seletor de mês
          _buildMonthSelector(),
          const SizedBox(height: 16),

          // Resumo do mês
          _buildMonthSummaryCard(totalSpent),
          const SizedBox(height: 16),

          // Gráfico de Pizza
          const Text('Distribuição por Categoria', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildPieChart(spentByCategory),
          const SizedBox(height: 24),

          // Gráfico de Barras
          const Text('Gastos por Categoria', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildBarChart(spentByCategory),
          const SizedBox(height: 24),

          // Heatmap
          SpendingHeatmap(
            transactions: _monthTransactions,
            selectedMonth: _selectedMonth,
          ),
        ],
      ),
    );
  }

  /// Tab 2: Tendências com gráfico de linha
  Widget _buildTrendsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Evolução dos Gastos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // Gráfico de linha - últimos 6 meses
          _buildLineChart(),
          const SizedBox(height: 24),

          // Comparativo mensal
          const Text('Comparativo com Mês Anterior', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildComparisonCard(),
          const SizedBox(height: 24),

          // Gráfico de área - acumulado
          const Text('Gastos Acumulados no Mês', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildAreaChart(),
        ],
      ),
    );
  }

  /// Tab 3: Projeções
  Widget _buildProjectionsTab() {
    // Converter RecurringExpense para RecurringExpenseData
    final recurringData = _recurringExpenses.map((e) => RecurringExpenseData(
      title: e.title,
      amount: e.amount,
      dayOfMonth: e.dayOfMonth,
      isActive: e.isActive,
    )).toList();
    
    // Saldo = Renda Total - Gastos (CALCULADO)
    final totalSpentThisMonth = _monthTransactions.fold(0.0, (sum, t) => sum + t.amount);
    final saldoDisponivel = _income - totalSpentThisMonth;
    
    final projection = AdvancedFinanceService.projectEndOfMonth(
      currentBalance: saldoDisponivel,
      monthlyIncome: _income,
      transactionsThisMonth: _monthTransactions,
      recurringExpenses: recurringData,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BalanceProjectionCard(
            projection: projection,
            income: _income,
          ),
          const SizedBox(height: 16),

          // Gauge de saúde financeira
          _buildFinancialHealthGauge(projection),
          const SizedBox(height: 16),

          // Dicas baseadas na projeção
          _buildProjectionTips(projection),
        ],
      ),
    );
  }

  /// Tab 4: Padrões de comportamento
  Widget _buildPatternsTab() {
    final pattern = AdvancedFinanceService.analyzePatterns(_monthTransactions);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SpendingPatternsCard(pattern: pattern),
          const SizedBox(height: 16),

          // Top gastos
          _buildTopExpensesCard(),
          const SizedBox(height: 16),

          // Radar chart de categorias
          const Text('Perfil de Gastos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildRadarChart(),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Card(
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  _selectedMonth = DateTime(
                    _selectedMonth.year,
                    _selectedMonth.month - 1,
                  );
                });
              },
            ),
            Text(
              '${_getMonthName(_selectedMonth.month)} ${_selectedMonth.year}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                setState(() {
                  _selectedMonth = DateTime(
                    _selectedMonth.year,
                    _selectedMonth.month + 1,
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSummaryCard(double totalSpent) {
    final remaining = _income - totalSpent;
    final percentUsed = _income > 0 ? (totalSpent / _income * 100) : 0;

    return Card(
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('Renda', _income, Colors.green),
                _buildSummaryItem('Gasto', totalSpent, Colors.red),
                _buildSummaryItem('Saldo', remaining, remaining >= 0 ? Colors.blue : Colors.orange),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (percentUsed / 100).clamp(0, 1),
                backgroundColor: Colors.grey[700],
                color: percentUsed > 100 ? Colors.red : percentUsed > 80 ? Colors.orange : Colors.green,
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${percentUsed.toStringAsFixed(0)}% do orçamento utilizado',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, double value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          'R\$ ${value.toStringAsFixed(0)}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildPieChart(Map<String, double> data) {
    if (data.isEmpty || data.values.every((v) => v == 0)) {
      return _buildEmptyChart('Nenhum gasto registrado');
    }

    final total = data.values.fold(0.0, (a, b) => a + b);
    final colors = {
      'Necessidade': Colors.red,
      'Desejos Lazer': Colors.orange,
      'Investimento': Colors.green,
    };

    return Card(
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: Row(
            children: [
              Expanded(
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: data.entries.map((entry) {
                      final percentage = total > 0 ? (entry.value / total * 100) : 0;
                      return PieChartSectionData(
                        value: entry.value,
                        title: '${percentage.toStringAsFixed(0)}%',
                        color: colors[entry.key] ?? Colors.grey,
                        radius: 50,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: data.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          color: colors[entry.key] ?? Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(entry.key, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(Map<String, double> data) {
    if (data.isEmpty) return _buildEmptyChart('Sem dados');

    final colors = {
      'Necessidade': Colors.red,
      'Desejos Lazer': Colors.orange,
      'Investimento': Colors.green,
    };

    final budgets = FinanceCalculator.getBudgets(_income);

    return Card(
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: budgets.values.reduce((a, b) => a > b ? a : b) * 1.2,
              barGroups: data.entries.toList().asMap().entries.map((entry) {
                final index = entry.key;
                final category = entry.value.key;
                final spent = entry.value.value;
                final budget = budgets[category] ?? 0;

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: budget,
                      color: Colors.grey[700],
                      width: 20,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    BarChartRodData(
                      toY: spent,
                      color: colors[category] ?? Colors.blue,
                      width: 20,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }).toList(),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final categories = data.keys.toList();
                      if (value.toInt() < categories.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            categories[value.toInt()].substring(0, 3),
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    // Últimos 6 meses
    final months = <DateTime>[];
    for (int i = 5; i >= 0; i--) {
      months.add(DateTime(DateTime.now().year, DateTime.now().month - i, 1));
    }

    final monthlySpends = months.map((month) {
      final monthTransactions = _transactions.where((t) =>
          t.date.month == month.month && t.date.year == month.year);
      return monthTransactions.fold(0.0, (sum, t) => sum + t.amount);
    }).toList();

    final maxY = monthlySpends.isEmpty ? 1000.0 : 
        monthlySpends.reduce((a, b) => a > b ? a : b) * 1.2;

    final interval = maxY > 0 ? maxY / 4 : 100.0; // Evita divisão por zero

    return Card(
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: interval,
                getDrawingHorizontalLine: (value) {
                  return FlLine(color: Colors.grey[800], strokeWidth: 1);
                },
              ),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() < months.length) {
                        return Text(
                          _getMonthName(months[value.toInt()].month).substring(0, 3),
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: 5,
              minY: 0,
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: monthlySpends.asMap().entries.map((e) {
                    return FlSpot(e.key.toDouble(), e.value);
                  }).toList(),
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blue.withValues(alpha: 0.2),
                  ),
                  dotData: const FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonCard() {
    final previousMonth = _transactions.where((t) =>
        t.date.month == (_selectedMonth.month == 1 ? 12 : _selectedMonth.month - 1) &&
        t.date.year == (_selectedMonth.month == 1 ? _selectedMonth.year - 1 : _selectedMonth.year)
    ).toList();
    
    final comparisonData = AdvancedFinanceService.compareMonths(
      _monthTransactions,
      previousMonth,
    );

    return MonthComparisonCard(comparisonData: comparisonData);
  }

  Widget _buildAreaChart() {
    // Gastos acumulados dia a dia
    final daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    final dailyAccumulated = <FlSpot>[];
    double accumulated = 0;

    for (int day = 1; day <= daysInMonth; day++) {
      final daySpend = _monthTransactions
          .where((t) => t.date.day == day)
          .fold(0.0, (sum, t) => sum + t.amount);
      accumulated += daySpend;
      dailyAccumulated.add(FlSpot(day.toDouble(), accumulated));
    }

    return Card(
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 150,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 7,
                    getTitlesWidget: (value, meta) {
                      return Text('${value.toInt()}', style: const TextStyle(fontSize: 10));
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                // Linha de budget
                LineChartBarData(
                  spots: [
                    const FlSpot(1, 0),
                    FlSpot(daysInMonth.toDouble(), _income),
                  ],
                  isCurved: false,
                  color: Colors.grey,
                  barWidth: 1,
                  dashArray: [5, 5],
                  dotData: const FlDotData(show: false),
                ),
                // Linha de gastos acumulados
                LineChartBarData(
                  spots: dailyAccumulated,
                  isCurved: true,
                  color: Colors.orange,
                  barWidth: 2,
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.orange.withValues(alpha: 0.2),
                  ),
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialHealthGauge(ProjectionResult projection) {
    // Score de 0 a 100
    final score = _calculateHealthScore(projection);
    final color = score > 70 ? Colors.green : score > 40 ? Colors.orange : Colors.red;
    final label = score > 70 ? 'Excelente' : score > 40 ? 'Atenção' : 'Crítico';

    return Card(
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Saúde Financeira', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[700],
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '${score.toInt()}',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
                    ),
                    Text(label, style: TextStyle(fontSize: 12, color: color)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _calculateHealthScore(ProjectionResult projection) {
    double score = 100.0;
    
    // Penaliza se projeção é negativa
    if (!projection.isPositive) {
      score -= 40.0;
    }
    
    // Penaliza baseado na % gasta
    final percentSpent = _income > 0 ? (projection.totalSpentSoFar / _income * 100) : 0.0;
    if (percentSpent > 100) {
      score -= 30.0;
    } else if (percentSpent > 80) score -= 15.0;
    
    // Bônus se média diária está sob controle
    final idealDaily = _income / 30.0;
    if (projection.avgDailySpend < idealDaily) score += 10.0;
    
    return score.clamp(0.0, 100.0);
  }

  Widget _buildProjectionTips(ProjectionResult projection) {
    final tips = <Map<String, dynamic>>[];

    if (!projection.isPositive) {
      tips.add({
        'icon': Icons.warning,
        'color': Colors.red,
        'text': 'Atenção! Você pode terminar o mês no vermelho.',
      });
    }

    if (projection.avgDailySpend > _income / 30) {
      tips.add({
        'icon': Icons.trending_down,
        'color': Colors.orange,
        'text': 'Reduza seus gastos diários para R\$ ${(_income / 30).toStringAsFixed(2)}',
      });
    }

    if (projection.pendingRecurring > 0) {
      tips.add({
        'icon': Icons.event,
        'color': Colors.blue,
        'text': 'Ainda há R\$ ${projection.pendingRecurring.toStringAsFixed(2)} em contas pendentes',
      });
    }

    if (tips.isEmpty) {
      tips.add({
        'icon': Icons.check_circle,
        'color': Colors.green,
        'text': 'Parabéns! Você está no caminho certo!',
      });
    }

    return Card(
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dicas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...tips.map((tip) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(tip['icon'], color: tip['color'], size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(tip['text'], style: const TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTopExpensesCard() {
    final sorted = List<Transaction>.from(_monthTransactions)
      ..sort((a, b) => b.amount.compareTo(a.amount));
    final top5 = sorted.take(5).toList();

    return Card(
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Maiores Gastos do Mês', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (top5.isEmpty)
              const Text('Nenhuma transação', style: TextStyle(color: Colors.grey))
            else
              ...top5.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final t = entry.value;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.withValues(alpha: 0.2),
                    child: Text('$index', style: const TextStyle(color: Colors.blue)),
                  ),
                  title: Text(t.title),
                  subtitle: Text(t.category),
                  trailing: Text(
                    'R\$ ${t.amount.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  dense: true,
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildRadarChart() {
    final spentByCategory = FinanceCalculator.getSpentByCategory(_monthTransactions);
    final budgets = FinanceCalculator.getBudgets(_income);

    // Calcula percentual de cada categoria
    final dataEntries = <RadarEntry>[];
    for (final category in ['Necessidade', 'Desejos Lazer', 'Investimento']) {
      final spent = spentByCategory[category] ?? 0.0;
      final budget = budgets[category] ?? 1.0;
      final percent = (spent / budget * 100).clamp(0.0, 150.0);
      dataEntries.add(RadarEntry(value: percent));
    }

    return Card(
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: RadarChart(
            RadarChartData(
              dataSets: [
                RadarDataSet(
                  dataEntries: dataEntries,
                  fillColor: Colors.blue.withValues(alpha: 0.3),
                  borderColor: Colors.blue,
                  borderWidth: 2,
                ),
                RadarDataSet(
                  dataEntries: [
                    const RadarEntry(value: 100),
                    const RadarEntry(value: 100),
                    const RadarEntry(value: 100),
                  ],
                  fillColor: Colors.transparent,
                  borderColor: Colors.grey,
                  borderWidth: 1,
                ),
              ],
              radarBackgroundColor: Colors.transparent,
              borderData: FlBorderData(show: false),
              radarBorderData: BorderSide(color: Colors.grey[700]!, width: 1),
              titlePositionPercentageOffset: 0.2,
              titleTextStyle: const TextStyle(fontSize: 12, color: Colors.white),
              getTitle: (index, angle) {
                switch (index) {
                  case 0:
                    return const RadarChartTitle(text: 'Necessidade');
                  case 1:
                    return const RadarChartTitle(text: 'Desejos Lazer');
                  case 2:
                    return const RadarChartTitle(text: 'Investimento');
                  default:
                    return const RadarChartTitle(text: '');
                }
              },
              tickCount: 3,
              ticksTextStyle: const TextStyle(fontSize: 8, color: Colors.grey),
              tickBorderData: BorderSide(color: Colors.grey[800]!, width: 1),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyChart(String message) {
    return Card(
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.pie_chart, size: 48, color: Colors.grey[600]),
              const SizedBox(height: 12),
              Text(message, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return months[month - 1];
  }
}
