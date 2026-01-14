import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../theme/app_theme.dart';

class TransactionFormDialog extends StatefulWidget {
  final Transaction? transaction;
  final Map<String, dynamic>? prefilled;
  final Function(Transaction) onSave;

  const TransactionFormDialog({
    this.transaction,
    this.prefilled,
    required this.onSave,
  });

  @override
  State<TransactionFormDialog> createState() => _TransactionFormDialogState();
}

class _TransactionFormDialogState extends State<TransactionFormDialog> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late String _selectedCategory;
  late DateTime _selectedDate;
  String _selectedSource = 'main';

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Necessidade', 'icon': Icons.home_rounded, 'color': AppTheme.necessidade},
    {'name': 'Desejos Lazer', 'icon': Icons.favorite_rounded, 'color': AppTheme.desejo},
    {'name': 'Investimento', 'icon': Icons.trending_up_rounded, 'color': AppTheme.investimento},
  ];

  @override
  void initState() {
    super.initState();
    String initialTitle = widget.transaction?.title ?? widget.prefilled?['title'] ?? '';
    double initialAmount = widget.transaction?.amount ?? widget.prefilled?['amount'] ?? 0.0;
    String initialCategory = widget.transaction?.category ?? widget.prefilled?['category'] ?? 'Necessidade';
    DateTime initialDate = widget.transaction?.date ?? widget.prefilled?['date'] ?? DateTime.now();
    _selectedSource = widget.transaction?.source ?? 'main';

    _titleController = TextEditingController(text: initialTitle);
    _amountController = TextEditingController(text: initialAmount > 0 ? initialAmount.toStringAsFixed(2) : '');
    _selectedCategory = initialCategory;
    _selectedDate = initialDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Preencha todos os campos'), backgroundColor: AppTheme.error));
      return;
    }
    final transaction = Transaction(
      title: _titleController.text,
      amount: double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0.0,
      category: _selectedCategory,
      date: _selectedDate,
      source: _selectedSource,
    );
    widget.onSave(transaction);
    Navigator.pop(context);
  }

  Color _getCategoryColor() {
    final cat = _categories.firstWhere((c) => c['name'] == _selectedCategory, orElse: () => _categories[0]);
    return cat['color'] as Color;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.cardBackground,
      title: Text(widget.transaction == null ? 'Nova Transação' : 'Editar Transação', style: TextStyle(color: AppTheme.textPrimary)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              style: TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(hintText: 'Descrição', filled: true, fillColor: AppTheme.surfaceLight),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(hintText: '0.00', prefixText: 'R\$ ', filled: true, fillColor: AppTheme.surfaceLight),
            ),
            SizedBox(height: 16),
            // Seletor de Fonte
            DropdownButtonFormField<String>(
              value: _selectedSource,
              dropdownColor: AppTheme.cardBackground,
              decoration: InputDecoration(filled: true, fillColor: AppTheme.surfaceLight, labelText: 'Debitar de'),
              items: [
                DropdownMenuItem(value: 'main', child: Text('Saldo Principal', style: TextStyle(color: AppTheme.textPrimary))),
                DropdownMenuItem(value: 'redeemed', child: Text('Saldo Resgatado', style: TextStyle(color: AppTheme.textPrimary))),
              ],
              onChanged: (v) => setState(() => _selectedSource = v!),
            ),
            SizedBox(height: 16),
            // Categorias
            Wrap(
              spacing: 8,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat['name'];
                return ChoiceChip(
                  label: Text(cat['name']),
                  selected: isSelected,
                  selectedColor: cat['color'].withOpacity(0.3),
                  backgroundColor: AppTheme.surfaceLight,
                  labelStyle: TextStyle(color: isSelected ? cat['color'] : AppTheme.textMuted),
                  onSelected: (b) => setState(() => _selectedCategory = cat['name']),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
        ElevatedButton(onPressed: _handleSave, style: ElevatedButton.styleFrom(backgroundColor: _getCategoryColor()), child: Text('Salvar')),
      ],
    );
  }
}

class IncomeEditDialog extends StatefulWidget {
  final double monthlyIncome;
  final double extraIncome;
  final Function(double, double) onSave;

  const IncomeEditDialog({required this.monthlyIncome, required this.extraIncome, required this.onSave});

  @override
  State<IncomeEditDialog> createState() => _IncomeEditDialogState();
}

class _IncomeEditDialogState extends State<IncomeEditDialog> {
  late TextEditingController _extraController;
  bool _isAdding = true;

  @override
  void initState() {
    super.initState();
    _extraController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: Text('Renda Extra'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(child: ChoiceChip(label: Text('Adicionar'), selected: _isAdding, onSelected: (b) => setState(() => _isAdding = true), selectedColor: Colors.green.withOpacity(0.3))),
              SizedBox(width: 8),
              Expanded(child: ChoiceChip(label: Text('Remover'), selected: !_isAdding, onSelected: (b) => setState(() => _isAdding = false), selectedColor: Colors.red.withOpacity(0.3))),
            ],
          ),
          SizedBox(height: 16),
          TextField(
            controller: _extraController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: 'Valor', prefixText: 'R\$ '),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
        ElevatedButton(
          onPressed: () {
            final val = double.tryParse(_extraController.text.replaceAll(',', '.')) ?? 0;
            if (val > 0) {
              final newExtra = _isAdding ? widget.extraIncome + val : (widget.extraIncome - val).clamp(0.0, double.infinity);
              widget.onSave(widget.monthlyIncome, newExtra);
              Navigator.pop(context);
            }
          },
          child: Text('Confirmar'),
        ),
      ],
    );
  }
}

class BalanceEditDialog extends StatefulWidget {
  final double currentBalance;
  final double calculatedBalance;
  final double monthlyIncome;
  final double extraIncome;
  final double totalGastos;
  final double restanteAtual;
  final bool isOverride;
  final Function(double) onSave;
  final VoidCallback onReset;

  const BalanceEditDialog({
    required this.currentBalance,
    required this.calculatedBalance,
    required this.monthlyIncome,
    required this.extraIncome,
    required this.totalGastos,
    required this.restanteAtual,
    required this.isOverride,
    required this.onSave,
    required this.onReset,
  });

  @override
  State<BalanceEditDialog> createState() => _BalanceEditDialogState();
}

class _BalanceEditDialogState extends State<BalanceEditDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentBalance.toStringAsFixed(2));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: Text('Ajustar Saldo Base'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Defina o saldo inicial manualmente. Os gastos serão subtraídos deste valor.', style: TextStyle(fontSize: 12, color: Colors.grey)),
          SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: 'Saldo Base', prefixText: 'R\$ '),
          ),
          if (widget.isOverride)
            TextButton(onPressed: () { widget.onReset(); Navigator.pop(context); }, child: Text('Resetar para Automático')),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
        ElevatedButton(
          onPressed: () {
            final val = double.tryParse(_controller.text.replaceAll(',', '.'));
            if (val != null) {
              widget.onSave(val);
              Navigator.pop(context);
            }
          },
          child: Text('Salvar'),
        ),
      ],
    );
  }
}

class SalaryConfigDialog extends StatefulWidget {
  final double? currentSalary;
  final int? currentPaymentDay;
  final bool? isActive;
  final Function(double, int, bool) onSave;

  const SalaryConfigDialog({this.currentSalary, this.currentPaymentDay, this.isActive, required this.onSave});

  @override
  State<SalaryConfigDialog> createState() => _SalaryConfigDialogState();
}

class _SalaryConfigDialogState extends State<SalaryConfigDialog> {
  late TextEditingController _salaryController;
  late int _selectedDay;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _salaryController = TextEditingController(text: widget.currentSalary?.toStringAsFixed(2) ?? '');
    _selectedDay = widget.currentPaymentDay ?? 5;
    _isActive = widget.isActive ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: Text('Configurar Salário'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _salaryController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: 'Valor', prefixText: 'R\$ '),
          ),
          SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: _selectedDay,
            decoration: InputDecoration(labelText: 'Dia do Pagamento'),
            items: List.generate(30, (i) => i + 1).map((d) => DropdownMenuItem(value: d, child: Text('Dia $d'))).toList(),
            onChanged: (v) => setState(() => _selectedDay = v!),
          ),
          SwitchListTile(title: Text('Automático'), value: _isActive, onChanged: (v) => setState(() => _isActive = v)),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
        ElevatedButton(
          onPressed: () {
            final val = double.tryParse(_salaryController.text.replaceAll(',', '.')) ?? 0;
            if (val > 0) {
              widget.onSave(val, _selectedDay, _isActive);
              Navigator.pop(context);
            }
          },
          child: Text('Salvar'),
        ),
      ],
    );
  }
}