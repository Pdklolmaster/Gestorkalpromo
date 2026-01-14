import 'package:flutter/material.dart';
import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';
import '../models/salary_config.dart';
import '../services/data_service.dart';
import '../services/finance_calculator.dart';
import '../services/input_processor.dart';
import '../widgets/cards_new.dart'; // Importa Cards e RedeemedCard
import '../widgets/forms.dart';     // Importa Dialogs
import '../widgets/smart_input_dialog.dart';
import '../services/action_bus.dart';
import '../theme/app_theme.dart';

class DashboardPage extends StatefulWidget {
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late DataService _dataService;
  late InputProcessor _inputProcessor;
  
  double _income = 0.0;
  double _extraIncome = 0.0;
  double _redeemedBalance = 0.0; 
  
  List<Transaction> _transactions = [];
  SalaryConfig? _salaryConfig;
  double? _balanceOverride;
  
  Box<Transaction>? _transactionsBox;
  Box<UserData>? _userDataBox;
  StreamSubscription<BoxEvent>? _transactionsSub;
  StreamSubscription<BoxEvent>? _userDataSub;

  @override
  void initState() {
    super.initState();
    _dataService = DataService();
    ActionBus.stream.listen((action) {
      if (action == AppAction.showSmartInput) {
        if (mounted) {
          Future.delayed(Duration(milliseconds: 120), () {
            if (mounted) _showSmartInputDialog();
          });
        }
      } else if (action == AppAction.showAddOptions) {
        if (mounted) {
          Future.delayed(Duration(milliseconds: 120), () {
            if (mounted) _showAddOptionsDialog();
          });
        }
      }
    });
    _inputProcessor = InputProcessor();
    _loadData();
  }

  @override
  void dispose() {
    _inputProcessor.dispose();
    _transactionsSub?.cancel();
    _userDataSub?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    await _dataService.init();
    final userData = _dataService.getUserData();
    final salaryConfig = _dataService.getSalaryConfig();
    
    setState(() {
      if (userData != null) {
        _income = userData.monthlyIncome;
        _extraIncome = userData.extraIncome;
        _redeemedBalance = userData.redeemedBalance;
        if (userData.currentBalance != 0) {
          _balanceOverride = userData.currentBalance;
        }
      }
      _salaryConfig = salaryConfig;
      _transactions = _dataService.getTransactionsByMonth(DateTime.now());
    });
    _setupWatchers();
  }

  void _setupWatchers() {
    _transactionsBox ??= Hive.box<Transaction>(DataService.transactionsBoxName);
    _userDataBox ??= Hive.box<UserData>(DataService.userDataBoxName);

    _transactionsSub ??= _transactionsBox!.watch().listen((event) {
      setState(() {
        _transactions = _dataService.getTransactionsByMonth(DateTime.now());
      });
    });

    _userDataSub ??= _userDataBox!.watch().listen((event) {
      final userData = _dataService.getUserData();
      if (userData != null) {
        setState(() {
          _income = userData.monthlyIncome;
          _extraIncome = userData.extraIncome;
          _redeemedBalance = userData.redeemedBalance;
          if (userData.currentBalance != 0) {
            _balanceOverride = userData.currentBalance;
          }
        });
      }
    });
  }

  Future<void> _addTransaction(Transaction transaction) async {
    await _dataService.addTransaction(transaction);
    if (transaction.source == 'redeemed') {
      await _dataService.consumeBalance(transaction.amount, 'redeemed');
    }
    setState(() {
      _transactions = _dataService.getTransactionsByMonth(DateTime.now());
      final u = _dataService.getUserData();
      if (u != null) _redeemedBalance = u.redeemedBalance;
    });
  }

  Future<void> _updateTransaction(int index, Transaction transaction) async {
    await _dataService.updateTransaction(index, transaction);
    setState(() {
      _transactions = _dataService.getTransactionsByMonth(DateTime.now());
    });
  }

  Future<void> _deleteTransaction(int index) async {
    await _dataService.deleteTransaction(index);
    setState(() {
      _transactions = _dataService.getTransactionsByMonth(DateTime.now());
    });
  }

  Future<void> _updateIncome(double newMonthlyIncome, double newExtraIncome) async {
    final userData = _dataService.getUserData() ?? UserData.empty();
    final updatedUserData = UserData(
      monthlyIncome: newMonthlyIncome,
      extraIncome: newExtraIncome,
      currentBalance: _balanceOverride ?? 0,
      redeemedBalance: userData.redeemedBalance,
      lastUpdated: DateTime.now(),
    );
    await _dataService.setUserData(updatedUserData);
    setState(() {
      _income = newMonthlyIncome;
      _extraIncome = newExtraIncome;
    });
  }

  Future<void> _setBalanceOverride(double newBalance) async {
    final userData = _dataService.getUserData() ?? UserData.empty();
    final updatedUserData = UserData(
      monthlyIncome: _income,
      extraIncome: _extraIncome,
      currentBalance: newBalance,
      redeemedBalance: userData.redeemedBalance,
      lastUpdated: DateTime.now(),
    );
    await _dataService.setUserData(updatedUserData);
    setState(() {
      _balanceOverride = newBalance;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saldo ajustado para R\$ ${newBalance.toStringAsFixed(2)}'), backgroundColor: Colors.teal),
    );
  }
  
  Future<void> _resetBalanceToAuto() async {
    final userData = _dataService.getUserData() ?? UserData.empty();
    final updatedUserData = UserData(
      monthlyIncome: _income,
      extraIncome: _extraIncome,
      currentBalance: 0,
      redeemedBalance: userData.redeemedBalance,
      lastUpdated: DateTime.now(),
    );
    await _dataService.setUserData(updatedUserData);
    setState(() {
      _balanceOverride = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saldo resetado para cálculo automático'), backgroundColor: Colors.blue),
    );
  }

  Future<void> _saveSalaryConfig(double salary, int paymentDay, bool isActive) async {
    final config = SalaryConfig(
      amount: salary,
      paymentDay: paymentDay,
      isActive: isActive,
      lastPaymentDate: _salaryConfig?.lastPaymentDate,
    );
    await _dataService.setSalaryConfig(config);
    setState(() {
      _salaryConfig = config;
      _income = salary;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isActive ? 'Salário de R\$ ${salary.toStringAsFixed(2)} configurado' : 'Salário automático desativado'), backgroundColor: Colors.green),
    );
  }

  void _showSalaryConfigDialog() {
    showDialog(
      context: context,
      builder: (context) => SalaryConfigDialog(
        currentSalary: _salaryConfig?.amount,
        currentPaymentDay: _salaryConfig?.paymentDay,
        isActive: _salaryConfig?.isActive,
        onSave: _saveSalaryConfig,
      ),
    );
  }

  void _showTransactionDialog({Transaction? transaction, int? index, Map<String, dynamic>? prefilled}) {
    showDialog(
      context: context,
      builder: (context) => TransactionFormDialog(
        transaction: transaction,
        prefilled: prefilled,
        onSave: (newTransaction) {
          if (index != null) {
            _updateTransaction(index, newTransaction);
          } else {
            _addTransaction(newTransaction);
          }
        },
      ),
    );
  }

  void _showExtraIncomeDialog() {
    showDialog(
      context: context,
      builder: (context) => IncomeEditDialog(
        monthlyIncome: _income,
        extraIncome: _extraIncome,
        onSave: _updateIncome,
      ),
    );
  }

  void _showTotalIncomeDialog() {
    final totalGastos = FinanceCalculator.getTotalSpentAllCategories(_transactions);
    final rendaTotal = _income + _extraIncome + _redeemedBalance;
    final saldoBase = _balanceOverride ?? rendaTotal;
    final restanteAtual = saldoBase - totalGastos;
    
    showDialog(
      context: context,
      builder: (context) => BalanceEditDialog(
        currentBalance: saldoBase,
        calculatedBalance: rendaTotal,
        monthlyIncome: _income,
        extraIncome: _extraIncome,
        totalGastos: totalGastos,
        restanteAtual: restanteAtual,
        isOverride: _balanceOverride != null,
        onSave: _setBalanceOverride,
        onReset: _resetBalanceToAuto,
      ),
    );
  }

  void _showAddOptionsDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.textMuted.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
            SizedBox(height: 20),
            Text('Adicionar Gasto', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            SizedBox(height: 24),
            _buildOptionTile(icon: Icons.camera_alt_rounded, iconColor: AppTheme.primary, title: 'Tirar Foto', subtitle: 'Capturar nota fiscal', onTap: () { Navigator.pop(context); _processImageInput(fromCamera: true); }),
            SizedBox(height: 12),
            _buildOptionTile(icon: Icons.photo_library_rounded, iconColor: AppTheme.investimento, title: 'Galeria', subtitle: 'Selecionar foto existente', onTap: () { Navigator.pop(context); _processImageInput(fromCamera: false); }),
            SizedBox(height: 12),
            _buildOptionTile(icon: Icons.picture_as_pdf_rounded, iconColor: AppTheme.error, title: 'PDF', subtitle: 'Importar arquivo PDF', onTap: () { Navigator.pop(context); _processPDFInput(); }),
            SizedBox(height: 12),
            _buildOptionTile(icon: Icons.edit_rounded, iconColor: AppTheme.desejo, title: 'Digitar', subtitle: 'Ex: "Conta luz 220 reais"', onTap: () { Navigator.pop(context); _showTextInputDialog(); }),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({required IconData icon, required Color iconColor, required String title, required String subtitle, required VoidCallback onTap}) {
    return Material(
      color: AppTheme.surfaceLight,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(color: iconColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                    SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processImageInput({required bool fromCamera}) async {
    try {
      showDialog(context: context, barrierDismissible: false, builder: (_) => Center(child: CircularProgressIndicator()));
      Map<String, dynamic>? extracted = fromCamera ? await _inputProcessor.processImageFromCamera() : await _inputProcessor.processImageFromGallery();
      Navigator.pop(context);
      if (extracted == null) return;
      _showTransactionDialog(prefilled: extracted);
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  Future<void> _processPDFInput() async {
    try {
      showDialog(context: context, barrierDismissible: false, builder: (_) => Center(child: CircularProgressIndicator()));
      Map<String, dynamic>? extracted = await _inputProcessor.processPDF();
      Navigator.pop(context);
      if (extracted == null) return;
      _showTransactionDialog(prefilled: extracted);
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  void _showTextInputDialog() {
    String inputText = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [Icon(Icons.edit_rounded, color: AppTheme.desejo, size: 20), SizedBox(width: 12), Text('Adicionar por Texto', style: TextStyle(color: AppTheme.textPrimary))],
        ),
        content: TextField(
          autofocus: true,
          style: TextStyle(color: AppTheme.textPrimary),
          decoration: InputDecoration(hintText: 'Ex: Restaurante 85 reais', filled: true, fillColor: AppTheme.surfaceLight, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
          maxLines: 3,
          onChanged: (value) => inputText = value,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
          ElevatedButton(
            onPressed: () { if (inputText.trim().isEmpty) return; Navigator.pop(context); Map<String, dynamic> extracted = _inputProcessor.processText(inputText); _showTransactionDialog(prefilled: extracted); },
            child: Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void _showSmartInputDialog() {
    showDialog(
      context: context,
      builder: (context) => SmartInputDialog(
        onTransactionsCreated: (transactions) async {
          for (final transaction in transactions) { await _addTransaction(transaction); }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Transações adicionadas!'), backgroundColor: Colors.green));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalSpent = FinanceCalculator.getTotalSpentAllCategories(_transactions);
    final spentByCategory = FinanceCalculator.getSpentByCategory(_transactions);
    final rendaTotal = _income + _extraIncome + _redeemedBalance;
    final isOverride = _balanceOverride != null;
    final saldoBase = isOverride ? _balanceOverride! : rendaTotal;
    final restante = saldoBase - totalSpent;
    
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.investimento]), borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Gestor-kal', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                Text('Inteligência Orçamentária 50/30/20', style: TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [IconButton(icon: Icon(Icons.notifications_outlined, color: Colors.white70), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            IncomeCard(
              monthlyIncome: _income,
              extraIncome: _extraIncome,
              onEditExtra: _showExtraIncomeDialog,
              onEditSalary: _showSalaryConfigDialog,
              salaryPaymentDay: _salaryConfig?.isActive == true ? _salaryConfig?.paymentDay : null,
            ),
            if (_redeemedBalance > 0)
              RedeemedCard(redeemedBalance: _redeemedBalance),
            SizedBox(height: 16),
            BalanceCard(
              currentBalance: saldoBase,
              totalIncome: rendaTotal,
              totalSpent: totalSpent,
              isOverride: isOverride,
              onEdit: _showTotalIncomeDialog,
            ),
            SizedBox(height: 20),
            SummaryCard(income: rendaTotal, totalSpent: totalSpent, availableBalance: restante),
            SizedBox(height: 28),
            Row(children: [
              Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.pie_chart_rounded, color: AppTheme.primary, size: 20)),
              SizedBox(width: 12),
              Text('Distribuição Orçamentária', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            ]),
            SizedBox(height: 20),
            CategoryProgressCard(category: 'Necessidades', subtitle: '50% do orçamento', spent: spentByCategory['Necessidade'] ?? 0, budget: (_income + _extraIncome) * 0.5, color: AppTheme.necessidade, icon: Icons.home_rounded),
            SizedBox(height: 14),
            CategoryProgressCard(category: 'Desejos & Lazer', subtitle: '30% do orçamento', spent: spentByCategory['Desejos Lazer'] ?? 0, budget: (_income + _extraIncome) * 0.3, color: AppTheme.desejo, icon: Icons.favorite_rounded),
            SizedBox(height: 14),
            CategoryProgressCard(category: 'Investimentos', subtitle: '20% do orçamento', spent: spentByCategory['Investimento'] ?? 0, budget: (_income + _extraIncome) * 0.2, color: AppTheme.investimento, icon: Icons.trending_up_rounded),
            SizedBox(height: 28),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [Icon(Icons.receipt_long_rounded, color: AppTheme.desejo, size: 20), SizedBox(width: 12), Text('Transações do Mês', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary))]),
              Text('${_transactions.length}', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
            ]),
            SizedBox(height: 16),
            if (_transactions.isEmpty)
              Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Column(children: [Icon(Icons.receipt_long_outlined, size: 64, color: AppTheme.textMuted), Text('Nenhuma transação ainda', style: TextStyle(color: AppTheme.textMuted))]))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _transactions.length,
                separatorBuilder: (context, index) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final transaction = _transactions[index];
                  return TransactionTile(
                    transaction: transaction,
                    index: index,
                    onEdit: () => _showTransactionDialog(transaction: transaction, index: index),
                    onDelete: () {
                      showDialog(context: context, builder: (ctx) => AlertDialog(title: Text('Excluir?'), content: Text('Deseja apagar esta transação?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancelar')), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error), onPressed: () { _deleteTransaction(index); Navigator.pop(ctx); }, child: Text('Excluir'))]));
                    },
                  );
                },
              ),
            SizedBox(height: 140),
          ],
        ),
      ),
    );
  }
}