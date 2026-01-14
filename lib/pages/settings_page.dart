import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../services/data_service.dart';
import '../models/app_settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final DataService _dataService = DataService();
  bool _biometricEnabled = false;
  bool _darkMode = true;
  String _currency = 'BRL';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _dataService.init(); // Garante init
    final settings = _dataService.getAppSettings();
    setState(() {
      _biometricEnabled = settings.biometricEnabled;
      _darkMode = settings.themeMode == 2;
      _currency = settings.currency;
    });
  }

  Future<void> _saveSettings() async {
    final settings = AppSettings(
      biometricEnabled: _biometricEnabled,
      themeMode: _darkMode ? 2 : 1,
      currency: _currency,
      budgetRolloverEnabled: true, // Sempre ATIVO
    );
    await _dataService.saveAppSettings(settings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: Colors.grey[900],
      ),
      backgroundColor: Colors.grey[900],
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Seção de Segurança
          _buildSectionTitle('Segurança'),
          _buildSettingTile(
            icon: Icons.fingerprint,
            title: 'Autenticação Biométrica',
            subtitle: 'Bloquear app com digital/FaceID',
            trailing: Switch(
              value: _biometricEnabled,
              onChanged: (value) {
                setState(() => _biometricEnabled = value);
                _saveSettings();
              },
              activeThumbColor: Colors.green,
            ),
          ),

          const SizedBox(height: 24),

          // Seção de Orçamento (Rolagem Removida - Agora Permanente)
          _buildSectionTitle('Orçamento'),
          _buildSettingTile(
            icon: Icons.info_outline,
            title: 'Rolagem Automática',
            subtitle: 'O saldo não gasto é sempre acumulado.',
            // Sem trailing switch pois é fixo
            iconColor: Colors.grey,
          ),

          const SizedBox(height: 24),

          // Seção de Dados (Backup e Limpeza)
          _buildSectionTitle('Backup e Dados'),
          _buildSettingTile(
            icon: Icons.cloud_upload_outlined,
            title: 'Exportar Backup (Manual)',
            subtitle: 'Salvar dados no Drive ou Arquivos',
            trailing: Icon(Icons.chevron_right, color: Colors.blue[400]),
            onTap: () => _exportBackup(),
            iconColor: Colors.blue[400],
          ),
          _buildSettingTile(
            icon: Icons.cloud_download_outlined,
            title: 'Importar Backup',
            subtitle: 'Restaurar de arquivo .json',
            trailing: Icon(Icons.chevron_right, color: Colors.blue[400]),
            onTap: () => _importBackup(),
            iconColor: Colors.blue[400],
          ),
          _buildSettingTile(
            icon: Icons.delete_forever,
            title: 'Limpar Todos os Dados',
            subtitle: 'Apaga transações (Exige senha)',
            trailing: Icon(Icons.chevron_right, color: Colors.red[400]),
            onTap: () => _confirmClearData(),
            iconColor: Colors.red[400],
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('Aparência'),
          // ... (Resto do código de aparência mantido)
          _buildSettingTile(
             icon: Icons.dark_mode,
             title: 'Modo Escuro',
             trailing: Switch(
               value: _darkMode,
               onChanged: (val) { 
                 setState(() => _darkMode = val);
                 _saveSettings();
               }
             )
          ),

          const SizedBox(height: 32),
          _buildCreditsCard(),
        ],
      ),
    );
  }

  // ... (Métodos auxiliares de UI mantidos: _buildSectionTitle, _buildSettingTile, _buildCreditsCard)

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue[400])),
    );
  }

  Widget _buildSettingTile({required IconData icon, required String title, String? subtitle, Widget? trailing, VoidCallback? onTap, Color? iconColor}) {
    return Card(
      color: Colors.grey[850],
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? Colors.grey[400]),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: Colors.grey[400], fontSize: 12)) : null,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
  
  Widget _buildCreditsCard() {
    return Card(
      color: Colors.grey[850],
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Criado Por Pablo de oliveira silva \nKaloferta Gestor v3.1\n© 2026 Todos os direitos reservados Ao seu Namorado Gostosão.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
      ),
    );
  }

  // --- LÓGICA DE BACKUP ---

  Future<void> _exportBackup() async {
    try {
      showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
      
      // 1. Gera JSON
      String jsonContent = await _dataService.createBackupJson();
      
      // 2. Salva arquivo temporário
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/backup_gestor_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonContent);
      
      Navigator.pop(context); // Fecha loading

      // 3. Abre menu de compartilhamento (Drive, WhatsApp, Salvar em Arquivos)
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Backup Gestor Financeiro',
        subject: 'Backup Kaloferta Gestor',
      );
      
    } catch (e) {
      Navigator.pop(context); // Fecha loading
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao exportar: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _importBackup() async {
    try {
      // 1. Escolher arquivo
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
        
        File file = File(result.files.single.path!);
        String content = await file.readAsString();
        
        // 2. Restaurar
        bool success = await _dataService.restoreBackupJson(content);
        
        Navigator.pop(context); // Fecha loading

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dados restaurados com sucesso! Reinicie o app.'), backgroundColor: Colors.green));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Arquivo inválido ou corrompido.'), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao importar: $e'), backgroundColor: Colors.red));
    }
  }

  // --- LIMPAR DADOS COM SENHA ---

  void _confirmClearData() {
    final passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Tudo?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Isso apagará todas as transações, mas manterá suas configurações e backups externos.'),
            const SizedBox(height: 16),
            const Text('Senha Padrão: 1234', style: TextStyle(color: Colors.grey, fontSize: 12)),
            TextField(
              controller: passwordController,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Digite a senha para confirmar',
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
            onPressed: () {
              if (passwordController.text == '1234') {
                Navigator.pop(context);
                _clearAllData();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Senha incorreta!'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('CONFIRMAR'),
          ),
        ],
      ),
    );
  }

  void _clearAllData() async {
    await _dataService.clearAllData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dados limpos com sucesso!'), backgroundColor: Colors.green),
    );
  }
}