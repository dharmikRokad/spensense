import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const _primaryColor = Color(0xFF6C63FF);
  static const _accentColor = Color(0xFF03DAC6);
  static const _errorColor = Color(0xFFCF6679);
  static const _successColor = Color(0xFF4CAF50);

  static const _darkBg = Color(0xFF0D0D1A);
  static const _darkSurface = Color(0xFF1A1A2E);
  static const _darkCard = Color(0xFF16213E);

  static const creditColor = Color(0xFF4ADE80);
  static const debitColor = Color(0xFFF87171);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _darkBg,
      colorScheme: const ColorScheme.dark(
        primary: _primaryColor,
        secondary: _accentColor,
        error: _errorColor,
        surface: _darkSurface,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      cardTheme: CardThemeData(
        color: _darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _darkBg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2A2A4A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.white60),
        hintStyle: const TextStyle(color: Colors.white38),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _darkSurface,
        selectedItemColor: _primaryColor,
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      extensions: const [
        AppColors(
          credit: creditColor,
          debit: debitColor,
          success: _successColor,
          gradient1: _primaryColor,
          gradient2: _accentColor,
          cardBg: _darkCard,
          surfaceBg: _darkSurface,
        ),
      ],
    );
  }

  static ThemeData get lightTheme {
    const lightBg = Color(0xFFF5F5FF);
    const lightSurface = Color(0xFFFFFFFF);
    const lightCard = Color(0xFFF0F0FF);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      colorScheme: const ColorScheme.light(
        primary: _primaryColor,
        secondary: _accentColor,
        error: _errorColor,
        surface: lightSurface,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDDDDFF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
      ),
      extensions: const [
        AppColors(
          credit: creditColor,
          debit: debitColor,
          success: _successColor,
          gradient1: _primaryColor,
          gradient2: _accentColor,
          cardBg: lightCard,
          surfaceBg: lightSurface,
        ),
      ],
    );
  }
}

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color credit;
  final Color debit;
  final Color success;
  final Color gradient1;
  final Color gradient2;
  final Color cardBg;
  final Color surfaceBg;

  const AppColors({
    required this.credit,
    required this.debit,
    required this.success,
    required this.gradient1,
    required this.gradient2,
    required this.cardBg,
    required this.surfaceBg,
  });

  @override
  AppColors copyWith({
    Color? credit,
    Color? debit,
    Color? success,
    Color? gradient1,
    Color? gradient2,
    Color? cardBg,
    Color? surfaceBg,
  }) {
    return AppColors(
      credit: credit ?? this.credit,
      debit: debit ?? this.debit,
      success: success ?? this.success,
      gradient1: gradient1 ?? this.gradient1,
      gradient2: gradient2 ?? this.gradient2,
      cardBg: cardBg ?? this.cardBg,
      surfaceBg: surfaceBg ?? this.surfaceBg,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      credit: Color.lerp(credit, other.credit, t)!,
      debit: Color.lerp(debit, other.debit, t)!,
      success: Color.lerp(success, other.success, t)!,
      gradient1: Color.lerp(gradient1, other.gradient1, t)!,
      gradient2: Color.lerp(gradient2, other.gradient2, t)!,
      cardBg: Color.lerp(cardBg, other.cardBg, t)!,
      surfaceBg: Color.lerp(surfaceBg, other.surfaceBg, t)!,
    );
  }
}
