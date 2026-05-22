import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Representa una facción del Protocolo ShadowNet.
class Faction {
  final String name;
  final String description;
  final String symbol;
  final String motto;

  final Color primaryColor;
  final Color backgroundColor;
  final Color accentColor;
  final Color appBarColor;

  /// Ruta de la imagen/logo central de la facción (Punto 2)
  final String logoAsset;

  const Faction({
    required this.name,
    required this.description,
    required this.symbol,
    required this.motto,
    required this.primaryColor,
    required this.backgroundColor,
    required this.accentColor,
    required this.appBarColor,
    required this.logoAsset,
  });

  // ── TIPOGRAFÍA M3 - Terminal de Alta Tecnología (Punto 4) ──────────────────────
  TextStyle textStyle({
    double size = 14,
    bool bold = false,
    Color? color,
    FontStyle? fontStyle,
  }) {
    final c = color ?? primaryColor;
    final w = bold ? FontWeight.w600 : FontWeight.normal;

    switch (name) {
      case 'ENFORCER':
        // Fuente futurista para facción militar
        return GoogleFonts.orbitron(
          fontSize: size,
          fontWeight: w,
          color: c,
          fontStyle: fontStyle,
        );

      case 'GHOST':
        // JetBrains Mono - Ideal para terminal/sigilo
        return GoogleFonts.jetBrainsMono(
          fontSize: size,
          fontWeight: w,
          color: c,
          fontStyle: fontStyle,
        );

      case 'HACKER':
      default:
        // JetBrains Mono - Estética clásica de hacker/terminal
        return GoogleFonts.jetBrainsMono(
          fontSize: size,
          fontWeight: w,
          color: c,
          fontStyle: fontStyle,
        );
    }
  }

  /// Retorna el ThemeData completo para esta facción.
  ThemeData get theme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: backgroundColor,
        primaryColor: primaryColor,
        fontFamily: 'JetBrainsMono',           // ← Tipografía global
        colorScheme: ColorScheme.dark(
          primary: primaryColor,
          secondary: accentColor,
          surface: backgroundColor,
          background: backgroundColor,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: appBarColor,
          elevation: 0,
          iconTheme: IconThemeData(color: primaryColor),
          titleTextStyle: textStyle(size: 16, bold: true),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'JetBrainsMono'),
          bodyLarge: TextStyle(fontFamily: 'JetBrainsMono'),
          titleMedium: TextStyle(fontFamily: 'JetBrainsMono'),
        ),
      );
}

// ═══════════════════════════════════════════════════
//  LAS 3 FACCIONES DE SHADOWNET (Actualizadas)
// ═══════════════════════════════════════════════════

final List<Faction> shadowNetFactions = [
  // ── HACKER ────────────────────────
  Faction(
    name: 'HACKER',
    description: 'Maestros del código y la infiltración digital',
    symbol: '⌨',
    motto: 'El conocimiento es el arma más peligrosa',
    primaryColor: const Color(0xFF00FF41),
    backgroundColor: const Color(0xFF020C02),
    accentColor: const Color(0xFF00FFFF),
    appBarColor: const Color(0xFF010801),
    logoAsset: 'assets/images/factions/hacker.jpg',
  ),

  // ── ENFORCER ──────────────────────
  Faction(
    name: 'ENFORCER',
    description: 'Operadores de campo y combate táctico',
    symbol: '⚡',
    motto: 'La fuerza protege lo que el código no puede',
    primaryColor: const Color(0xFFFF6B00),
    backgroundColor: const Color(0xFF0D0500),
    accentColor: const Color(0xFFFFB000),
    appBarColor: const Color(0xFF080200),
    logoAsset: 'assets/images/factions/enforcer.jpg',
  ),

  // ── GHOST ─────────────────────────
  Faction(
    name: 'GHOST',
    description: 'Espías invisibles y maestros del sigilo',
    symbol: '👁',
    motto: 'Lo que no se ve, no se puede detener',
    primaryColor: const Color(0xFF9B59B6),
    backgroundColor: const Color(0xFF05000D),
    accentColor: const Color(0xFFE0AAFF),
    appBarColor: const Color(0xFF030008),
    logoAsset: 'assets/images/factions/ghost.jpg',
  ),
];

// Facción por defecto
final Faction defaultFaction = shadowNetFactions[0];
