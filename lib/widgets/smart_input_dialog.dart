import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/smart_input_parser.dart';
import '../models/transaction_model.dart';
import '../theme/app_theme.dart';

/// Dialog para entrada inteligente de gastos via texto natural
class SmartInputDialog extends StatefulWidget {
  final Function(List<Transaction>) onTransactionsCreated;

  const SmartInputDialog({
    super.key,
    required this.onTransactionsCreated,
  });

  @override
  State<SmartInputDialog> createState() => _SmartInputDialogState();
}

class _SmartInputDialogState extends State<SmartInputDialog> {
  final TextEditingController _controller = TextEditingController();
  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final dateFormat = DateFormat('dd/MM/yyyy');
  
  SmartParseResult? _parseResult;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_controller.text.length >= 3) {
      setState(() {
        _parseResult = SmartInputParser.parse(_controller.text);
      });
    } else {
      setState(() => _parseResult = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primary.withOpacity(0.2), AppTheme.investimento.withOpacity(0.2)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.auto_awesome, color: AppTheme.primary, size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Entrada Inteligente',
                          style: TextStyle(
                            fontSize: 20, 
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          )),
                      Text('Digite como você falaria',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Input field
            TextField(
              controller: _controller,
              autofocus: true,
              maxLines: 3,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Ex: "Ontem gastei 300 reais no mercado e parcelei em 3x"',
                hintStyle: TextStyle(color: AppTheme.textMuted.withOpacity(0.6), fontSize: 14),
                filled: true,
                fillColor: AppTheme.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 16, right: 8),
                  child: Icon(Icons.mic_rounded, color: AppTheme.textMuted, size: 22),
                ),
              ),
            ),

            // Examples
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildExampleChip('Ontem gastei 50 no uber'),
                _buildExampleChip('Mercado 200 reais dia 10'),
                _buildExampleChip('Netflix 39.90 todo mês'),
                _buildExampleChip('Celular 1200 em 12x'),
              ],
            ),

            // Parse preview
            if (_parseResult != null && _parseResult!.isValid) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.investimento.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.investimento.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: AppTheme.investimento, size: 20),
                        SizedBox(width: 8),
                        Text('Dados identificados:',
                            style: TextStyle(fontWeight: FontWeight.w600, 
                                color: AppTheme.investimento)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildResultRow(Icons.description_outlined, 'Descrição', 
                        _parseResult!.description),
                    _buildResultRow(Icons.attach_money_rounded, 'Valor', 
                        currencyFormat.format(_parseResult!.amount)),
                    _buildResultRow(Icons.calendar_today_rounded, 'Data', 
                        dateFormat.format(_parseResult!.date)),
                    _buildResultRow(Icons.category_rounded, 'Categoria', 
                        _parseResult!.category),
                    
                    if (_parseResult!.hasInstallments) ...[
                      const Divider(color: AppTheme.cardBorder, height: 24),
                      _buildResultRow(Icons.credit_card_rounded, 'Parcelas', 
                          '${_parseResult!.totalInstallments}x de ${currencyFormat.format(_parseResult!.installmentAmount)}'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.desejo.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Serão criadas ${_parseResult!.totalInstallments} transações',
                          style: const TextStyle(fontSize: 11, color: AppTheme.desejo, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                    
                    if (_parseResult!.isFixed) ...[
                      const Divider(color: AppTheme.cardBorder, height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.repeat_rounded, size: 14, color: AppTheme.primary),
                            SizedBox(width: 6),
                            Text('Conta fixa (repetirá mensalmente)',
                                style: TextStyle(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            if (_parseResult != null && !_parseResult!.isValid) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.warning.withOpacity(0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_rounded, color: AppTheme.warning, size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Não consegui identificar o valor. Tente incluir "R\$" ou "reais".',
                        style: TextStyle(color: AppTheme.warning, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: AppTheme.textMuted)),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _parseResult?.isValid == true && !_isProcessing
                      ? _confirmTransaction
                      : null,
                  icon: _isProcessing 
                      ? const SizedBox(
                          width: 18, 
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded, size: 20),
                  label: Text(_parseResult?.hasInstallments == true 
                      ? 'Criar Parcelas' 
                      : 'Adicionar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.investimento,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppTheme.surfaceLight,
                    disabledForegroundColor: AppTheme.textMuted,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleChip(String text) {
    return GestureDetector(
      onTap: () {
        _controller.text = text;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
        ),
      ),
    );
  }

  Widget _buildResultRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textMuted),
          const SizedBox(width: 10),
          Text('$label: ', style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
          Expanded(
            child: Text(value, 
                style: const TextStyle(
                  fontWeight: FontWeight.w600, 
                  fontSize: 13,
                  color: AppTheme.textPrimary,
                )),
          ),
        ],
      ),
    );
  }

  void _confirmTransaction() async {
    if (_parseResult == null || !_parseResult!.isValid) return;

    setState(() => _isProcessing = true);

    try {
      final transactions = SmartInputParser.createTransactions(_parseResult!);
      widget.onTransactionsCreated(transactions);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao criar transação: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}

/// Botão flutuante para entrada inteligente
class SmartInputButton extends StatelessWidget {
  final Function(List<Transaction>) onTransactionsCreated;

  const SmartInputButton({
    super.key,
    required this.onTransactionsCreated,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: 'smart_input',
      onPressed: () => _showSmartInput(context),
      icon: const Icon(Icons.auto_awesome),
      label: const Text('Entrada Rápida'),
      backgroundColor: AppTheme.primary,
    );
  }

  void _showSmartInput(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SmartInputDialog(
        onTransactionsCreated: onTransactionsCreated,
      ),
    );
  }
}
