import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Color Palette from Design Guide
  static const Color bg = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surface2 = Color(0xFFF0F2F5);
  static const Color border = Color(0xFFE4E7ED);
  static const Color accent = Color(0xFF1DB954);
  static const Color accentSoft = Color(0xFFE8F8EE);
  static const Color red = Color(0xFFEF4444);
  static const Color redSoft = Color(0xFFFEF2F2);
  static const Color blue = Color(0xFF3B82F6);
  static const Color blueSoft = Color(0xFFEFF6FF);
  static const Color amber = Color(0xFFF59E0B);
  static const Color amberSoft = Color(0xFFFFFBEB);
  static const Color textBody = Color(0xFF111827);
  static const Color textSub = Color(0xFF6B7280);
  static const Color textDim = Color(0xFF9CA3AF);

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme)
        .copyWith(
          displayLarge: GoogleFonts.plusJakartaSans(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: textBody,
            letterSpacing: -0.5,
          ),
          headlineMedium: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textBody,
          ),
          titleMedium: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textBody,
          ),
          bodyLarge: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textBody,
          ),
          bodyMedium: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: textBody,
          ),
          labelMedium: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: textSub,
          ),
        );

    return base.copyWith(
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.light(
        primary: accent,
        secondary: blue,
        surface: surface,
        error: red,
        onSurface: textBody,
        onPrimary: Colors.white,
      ),
      textTheme: textTheme,
      dividerTheme: const DividerThemeData(
        color: border,
        space: 1,
        thickness: 1,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: border),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.headlineMedium,
        iconTheme: const IconThemeData(color: textBody),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.titleMedium,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        labelStyle: textTheme.labelMedium,
        hintStyle: textTheme.bodyLarge?.copyWith(color: textDim),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        elevation: 0,
        selectedItemColor: accent,
        unselectedItemColor: textDim,
        selectedLabelStyle: textTheme.labelMedium?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: accent,
        ),
        unselectedLabelStyle: textTheme.labelMedium?.copyWith(fontSize: 10),
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 2,
        sizeConstraints: BoxConstraints.tightFor(width: 52, height: 52),
        shape: CircleBorder(),
      ),
      extensions: const [
        AppColors(
          bg: bg,
          surface: surface,
          surface2: surface2,
          border: border,
          accent: accent,
          accentSoft: accentSoft,
          red: red,
          redSoft: redSoft,
          blue: blue,
          blueSoft: blueSoft,
          amber: amber,
          amberSoft: amberSoft,
          text: textBody,
          textSub: textSub,
          textDim: textDim,
        ),
      ],
    );
  }

  // Dark theme as secondary
  static ThemeData get darkTheme =>
      lightTheme.copyWith(brightness: Brightness.dark);
}

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color bg;
  final Color surface;
  final Color surface2;
  final Color border;
  final Color accent;
  final Color accentSoft;
  final Color red;
  final Color redSoft;
  final Color blue;
  final Color blueSoft;
  final Color amber;
  final Color amberSoft;
  final Color text;
  final Color textSub;
  final Color textDim;

  const AppColors({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.border,
    required this.accent,
    required this.accentSoft,
    required this.red,
    required this.redSoft,
    required this.blue,
    required this.blueSoft,
    required this.amber,
    required this.amberSoft,
    required this.text,
    required this.textSub,
    required this.textDim,
  });

  @override
  AppColors copyWith({
    Color? bg,
    Color? surface,
    Color? surface2,
    Color? border,
    Color? accent,
    Color? accentSoft,
    Color? red,
    Color? redSoft,
    Color? blue,
    Color? blueSoft,
    Color? amber,
    Color? amberSoft,
    Color? text,
    Color? textSub,
    Color? textDim,
  }) {
    return AppColors(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surface2: surface2 ?? this.surface2,
      border: border ?? this.border,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      red: red ?? this.red,
      redSoft: redSoft ?? this.redSoft,
      blue: blue ?? this.blue,
      blueSoft: blueSoft ?? this.blueSoft,
      amber: amber ?? this.amber,
      amberSoft: amberSoft ?? this.amberSoft,
      text: text ?? this.text,
      textSub: textSub ?? this.textSub,
      textDim: textDim ?? this.textDim,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      border: Color.lerp(border, other.border, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      red: Color.lerp(red, other.red, t)!,
      redSoft: Color.lerp(redSoft, other.redSoft, t)!,
      blue: Color.lerp(blue, other.blue, t)!,
      blueSoft: Color.lerp(blueSoft, other.blueSoft, t)!,
      amber: Color.lerp(amber, other.amber, t)!,
      amberSoft: Color.lerp(amberSoft, other.amberSoft, t)!,
      text: Color.lerp(text, other.text, t)!,
      textSub: Color.lerp(textSub, other.textSub, t)!,
      textDim: Color.lerp(textDim, other.textDim, t)!,
    );
  }
}
