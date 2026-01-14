import 'package:flutter/material.dart';

// Use o nome que está no seu pubspec.yaml (provavelmente kaloferta_gestor)
import 'package:kaloferta_gestor/pages/dashboard_page.dart';
import 'package:kaloferta_gestor/pages/savings_page.dart';
import 'package:kaloferta_gestor/pages/recurring_expenses_page.dart';
import 'package:kaloferta_gestor/pages/achievements_page.dart';
import 'package:kaloferta_gestor/pages/settings_page.dart';
import 'package:kaloferta_gestor/pages/reports_page.dart';
import 'package:kaloferta_gestor/pages/investments_page.dart';

import 'package:kaloferta_gestor/theme/app_theme.dart';
import 'package:kaloferta_gestor/services/action_bus.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  // Lista de todas as suas páginas
  final List<Widget> _pages = [
    DashboardPage(),           // 0
    ReportsPage(),             // 1
    InvestmentsPage(),         // 2
    SavingsPage(),             // 3
    RecurringExpensesPage(),   // 4
    AchievementsPage(),        // 5
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      extendBody: true, // Permite que o fundo apareça atrás da barra
      body: Stack(
        children: [
          // 1. IMAGEM DE FUNDO DO TEMA (Wallpaper interno)
          Positioned.fill(
            child: Opacity(
              opacity: 0.12, // Ajuste entre 0.05 e 0.20 para não cansar a vista
              child: Image.asset(
                "assets/images/fundo.jpeg",
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. CONTEÚDO DAS PÁGINAS
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
        ],
      ),
      bottomNavigationBar: _buildIntegratedNavBar(),
    );
  }

  Widget _buildIntegratedNavBar() {
    return Container(
      height: 85, // Altura fixa: Resolve o erro da tela preta
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 20),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground.withOpacity(0.95),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Lado Esquerdo
          _navItem(0, Icons.dashboard_rounded, "Home"),
          _navItem(1, Icons.analytics_rounded, "Relat."),
          _navItem(2, Icons.trending_up_rounded, "Invest."),

          // BOTÕES DE AÇÃO CENTRAIS (Fixos no painel)
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

          // Lado Direito
          _navItem(3, Icons.savings_rounded, "Poup."),
          _navItem(5, Icons.emoji_events_rounded, "Conq."),
          
          // Botão de Configurações
          _configButton(),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 45,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryBlue : AppTheme.textMuted,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryBlue : AppTheme.textMuted,
                fontSize: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon, 
    required Color color, 
    required String label, 
    required VoidCallback onTap
  }) {
    return GestureDetector(
      onTap: () {
        // Opcional: Volta para a home ao clicar em uma ação
        if (_currentIndex != 0) setState(() => _currentIndex = 0);
        onTap();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 2),
          Text(
            label, 
            style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold)
          ),
        ],
      ),
    );
  }

  Widget _configButton() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context, 
        MaterialPageRoute(builder: (_) => SettingsPage())
      ),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 45,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings_outlined, color: AppTheme.textMuted, size: 22),
            SizedBox(height: 4),
            Text(
              "Config", 
              style: TextStyle(color: AppTheme.textMuted, fontSize: 8)
            ),
          ],
        ),
      ),
    );
  }
}