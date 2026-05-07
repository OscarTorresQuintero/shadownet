import 'package:vibration/vibration.dart';

class VibrationService {

  // ── UNIDADES DE TIEMPO ───────────────────────
  static const int dot       = 100; // Punto  (.)
  static const int dash      = 300; // Raya   (—)
  static const int symbolGap = 100; // Pausa entre símbolos
  static const int letterGap = 300; // Pausa entre letras

  // Morse de "OK" (confirmación de misión completada)
  // O = .--   K = -.-
  static const List<int> _missionComplete = [
    dot,  symbolGap,
    dash, symbolGap,
    dash,
    letterGap,
    dash, symbolGap,
    dot,  symbolGap,
    dash,
  ];

  // SOS (al acercarte a un nodo)
  // S = ...   O = ---   S = ...
  static const List<int> _nodeDetected = [
    dot, symbolGap, dot, symbolGap, dot,
    letterGap,
    dash, symbolGap, dash, symbolGap, dash,
    letterGap,
    dot, symbolGap, dot, symbolGap, dot,
  ];

  // Patrón de autodestrucción (3 fallos biométricos)
  static const List<int> _selfDestruct = [
    500, 150,
    500, 150,
    500, 150,
    1000, 200,
    1000, 200,
    1000,
  ];

  // Al completar una misión → vibra código Morse "OK"
  static Future<void> missionComplete() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (!hasVibrator) return;

    await Vibration.vibrate(pattern: _missionComplete);
  }

  // Al acercarte a un nodo → vibra SOS
  static Future<void> nodeDetected() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (!hasVibrator) return;

    await Vibration.vibrate(pattern: _nodeDetected);
  }

  // Al fallar biometría 3 veces → vibra fuerte 5 segundos
  static Future<void> selfDestruct() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (!hasVibrator) return;

    await Vibration.vibrate(pattern: _selfDestruct);
  }

  // Cancela cualquier vibración activa
  static Future<void> cancel() async {
    await Vibration.cancel();
  }
}