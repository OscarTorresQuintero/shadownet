import 'package:flutter/material.dart';
import '../models/faction_model.dart';

// ═══════════════════════════════════════════════════
//  PROVIDER DE FACCIÓN — OPERACIÓN CAMALEÓN
//  Maneja el estado global de la facción activa.
//  Cualquier widget de la app puede escucharlo
//  y se reconstruye automáticamente al cambiar.
// ═══════════════════════════════════════════════════

/// Provider que controla la facción activa en toda la app.
///
/// Extiende [ChangeNotifier] para notificar a todos los
/// widgets suscritos cuando el operador cambia de facción.
///
/// Uso:
/// ```dart
/// // Leer la facción activa
/// final faction = context.watch<FactionProvider>().currentFaction;
///
/// // Cambiar la facción
/// context.read<FactionProvider>().setFaction(shadowNetFactions[1]);
/// ```
class FactionProvider extends ChangeNotifier {

  /// Facción actualmente seleccionada por el operador.
  Faction _currentFaction = defaultFaction;

  /// Nombre del operador ingresado en el perfil.
  String _agentName = 'OPERADOR DESCONOCIDO';

  /// Nivel del operador basado en misiones completadas.
  int _agentLevel = 1;

  /// Número de misiones completadas por el operador.
  int _missionsCompleted = 0;

  // ── Getters ───────────────────────────────────

  /// Retorna la facción activa actual.
  Faction get currentFaction => _currentFaction;

  /// Retorna el nombre del agente.
  String get agentName => _agentName;

  /// Retorna el nivel del agente.
  int get agentLevel => _agentLevel;

  /// Retorna las misiones completadas.
  int get missionsCompleted => _missionsCompleted;

  /// Retorna el color primario de la facción activa.
  ///
  /// Atajo para no escribir provider.currentFaction.primaryColor
  Color get primaryColor => _currentFaction.primaryColor;

  /// Retorna el color de fondo de la facción activa.
  Color get backgroundColor => _currentFaction.backgroundColor;

  /// Retorna el color de acento de la facción activa.
  Color get accentColor => _currentFaction.accentColor;

  /// Retorna el ThemeData completo de la facción activa.
  ThemeData get currentTheme => _currentFaction.theme;

  // ── Métodos ───────────────────────────────────

  /// Cambia la facción activa y notifica a toda la app.
  ///
  /// [faction]: la nueva facción seleccionada por el operador.
  /// Llama a [notifyListeners] para reconstruir todos los
  /// widgets que están escuchando este provider.
  void setFaction(Faction faction) {
    _currentFaction = faction;
    notifyListeners();
  }

  /// Actualiza el nombre del agente en el perfil.
  ///
  /// [name]: nombre ingresado por el operador.
  /// Si está vacío conserva el nombre anterior.
  void setAgentName(String name) {
    if (name.trim().isEmpty) return;
    _agentName = name.trim().toUpperCase();
    notifyListeners();
  }

  /// Registra una misión completada y actualiza el nivel.
  ///
  /// El nivel sube cada 2 misiones completadas.
  /// Nivel máximo: 10.
  void completeMission() {
    _missionsCompleted++;
    _agentLevel = (_missionsCompleted ~/ 2 + 1).clamp(1, 10);
    notifyListeners();
  }

  /// Retorna el estilo de texto de la facción activa.
  ///
  /// [size]: tamaño de fuente.
  /// [bold]: si aplica negrita.
  /// [color]: color opcional. Si es null usa primaryColor.
  TextStyle textStyle({
    double size = 14,
    bool bold = false,
    Color? color,
  }) =>
      _currentFaction.textStyle(
        size: size,
        bold: bold,
        color: color,
      );

  /// Retorna el rango del agente según su nivel.
  ///
  /// Retorna una cadena con el título del rango actual.
  String get agentRank {
    if (_agentLevel >= 9) return 'OPERADOR ÉLITE';
    if (_agentLevel >= 7) return 'OPERADOR SENIOR';
    if (_agentLevel >= 5) return 'OPERADOR REGULAR';
    if (_agentLevel >= 3) return 'OPERADOR JUNIOR';
    return 'RECLUTA';
  }
}
