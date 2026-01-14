import 'package:flutter/material.dart';
import 'dart:ui';

/// Tema Premium Dark Mode para Gestor 50/30/20
class AppTheme {
  // Cores de fundo Premium (Grafite e Cinza escuro em vez de preto puro)
  static const Color scaffoldBackground = Color(0xFF121212);
  static const Color cardBackground = Color(0xFF1E1E1E);
  static const Color cardBackgroundLight = Color(0xFF252525);
  static const Color surfaceColor = Color(0xFF1A1A1A);
  static const Color surfaceLight = Color(0xFF2A2A2A);
  
  // Cores de Categoria (Pastéis Vibrantes)
  static const Color necessidadeColor = Color(0xFF64B5F6); // Azul Neon Soft
  static const Color desejoColor = Color(0xFFFFB74D);      // Laranja/Âmbar suave
  static const Color investimentoColor = Color(0xFF4DB6AC); // Verde Esmeralda Moderno
  
  // Aliases para acesso mais curto
  static const Color necessidade = necessidadeColor;
  static const Color desejo = desejoColor;
  static const Color investimento = investimentoColor;
  
  // Cores de Destaque
  static const Color primaryBlue = Color(0xFF5C9CE6);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFEF5350);
  
  // Aliases
  static const Color primary = primaryBlue;
  static const Color success = successGreen;
  static const Color warning = warningOrange;
  static const Color error = errorRed;
  
  // Cores de Texto
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF757575);
  
  // Bordas e Efeitos
  static const Color cardBorder = Color(0xFF2D2D2D);
  static const double cardRadius = 20.0;
  static const double buttonRadius = 16.0;
  static const double inputRadius = 12.0;

  /// Tema principal do app
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: scaffoldBackground,
    
    // Esquema de cores
    colorScheme: const ColorScheme.dark(
      primary: primaryBlue,
      secondary: necessidadeColor,
      surface: cardBackground,
      error: errorRed,
    ),
    
    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: scaffoldBackground,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.5,
      ),
      iconTheme: IconThemeData(color: textPrimary),
    ),
    
    // Cards
    cardTheme: CardThemeData(
      color: cardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      margin: EdgeInsets.zero,
    ),
    
    // Texto
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimary,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        color: textPrimary,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        color: textSecondary,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        color: textMuted,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Inter',
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: textMuted,
        letterSpacing: 0.5,
      ),
    ),
    
    // Inputs
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardBackgroundLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputRadius),
        borderSide: const BorderSide(color: Colors.white10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputRadius),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: textMuted),
      labelStyle: const TextStyle(color: textSecondary),
    ),
    
    // Botões
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryBlue,
        side: BorderSide(color: primaryBlue.withOpacity(0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
      ),
    ),
    
    // FAB
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // Divider
    dividerTheme: const DividerThemeData(
      color: Colors.white10,
      thickness: 1,
    ),
    
    // Dialogs
    dialogTheme: DialogThemeData(
      backgroundColor: cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
      ),
    ),
    
    // Bottom Sheet
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(cardRadius)),
      ),
    ),
    
    // Snackbar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: cardBackgroundLight,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  /// Retorna a cor da categoria
  static Color getCategoryColor(String category) {
    switch (category) {
      case 'Necessidade':
        return necessidadeColor;
      case 'Desejos Lazer':
        return desejoColor;
      case 'Investimento':
        return investimentoColor;
      default:
        return textMuted;
    }
  }

  /// Retorna o ícone da categoria
  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Necessidade':
        return Icons.home_rounded;
      case 'Desejos Lazer':
        return Icons.shopping_bag_rounded;
      case 'Investimento':
        return Icons.trending_up_rounded;
      default:
        return Icons.attach_money_rounded;
    }
  }

  /// Decoração de gradiente para cards especiais
  static BoxDecoration get premiumCardDecoration => BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        cardBackgroundLight,
        cardBackground,
      ],
    ),
    borderRadius: BorderRadius.circular(cardRadius),
    boxShadow: const [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
  );

  /// Decoração glassmorphism
  static BoxDecoration glassDecoration({Color? tint}) => BoxDecoration(
    color: (tint ?? Colors.white).withOpacity(0.05),
    borderRadius: BorderRadius.circular(cardRadius),
    border: Border.all(
      color: Colors.white.withOpacity(0.1),
      width: 1,
    ),
    boxShadow: const [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 20,
        offset: Offset(0, 8),
      ),
    ],
  );
}

/// Widget para efeito de blur/glassmorphism
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color? tint;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 10,
    this.tint,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.cardRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: AppTheme.glassDecoration(tint: tint),
          child: child,
        ),
      ),
    );
  }
}

/// Animação de shimmer para loading
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  
  const ShimmerEffect({super.key, required this.child});

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.white.withOpacity(0.0),
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.0),
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((s) => s.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Widget de fundo profissional com gradiente simples
class ProfessionalBackground extends StatelessWidget {
  final Widget child;

  const ProfessionalBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D0D0D),
            Color(0xFF1A1A2E),
            Color(0xFF16213E),
            Color(0xFF0F0F1A),
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: child,
    );
  }
}

