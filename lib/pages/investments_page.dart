import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/investment.dart';
import '../services/investment_service.dart';
import '../theme/app_theme.dart';

/// Página de gerenciamento de Investimentos
class InvestmentsPage extends StatefulWidget {
  const InvestmentsPage({super.key});

  @override
  State<InvestmentsPage> createState() => _InvestmentsPageState();
}

class _InvestmentsPageState extends State<InvestmentsPage> {
  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void initState() {
    super.initState();
    // Aplica rendimentos pendentes ao abrir a página
    _applyPendingYields();
  }

  Future<void> _applyPendingYields() async {
    final totalYield = await InvestmentService.applyAllYields();
    if (totalYield > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rendimento aplicado: ${currencyFormat.format(totalYield)}'),
          backgroundColor: AppTheme.investimento,
        ),
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.investimento.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.trending_up_rounded, color: AppTheme.investimento, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Investimentos'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Aplicar Rendimentos',
            onPressed: _applyPendingYields,
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Investment>('investments').listenable(),
        builder: (context, Box<Investment> box, _) {
          final investments = box.values.toList();

          if (investments.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              _buildSummaryCard(investments),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: investments.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _buildInvestmentCard(investments[index]),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Novo Investimento'),
        backgroundColor: AppTheme.investimento,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.investimento.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.trending_up_rounded, size: 64, color: AppTheme.investimento),
          ),
          const SizedBox(height: 24),
          const Text(
            'Nenhum investimento cadastrado',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Adicione uma caixinha para começar a render!',
            style: TextStyle(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showAddDialog(),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Criar Investimento'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.investimento,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(List<Investment> investments) {
    final totalInvested = investments.fold<double>(
        0, (sum, inv) => sum + inv.investedAmount);
    final totalCurrent = investments.fold<double>(
        0, (sum, inv) => sum + inv.currentAmount);
    final totalYield = totalCurrent - totalInvested;
    final yieldPercent = totalInvested > 0 
        ? (totalYield / totalInvested) * 100 
        : 0.0;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.investimento.withOpacity(0.2),
            AppTheme.investimento.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(
          color: AppTheme.investimento.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Investido', 
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(currencyFormat.format(totalInvested),
                      style: const TextStyle(color: AppTheme.textPrimary, 
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Saldo Atual', 
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(currencyFormat.format(totalCurrent),
                      style: const TextStyle(color: AppTheme.investimento, 
                          fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.investimento.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.trending_up_rounded, color: AppTheme.investimento, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Rendimento: ${currencyFormat.format(totalYield)} ',
                  style: const TextStyle(color: AppTheme.investimento, fontWeight: FontWeight.bold),
                ),
                Text(
                  '(${yieldPercent.toStringAsFixed(2)}%)',
                  style: const TextStyle(color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentCard(Investment investment) {
    final color = Color(investment.colorValue);
    final monthlyEstimate = investment.interestType == InterestType.monthly
        ? investment.currentAmount * investment.interestRate
        : investment.currentAmount * (investment.interestRate / 12);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(
          color: color.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDetailDialog(investment),
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(investment.icon, style: const TextStyle(fontSize: 26)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(investment.name,
                              style: const TextStyle(fontSize: 16, 
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary)),
                          const SizedBox(height: 2),
                          Text(
                            '${(investment.interestRate * 100).toStringAsFixed(2)}% ${investment.interestType == InterestType.monthly ? 'ao mês' : 'ao ano'}',
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(currencyFormat.format(investment.currentAmount),
                            style: TextStyle(fontSize: 18, 
                                fontWeight: FontWeight.bold, color: color)),
                        if (investment.totalYield > 0)
                          Text('+${currencyFormat.format(investment.totalYield)}',
                              style: const TextStyle(color: AppTheme.investimento, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(investment.autoReinvest 
                            ? Icons.autorenew_rounded : Icons.account_balance_wallet_rounded,
                            size: 14, color: AppTheme.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          investment.autoReinvest 
                              ? 'Reinveste automático' 
                              : 'Transfere para saldo',
                          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.investimento.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Rende ~${currencyFormat.format(monthlyEstimate)}/mês',
                        style: const TextStyle(fontSize: 11, color: AppTheme.investimento, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showDepositDialog(investment),
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('Depositar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.investimento,
                          side: BorderSide(color: AppTheme.investimento.withOpacity(0.5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showWithdrawDialog(investment),
                        icon: const Icon(Icons.remove_rounded, size: 16),
                        label: const Text('Resgatar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.desejo,
                          side: BorderSide(color: AppTheme.desejo.withOpacity(0.5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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

  void _showAddDialog() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final rateController = TextEditingController(text: '1.0');
    InterestType selectedType = InterestType.monthly;
    bool autoReinvest = true;
    String selectedIcon = '📈';
    int selectedColor = Colors.green.value;

    final icons = ['📈', '💰', '🏦', '💵', '🪙', '💎', '🏠', '🚗', '✈️', '🎯'];
    final colors = [
      Colors.green, Colors.blue, Colors.purple, Colors.orange, 
      Colors.teal, Colors.pink, Colors.amber, Colors.cyan,
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Novo Investimento'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    hintText: 'Ex: Caixinha Nubank',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Valor Inicial',
                    prefixText: 'R\$ ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: rateController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Taxa de Juros (%)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<InterestType>(
                      value: selectedType,
                      items: const [
                        DropdownMenuItem(
                          value: InterestType.monthly,
                          child: Text('Mensal'),
                        ),
                        DropdownMenuItem(
                          value: InterestType.annual,
                          child: Text('Anual'),
                        ),
                      ],
                      onChanged: (value) {
                        setDialogState(() => selectedType = value!);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Reinvestir automaticamente'),
                  subtitle: Text(
                    autoReinvest 
                        ? 'Rendimento soma ao investimento' 
                        : 'Rendimento vai para saldo',
                    style: const TextStyle(fontSize: 11),
                  ),
                  value: autoReinvest,
                  onChanged: (v) => setDialogState(() => autoReinvest = v),
                ),
                const SizedBox(height: 16),
                const Text('Ícone:', style: TextStyle(fontSize: 12)),
                Wrap(
                  spacing: 8,
                  children: icons.map((icon) => GestureDetector(
                    onTap: () => setDialogState(() => selectedIcon = icon),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: selectedIcon == icon 
                            ? Colors.blue.withOpacity(0.3) 
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(icon, style: const TextStyle(fontSize: 24)),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 12),
                const Text('Cor:', style: TextStyle(fontSize: 12)),
                Wrap(
                  spacing: 8,
                  children: colors.map((color) => GestureDetector(
                    onTap: () => setDialogState(() => selectedColor = color.value),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: selectedColor == color.value
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final amount = double.tryParse(
                    amountController.text.replaceAll(',', '.')) ?? 0;
                final rate = (double.tryParse(
                    rateController.text.replaceAll(',', '.')) ?? 1) / 100;

                if (name.isEmpty || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Preencha nome e valor')),
                  );
                  return;
                }

                final investment = Investment(
                  id: InvestmentService.generateId(),
                  name: name,
                  investedAmount: amount,
                  interestRate: rate,
                  interestType: selectedType,
                  autoReinvest: autoReinvest,
                  icon: selectedIcon,
                  colorValue: selectedColor,
                  createdAt: DateTime.now(),
                );

                await InvestmentService.add(investment);
                Navigator.pop(context);
                setState(() {});
              },
              child: const Text('Criar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDepositDialog(Investment investment) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Depositar em ${investment.name}'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Valor',
            prefixText: 'R\$ ',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(
                  controller.text.replaceAll(',', '.')) ?? 0;
              if (amount > 0) {
                await InvestmentService.deposit(investment.id, amount);
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text('Depositar'),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog(Investment investment) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Resgatar de ${investment.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Saldo disponível: ${currencyFormat.format(investment.currentAmount)}',
              style: TextStyle(color: Colors.grey[400]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Valor',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(
                  controller.text.replaceAll(',', '.')) ?? 0;
              if (amount > 0 && amount <= investment.currentAmount) {
                await InvestmentService.withdraw(investment.id, amount);
                Navigator.pop(context);
                setState(() {});
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Valor inválido ou insuficiente')),
                );
              }
            },
            child: const Text('Resgatar'),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(Investment investment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(investment.icon),
            const SizedBox(width: 8),
            Expanded(child: Text(investment.name)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Valor Investido', 
                  currencyFormat.format(investment.investedAmount)),
              _buildDetailRow('Saldo Atual', 
                  currencyFormat.format(investment.currentAmount)),
              _buildDetailRow('Rendimento', 
                  '+${currencyFormat.format(investment.totalYield)} (${investment.yieldPercentage.toStringAsFixed(2)}%)'),
              const Divider(),
              _buildDetailRow('Taxa', 
                  '${(investment.interestRate * 100).toStringAsFixed(2)}% ${investment.interestType == InterestType.monthly ? 'ao mês' : 'ao ano'}'),
              _buildDetailRow('Modo', 
                  investment.autoReinvest ? 'Reinveste' : 'Transfere'),
              _buildDetailRow('Criado em', 
                  DateFormat('dd/MM/yyyy').format(investment.createdAt)),
              _buildDetailRow('Último rendimento', 
                  DateFormat('dd/MM/yyyy').format(investment.lastYieldDate)),
              if (investment.yieldHistory.isNotEmpty) ...[
                const Divider(),
                const Text('Histórico de Rendimentos:', 
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...investment.yieldHistory.take(5).map((record) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('dd/MM').format(record.date),
                          style: const TextStyle(fontSize: 12)),
                      Text('+${currencyFormat.format(record.amount)}',
                          style: const TextStyle(fontSize: 12, color: Colors.green)),
                    ],
                  ),
                )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Excluir investimento?'),
                  content: const Text('Esta ação não pode ser desfeita.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Excluir', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await InvestmentService.delete(investment.id);
                setState(() {});
              }
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
