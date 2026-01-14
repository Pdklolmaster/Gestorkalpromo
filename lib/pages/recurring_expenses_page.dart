import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/recurring_expense.dart';

/// Página de Gastos Recorrentes (Auto-gerenciada)
class RecurringExpensesPage extends StatefulWidget {
  const RecurringExpensesPage({super.key});

  @override
  State<RecurringExpensesPage> createState() => _RecurringExpensesPageState();
}

class _RecurringExpensesPageState extends State<RecurringExpensesPage> {
  late Box<RecurringExpense> _box;
  List<RecurringExpense> _expenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    _box = Hive.box<RecurringExpense>('recurringExpenses');
    setState(() {
      _expenses = _box.values.toList();
    });
  }

  void _addExpense(RecurringExpense expense) {
    _box.put(expense.id, expense);
    setState(() {
      _expenses = _box.values.toList();
    });
  }

  void _toggleExpense(RecurringExpense expense) {
    final updated = expense.copyWith(isActive: !expense.isActive);
    _box.put(expense.id, updated);
    setState(() {
      _expenses = _box.values.toList();
    });
  }

  void _deleteExpense(String id) {
    _box.delete(id);
    setState(() {
      _expenses = _box.values.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final active = _expenses.where((e) => e.isActive).toList();
    final inactive = _expenses.where((e) => !e.isActive).toList();
    final monthlyTotal = active.fold(0.0, (sum, e) => sum + e.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gastos Recorrentes'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTotalCard(monthlyTotal),
            const SizedBox(height: 24),
            
            Text(
              'Ativos (${active.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            if (active.isEmpty)
              _buildEmptyHint()
            else
              ...active.map((e) => _buildExpenseCard(e)),
            
            if (inactive.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Inativos (${inactive.length})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              ...inactive.map((e) => _buildExpenseCard(e)),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Novo'),
      ),
    );
  }

  Widget _buildTotalCard(double total) {
    return Card(
      color: Colors.blue.shade900,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Total Mensal Fixo', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text(
              'R\$ ${total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              '${_expenses.where((e) => e.isActive).length} despesas ativas',
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyHint() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[700]!, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.repeat, size: 48, color: Colors.grey[600]),
          const SizedBox(height: 12),
          Text('Nenhuma despesa recorrente', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
          Text('Adicione aluguel, streaming, etc.', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(RecurringExpense expense) {
    final categoryColors = {
      'necessidades': Colors.red,
      'necessidade': Colors.red,
      'desejos': Colors.orange,
      'desejo': Colors.orange,
      'poupanca': Colors.green,
      'meta': Colors.green,
    };
    
    final color = categoryColors[expense.category.toLowerCase()] ?? Colors.blue;
    final isActive = expense.isActive;
    
    return Card(
      color: isActive ? Colors.grey[850] : Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text('Dia\n${expense.dayOfMonth}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ),
        title: Text(
          expense.title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            decoration: isActive ? null : TextDecoration.lineThrough,
            color: isActive ? Colors.white : Colors.grey,
          ),
        ),
        subtitle: Text(
          '${expense.category}${expense.subcategory.isNotEmpty ? ' > ${expense.subcategory}' : ''}',
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'R\$ ${expense.amount.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? Colors.white : Colors.grey),
            ),
            const SizedBox(width: 8),
            Switch(value: isActive, onChanged: (_) => _toggleExpense(expense), activeThumbColor: Colors.green),
          ],
        ),
        onLongPress: () => _showDeleteConfirm(expense.id),
      ),
    );
  }

  void _showDeleteConfirm(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir despesa?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteExpense(id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = 'Necessidade';
    int selectedDay = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nova Despesa Recorrente', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Nome da despesa',
                  hintText: 'Ex: Netflix, Aluguel, Academia',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Valor (R\$)',
                  prefixText: 'R\$ ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: InputDecoration(labelText: 'Categoria', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                items: ['Necessidade', 'Desejo', 'Meta'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setModalState(() => selectedCategory = v!),
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<int>(
                initialValue: selectedDay,
                decoration: InputDecoration(labelText: 'Dia de cobrança', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                items: List.generate(28, (i) => i + 1).map((d) => DropdownMenuItem(value: d, child: Text('Dia $d'))).toList(),
                onChanged: (v) => setModalState(() => selectedDay = v!),
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final amount = double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0;
                    
                    if (title.isEmpty || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preencha todos os campos')));
                      return;
                    }
                    
                    final expense = RecurringExpense(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: title,
                      amount: amount,
                      category: selectedCategory,
                      dayOfMonth: selectedDay,
                      createdAt: DateTime.now(),
                    );
                    
                    _addExpense(expense);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Despesa "$title" adicionada!')));
                  },
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Adicionar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
