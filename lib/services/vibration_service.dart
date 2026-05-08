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
  // Al completar una misión → vibra código Morse "OK"
  static Future<void> missionComplete() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (!hasVibrator) return;

    await Vibration.vibrate(pattern: _missionComplete);
  }
}