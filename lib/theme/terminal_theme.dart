import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TerminalTheme {

  // ── COLORES ──────────────────────────────────
  static const Color bgColor      = Color(0xFF020C02); // Negro
  static const Color primaryGreen = Color(0xFF00FF41); // Verde fósforo
  static const Color dimGreen     = Color(0xFF00A82D); // Verde atenuado
  static const Color amber        = Color(0xFFFFB000); // Ámbar (advertencia)
  static const Color red          = Color(0xFFFF003C); // Rojo (peligro)
  static const Color cyan         = Color(0xFF00FFFF); // Cian (completado)

  // ── TEMA GENERAL DE LA APP ───────────────────
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgColor,
    primaryColor: primaryGreen,
    colorScheme: const ColorScheme.dark(
      primary: primaryGreen,
      secondary: amber,
      surface: Color(0xFF0A150A),
      error: red,
    ),
    textTheme: GoogleFonts.robotoMonoTextTheme().apply(
      bodyColor: primaryGreen,
      displayColor: primaryGreen,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: bgColor,
      elevation: 0,
      titleTextStyle: GoogleFonts.robotoMono(
        color: primaryGreen,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    ),
  );

  // ── ESTILOS DE TEXTO ─────────────────────────
  static TextStyle get terminalText => GoogleFonts.robotoMono(
    color: primaryGreen,
    fontSize: 14,
  );

  static TextStyle get terminalTitle => GoogleFonts.robotoMono(
    color: primaryGreen,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    letterSpacing: 3,
  );

  static TextStyle get terminalSmall => GoogleFonts.robotoMono(
    color: dimGreen,
    fontSize: 11,
    letterSpacing: 1,
  );

  static TextStyle get warningText => GoogleFonts.robotoMono(
    color: amber,
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get dangerText => GoogleFonts.robotoMono(
    color: red,
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );
}