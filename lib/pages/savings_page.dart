import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/savings_fund.dart';
import '../models/transaction_model.dart';
import '../services/data_service.dart';
import '../services/advanced_finance_service.dart';

/// Página de Fundos de Reserva (Auto-gerenciada)
class SavingsPage extends StatefulWidget {
  const SavingsPage({super.key});

  @override
  State<SavingsPage> createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> {
  late Box<SavingsFund> _box;
  List<SavingsFund> _funds = [];

  @override
  void initState() {
    super.initState();
    _loadFunds();
  }

  Future<void> _loadFunds() async {
    _box = Hive.box<SavingsFund>('savingsFunds');
    setState(() {
      _funds = _box.values.toList();
    });
  }

  void _addFund(SavingsFund fund) {
    _box.put(fund.id, fund);
    setState(() {
      _funds = _box.values.toList();
    });
  }

  void _addToFund(SavingsFund fund, double amount) {
    final updated = fund.copyWith(currentAmount: fund.currentAmount + amount);
    _box.put(fund.id, updated);
    setState(() {
      _funds = _box.values.toList();
    });
  }

  void _deleteFund(String id) {
    _box.delete(id);
    setState(() {
      _funds = _box.values.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalSaved = _funds.fold(0.0, (sum, f) => sum + f.currentAmount);
    final totalTarget = _funds.fold(0.0, (sum, f) => sum + f.targetAmount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Investimentos'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryCard(totalSaved, totalTarget),
            const SizedBox(height: 24),
            
            if (_funds.isEmpty)
              _buildEmptyState(context)
            else
              ..._funds.map((fund) => _buildFundCard(context, fund)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddFundDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Novo Investimento'),
      ),
    );
  }

  Widget _buildSummaryCard(double totalSaved, double totalTarget) {
    final progress = totalTarget > 0 ? totalSaved / totalTarget : 0.0;
    
    return Card(
      color: Colors.green.shade900,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Total Economizado', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text(
              'R\$ ${totalSaved.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              'de R\$ ${totalTarget.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress.clamp(0, 1),
                backgroundColor: Colors.white24,
                color: Colors.white,
                minHeight: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFundCard(BuildContext context, SavingsFund fund) {
    return Card(
      color: Colors.grey[850],
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showFundDetailsDialog(context, fund),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color(fund.colorValue).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(fund.icon, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fund.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        if (fund.targetDate != null)
                          Text(
                            'Meta: ${_formatDate(fund.targetDate!)}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.green),
                    onPressed: () => _showAddAmountDialog(context, fund),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'R\$ ${fund.currentAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'de R\$ ${fund.targetAmount.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: fund.progressPercentage,
                  backgroundColor: Colors.grey[700],
                  color: Color(fund.colorValue),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(fund.progressPercentage * 100).toInt()}% • Faltam R\$ ${fund.remainingAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 48),
          const Text('🎯', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            'Nenhum investimento ainda',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Crie investimentos para acompanhar\nsuas economias',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddFundDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Criar Primeiro Investimento'),
          ),
        ],
      ),
    );
  }

  void _showAddFundDialog(BuildContext context) {
    String name = '';
    double target = 0;
    String selectedIcon = '💰';
    
    final icons = ['💰', '🏠', '🚗', '✈️', '💻', '📱', '🎓', '💍', '🛡️', '🎯'];
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Novo Investimento'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Nome do Investimento',
                    hintText: 'Ex: Reserva de Emergência',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => name = v,
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Valor Alvo (R\$)',
                    hintText: 'Ex: 5000',
                    border: OutlineInputBorder(),
                    prefixText: 'R\$ ',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => target = double.tryParse(v) ?? 0,
                ),
                const SizedBox(height: 16),
                const Text('Ícone:', style: TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: icons.map((icon) => GestureDetector(
                    onTap: () => setState(() => selectedIcon = icon),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: selectedIcon == icon ? Colors.blue : Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(child: Text(icon, style: const TextStyle(fontSize: 20))),
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
              onPressed: () {
                if (name.isEmpty || target <= 0) return;
                
                final fund = SavingsFund(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  targetAmount: target,
                  icon: selectedIcon,
                  createdAt: DateTime.now(),
                );
                _addFund(fund);
                Navigator.pop(context);
              },
              child: const Text('Criar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAmountDialog(BuildContext context, SavingsFund fund) {
    double amount = 0;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Adicionar a ${fund.name}'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Valor (R\$)',
            border: OutlineInputBorder(),
            prefixText: 'R\$ ',
          ),
          keyboardType: TextInputType.number,
          onChanged: (v) => amount = double.tryParse(v) ?? 0,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (amount > 0) {
                Navigator.pop(context);
                _showWithdrawalOptionDialog(context, fund, amount);
              }
            },
            child: const Text('Próximo'),
          ),
        ],
      ),
    );
  }

  void _showWithdrawalOptionDialog(BuildContext context, SavingsFund fund, double amount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escolha a Carteira'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'De qual carteira deseja retirar R\$ ${amount.toStringAsFixed(2)}?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[300]),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.maxFinite,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.savings),
                label: const Text('Renda Extra'),
                onPressed: () {
                  Navigator.pop(context);
                  _processWithdrawal(context, fund, amount, 1);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.maxFinite,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.wallet),
                label: const Text('Renda Mensal'),
                onPressed: () {
                  Navigator.pop(context);
                  _processWithdrawal(context, fund, amount, 2);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.maxFinite,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.account_balance_wallet),
                label: const Text('Ambas Carteiras'),
                onPressed: () {
                  Navigator.pop(context);
                  _processWithdrawal(context, fund, amount, 3);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _processWithdrawal(BuildContext context, SavingsFund fund, double amount, int option) async {
    try {
      final dataService = DataService();
      await dataService.init();
      final userData = dataService.getUserData();
      
      if (userData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro: Renda não configurada'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Usar a função withdrawForInvestment
      final result = AdvancedFinanceService.withdrawForInvestment(
        monthlyIncome: userData.monthlyIncome,
        extraIncome: userData.extraIncome,
        amountNeeded: amount,
        withdrawalOption: option,
      );

      if (!result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${result.message}'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Atualizar saldo atual (Renda Total) e registrar transação de Investimento
      final updatedUserData = UserData(
        monthlyIncome: userData.monthlyIncome, // salário fixo permanece
        extraIncome: userData.extraIncome,     // renda extra permanece
        currentBalance: (userData.currentBalance - amount).clamp(0, double.infinity),
        lastUpdated: DateTime.now(),
      );
      await dataService.setUserData(updatedUserData);

      // Registrar transação para refletir no relatório e home (Investimento 20%)
      final investmentTx = Transaction(
        title: 'Depósito Investimento: ${fund.name}',
        amount: amount,
        category: 'Investimento',
        date: DateTime.now(),
      );
      await dataService.addTransaction(investmentTx);

      // Adicionar valor ao fundo escolhido
      _addToFund(fund, amount);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showFundDetailsDialog(BuildContext context, SavingsFund fund) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(fund.icon, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(fund.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            
            ListTile(
              leading: const Icon(Icons.add_circle, color: Colors.green),
              title: const Text('Adicionar Valor'),
              onTap: () {
                Navigator.pop(context);
                _showAddAmountDialog(context, fund);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Excluir Meta'),
              onTap: () {
                Navigator.pop(context);
                _deleteFund(fund.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
