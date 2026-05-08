import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../theme/terminal_theme.dart';
import '../widgets/terminal_widgets.dart';
import '../services/vibration_service.dart';
import 'radar_screen.dart'; // ← Este import es clave

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with TickerProviderStateMixin {

  final LocalAuthentication _auth = LocalAuthentication();

  int  _failedAttempts       = 0;
  bool _isLocked             = false;
  bool _isScanning           = false;
  bool _selfDestructActive   = false;
  int  _selfDestructCountdown = 5;

  String _statusMessage = '> SISTEMA SHADOWNET v2.084';
  String _subMessage    = '> Esperando validación biométrica...';
  Color  _statusColor   = TerminalTheme.primaryGreen;

  late AnimationController _scanController;
  late Animation<double>   _scanAnimation;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0, end: 1)
        .animate(_scanController);
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════
  //  AUTENTICACIÓN BIOMÉTRICA
  // ═══════════════════════════════════════════
  Future<void> _authenticate() async {
  if (_isLocked || _isScanning || _selfDestructActive) return;

  setState(() {
    _isScanning = true;
    _statusMessage = '> ESCANEANDO ADN BIOMÉTRICO...';
    _subMessage = '> No retire el dedo del sensor';
    _statusColor = TerminalTheme.amber;
  });

  try {

    final biometrics = await _auth.getAvailableBiometrics();

    print("BIOMETRÍA DISPONIBLE: $biometrics");

    if (biometrics.isEmpty) {
      // Si no hay biometría, usar modo simulado
      _handleSimulatedAuth();
      return;
    }

    final bool authenticated = await _auth.authenticate(
      localizedReason: 'Valida tu identidad',
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
      ),
    );

    if (authenticated) {
      _handleSuccess();
    } else {
      _handleFailure();
    }

  } on PlatformException catch (e) {

    print("ERROR BIOMÉTRICO: $e");

    // Si hay error en el sensor, usar modo simulado
    _handleSimulatedAuth();
  }
}
  // ═══════════════════════════════════════════
  //  MANEJADORES DE RESULTADO
  // ═══════════════════════════════════════════
  void _handleSuccess() {
    setState(() {
      _isScanning    = false;
      _failedAttempts = 0;
      _statusMessage = '> ✓ ADN VERIFICADO';
      _subMessage    = '> Acceso concedido. Bienvenido, Operador.';
      _statusColor   = TerminalTheme.primaryGreen;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RadarScreen()),
        );
      }
    });
  }

  void _handleFailure() {
    _failedAttempts++;

    setState(() {
      _isScanning    = false;
      _statusMessage = '> ✗ ADN NO RECONOCIDO';
      _subMessage    = '> ADVERTENCIA: ${3 - _failedAttempts} intentos restantes';
      _statusColor   = TerminalTheme.red;
    });

    if (_failedAttempts >= 3) {
      _triggerSelfDestruct();
    }
  }

  void _handleSimulatedAuth() {
    setState(() => _isScanning = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: TerminalTheme.bgColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: TerminalTheme.amber),
        ),
        title: Text('MODO SIMULACIÓN', style: TerminalTheme.warningText),
        content: Text(
          'Dispositivo sin biometría detectada.\n'
          '¿Acceso de emergencia?',
          style: TerminalTheme.terminalText,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _handleFailure();
            },
            child: Text('DENEGAR', style: TerminalTheme.dangerText),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _handleSuccess();
            },
            child: Text('CONCEDER', style: TerminalTheme.terminalText),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  AUTODESTRUCCIÓN (3 fallos)
  // ═══════════════════════════════════════════
  void _triggerSelfDestruct() async {
    setState(() {
      _selfDestructActive    = true;
      _isLocked              = true;
      _selfDestructCountdown = 5;
      _statusMessage = '> ⚠ PROTOCOLO DE AUTODESTRUCCIÓN INICIADO';
      _subMessage    = '> ALERTA DE SEGURIDAD MÁXIMA';
      _statusColor   = TerminalTheme.red;
    });

    // Vibrar fuerte durante toda la cuenta regresiva
    VibrationService.selfDestruct();

    // Cuenta regresiva de 5 a 0
    for (int i = 5; i >= 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) setState(() => _selfDestructCountdown = i);
    }

    // Desbloquear y resetear después de los 5 segundos
    if (mounted) {
      setState(() {
        _selfDestructActive    = false;
        _isLocked              = false;
        _failedAttempts        = 0;
        _selfDestructCountdown = 5;
        _statusMessage = '> Sistema reiniciado. Intente de nuevo.';
        _subMessage    = '> Esperando validación biométrica...';
        _statusColor   = TerminalTheme.amber;
      });
    }
  }

  // ═══════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TerminalTheme.bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              const TerminalDivider(label: 'ESCANEO BIOMÉTRICO'),
              const SizedBox(height: 20),
              Expanded(child: _buildScanArea()),
              _buildStatus(),
              const SizedBox(height: 20),
              if (!_selfDestructActive) _buildAuthButton(),
              const SizedBox(height: 16),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  WIDGETS VISUALES
  // ═══════════════════════════════════════════
  Widget _buildHeader() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('SHADOWNET://AUTH', style: TerminalTheme.terminalSmall),
      const SizedBox(height: 4),
      Text('PROTOCOLO DE ACCESO v2.084',
          style: TerminalTheme.terminalTitle),
      const SizedBox(height: 8),
      Row(
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isLocked
                  ? TerminalTheme.red
                  : TerminalTheme.primaryGreen,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _isLocked ? 'SISTEMA BLOQUEADO' : 'SISTEMA ACTIVO',
            style: TerminalTheme.terminalSmall.copyWith(
              color: _isLocked
                  ? TerminalTheme.red
                  : TerminalTheme.dimGreen,
            ),
          ),
        ],
      ),
    ],
  );

  Widget _buildScanArea() {
    // Pantalla de autodestrucción
    if (_selfDestructActive) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '☢',
              style: TextStyle(
                color: TerminalTheme.red,
                fontSize: 80,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'PROTOCOLO DE AUTODESTRUCCIÓN INICIADO',
              style: TerminalTheme.dangerText.copyWith(fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              '$_selfDestructCountdown',
              style: TerminalTheme.dangerText.copyWith(fontSize: 72),
            ),
            const SizedBox(height: 10),
            Text(
              'ELIMINANDO DATOS SENSIBLES...',
              style: TerminalTheme.terminalSmall
                  .copyWith(color: TerminalTheme.red),
            ),
          ],
        ),
      );
    }

    // Animación normal de escaneo
    return Center(
      child: AnimatedBuilder(
        animation: _scanAnimation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Anillo exterior
              Container(
                width: 220, height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _statusColor.withOpacity(0.15),
                    width: 1,
                  ),
                ),
              ),
              // Anillo medio
              Container(
                width: 170, height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _statusColor.withOpacity(
                      0.2 + _scanAnimation.value * 0.3,
                    ),
                    width: 1,
                  ),
                ),
              ),
              // Anillo interior
              Container(
                width: 130, height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _statusColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              // Ícono de huella
              Icon(
                Icons.fingerprint,
                size: 100,
                color: _statusColor.withOpacity(0.9),
              ),
              // Línea de escaneo animada
              if (_isScanning)
                Positioned(
                  top: 60 + (_scanAnimation.value * 100),
                  child: Container(
                    width: 130,
                    height: 2,
                    color: TerminalTheme.cyan.withOpacity(0.7),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatus() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        _statusMessage,
        style: TerminalTheme.terminalText
            .copyWith(color: _statusColor),
      ),
      const SizedBox(height: 4),
      Text(_subMessage, style: TerminalTheme.terminalSmall),
      const SizedBox(height: 10),
      // Indicadores de intentos (3 cuadros)
      Row(
        children: List.generate(3, (i) => Container(
          margin: const EdgeInsets.only(right: 8),
          width: 22, height: 22,
          decoration: BoxDecoration(
            border: Border.all(color: TerminalTheme.red, width: 1),
            color: i < _failedAttempts
                ? TerminalTheme.red.withOpacity(0.5)
                : Colors.transparent,
          ),
          child: i < _failedAttempts
              ? const Icon(Icons.close,
                  color: TerminalTheme.red, size: 14)
              : null,
        )),
      ),
    ],
  );

  Widget _buildAuthButton() => SizedBox(
    width: double.infinity,
    child: TerminalButton(
      label: _isScanning
          ? 'ESCANEANDO...'
          : 'INICIAR ESCANEO BIOMÉTRICO',
      onPressed: _isScanning ? null : _authenticate,
      color: _failedAttempts > 0
          ? TerminalTheme.amber
          : TerminalTheme.primaryGreen,
    ),
  );

  Widget _buildFooter() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        'INTENTOS: $_failedAttempts/3',
        style: TerminalTheme.terminalSmall,
      ),
      Row(children: [
        Text('CIFRADO: AES-256  ',
            style: TerminalTheme.terminalSmall),
        const BlinkingCursor(),
      ]),
    ],
  );
}