import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';

// Imports das páginas
import 'package:kaloferta_gestor/pages/dashboard_page.dart';
import 'package:kaloferta_gestor/pages/settings_page.dart';
import 'package:kaloferta_gestor/pages/reports_page.dart';
import 'package:kaloferta_gestor/pages/investments_page.dart';
import 'package:kaloferta_gestor/pages/savings_page.dart';
import 'package:kaloferta_gestor/pages/recurring_expenses_page.dart';
import 'package:kaloferta_gestor/pages/achievements_page.dart';

// Imports dos modelos
import 'package:kaloferta_gestor/models/transaction_model.dart';
import 'package:kaloferta_gestor/models/app_settings.dart';
import 'package:kaloferta_gestor/models/salary_config.dart';
import 'package:kaloferta_gestor/models/investment.dart';
import 'package:kaloferta_gestor/models/recurring_expense.dart';
import 'package:kaloferta_gestor/models/savings_fund.dart';
import 'package:kaloferta_gestor/models/achievement.dart';

import 'package:kaloferta_gestor/theme/app_theme.dart';
import 'package:kaloferta_gestor/services/action_bus.dart';
import 'package:kaloferta_gestor/services/biometric_service.dart';
import 'package:kaloferta_gestor/services/data_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  // Registro de Adaptadores
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(TransactionAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(UserDataAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(RecurringExpenseAdapter());
  if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(SavingsFundAdapter());
  if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(AchievementAdapter());
  if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(AppSettingsAdapter());
  if (!Hive.isAdapterRegistered(7)) Hive.registerAdapter(SalaryConfigAdapter());
  if (!Hive.isAdapterRegistered(10)) Hive.registerAdapter(InvestmentAdapter());
  if (!Hive.isAdapterRegistered(11)) Hive.registerAdapter(InterestTypeAdapter());
  if (!Hive.isAdapterRegistered(12)) Hive.registerAdapter(YieldRecordAdapter());
  
  // Inicializa serviço de dados
  final dataService = DataService();
  await dataService.init();
  
  runApp(const FinanceApp());
}

class FinanceApp extends StatefulWidget {
  const FinanceApp({super.key});

  @override
  State<FinanceApp> createState() => _FinanceAppState();
}

class _FinanceAppState extends State<FinanceApp> {
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final settingsBox = Hive.box<AppSettings>(DataService.appSettingsBoxName);
    final settings = settingsBox.isNotEmpty 
        ? settingsBox.getAt(0) 
        : AppSettings(biometricEnabled: false);
    
    // Se a biometria estiver ativada nas configurações, pede autenticação
    if (settings?.biometricEnabled == true) {
      _authenticate();
    } else {
      // Se não, entra direto
      setState(() => _isAuthenticated = true);
    }
  }

  Future<void> _authenticate() async {
    final auth = BiometricService();
    bool authenticated = await auth.authenticate(
      reason: 'Desbloqueie para acessar seus dados financeiros'
    );
    
    if (authenticated) {
      setState(() => _isAuthenticated = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Se não estiver autenticado, mostra tela de bloqueio
    if (!_isAuthenticated) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: Scaffold(
          backgroundColor: AppTheme.scaffoldBackground,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 64, color: AppTheme.primary),
                const SizedBox(height: 16),
                const Text('Aplicativo Bloqueado', style: TextStyle(fontSize: 20, color: Colors.white)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _authenticate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text('Desbloquear'),
                )
              ],
            ),
          ),
        ),
      );
    }

    // Se autenticado, mostra o app normal
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestor-kal',
      theme: AppTheme.darkTheme, 
      home: const MainNavigationPage(),
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    DashboardPage(),
    ReportsPage(),
    InvestmentsPage(),
    SavingsPage(),
    RecurringExpensesPage(),
    AchievementsPage(),
  ];

  Color _getTabColor() {
    switch (_currentIndex) {
      case 1: return Colors.orangeAccent;
      case 2: return Colors.greenAccent;
      case 3: return Colors.pinkAccent;
      default: return AppTheme.primaryBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    const double safePaddingBottom = 110.0; 

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      extendBody: true, 
      body: Stack(
        children: [
          // 1. Imagem de Fundo
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                "assets/images/fundo.jpeg",
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(color: Colors.black),
              ),
            ),
          ),
          
          // 2. Conteúdo das Páginas
          Padding(
            padding: const EdgeInsets.only(bottom: safePaddingBottom),
            child: Theme(
              data: Theme.of(context).copyWith(
                scaffoldBackgroundColor: Colors.transparent,
              ),
              child: IndexedStack(
                index: _currentIndex,
                children: _pages,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildIntegratedNavBar(),
    );
  }

  Widget _buildIntegratedNavBar() {
    final activeColor = _getTabColor();
    // Atualizado para usar withValues se sua versão do Flutter for muito recente, 
    // mas mantive withOpacity por compatibilidade com versões estáveis comuns.
    return Container(
      height: 85, 
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 25),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground.withOpacity(0.92),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: activeColor.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(0, Icons.dashboard_rounded, "Home", activeColor),
          _navItem(1, Icons.analytics_rounded, "Relat.", activeColor),
          _navItem(2, Icons.trending_up_rounded, "Invest.", activeColor),
          const VerticalDivider(color: Colors.white10, indent: 20, endIndent: 20, width: 1),
          _actionButton(
            icon: Icons.auto_awesome,
            color: AppTheme.primary,
            label: "IA",
            onTap: () => ActionBus.emit(AppAction.showSmartInput),
          ),
          _actionButton(
            icon: Icons.add,
            color: AppTheme.desejo,
            label: "Incluir",
            onTap: () => ActionBus.emit(AppAction.showAddOptions),
          ),
          const VerticalDivider(color: Colors.white10, indent: 20, endIndent: 20, width: 1),
          _navItem(3, Icons.savings_rounded, "Poup.", activeColor),
          _navItem(5, Icons.emoji_events_rounded, "Conq.", activeColor),
          _configButton(),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label, Color activeColor) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 42,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? activeColor : AppTheme.textMuted, size: isSelected ? 24 : 20),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: isSelected ? activeColor : AppTheme.textMuted, fontSize: 8)),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({required IconData icon, required Color color, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: color, fontSize: 7, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _configButton() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsPage())),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 42,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings_outlined, color: AppTheme.textMuted, size: 20),
            const SizedBox(height: 4),
            Text("Config", style: TextStyle(color: AppTheme.textMuted, fontSize: 8)),
          ],
        ),
      ),
    );
  }
}