import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TementColors {
  // 🟣 Couleurs principales
  static const Color indigoTech = Color(0xFF2B245A); // Logo, titres, navbar
  static const Color deepPurple = Color(0xFF3C2F7A); // Fonds premium, hover
  static const Color sunsetOrange =
      Color(0xFFE36A3D); // CTA, actions importantes
  static const Color softGold = Color(0xFFF4A261); // Badges premium, highlights

  // ⚪ Couleurs neutres
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightBackground = Color(0xFFF4F6FA);
  static const Color darkBackground = Color(0xFF14122B);
  static const Color greySecondary = Color(0xFF6B6B8D);
}

class TementTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: TementColors.indigoTech,
    scaffoldBackgroundColor: TementColors.lightBackground,
    colorScheme: const ColorScheme.light(
      primary: TementColors.indigoTech,
      secondary: TementColors.sunsetOrange,
      tertiary: TementColors.softGold,
      surface: TementColors.white,
      error: Colors.red,
    ),

    // ✅ POLICE INTER POUR TOUTE L'APPLICATION
    fontFamily: GoogleFonts.inter().fontFamily,

    // ✅ APPBAR THEME
    appBarTheme: AppBarTheme(
      backgroundColor: TementColors.indigoTech,
      foregroundColor: TementColors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    // ✅ BOUTONS
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: TementColors.sunsetOrange,
        foregroundColor: TementColors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: TementColors.indigoTech,
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // ✅ INPUTS
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: TementColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: TementColors.indigoTech, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      contentPadding: const EdgeInsets.all(16),
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        color: TementColors.greySecondary,
      ),
      hintStyle: GoogleFonts.inter(
        fontSize: 14,
        color: TementColors.greySecondary.withOpacity(0.6),
      ),
    ),

    // ✅ CARTES
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: TementColors.white,
    ),

    // ✅ TEXT THEME COMPLET
    textTheme: TextTheme(
      // Très grands titres (rare)
      displayLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: TementColors.indigoTech,
      ),

      // Titres principaux (ex: "Bienvenue")
      headlineLarge: GoogleFonts.inter(
        color: TementColors.indigoTech,
        fontWeight: FontWeight.bold,
        fontSize: 28,
      ),

      // Sous-titres principaux
      headlineMedium: GoogleFonts.inter(
        color: TementColors.indigoTech,
        fontWeight: FontWeight.w600,
        fontSize: 24,
      ),

      // Titres de sections
      titleLarge: GoogleFonts.inter(
        color: TementColors.darkBackground,
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),

      // Sous-titres de sections
      titleMedium: GoogleFonts.inter(
        color: TementColors.darkBackground,
        fontWeight: FontWeight.w500,
        fontSize: 18,
      ),

      // Corps de texte principal
      bodyLarge: GoogleFonts.inter(
        color: TementColors.darkBackground,
        fontSize: 16,
        height: 1.5,
      ),

      // Texte secondaire
      bodyMedium: GoogleFonts.inter(
        color: TementColors.greySecondary,
        fontSize: 14,
        height: 1.4,
      ),

      // Petits textes
      bodySmall: GoogleFonts.inter(
        color: TementColors.greySecondary,
        fontSize: 12,
        height: 1.3,
      ),

      // Boutons et labels
      labelLarge: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),

      // Petits labels
      labelSmall: GoogleFonts.inter(
        fontSize: 12,
        color: TementColors.greySecondary,
      ),
    ),
  );
}
