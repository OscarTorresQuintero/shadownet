...import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/terminal_theme.dart';
import '../models/node_model.dart';
import '../widgets/terminal_widgets.dart';
import '../services/vibration_service.dart';

class MissionScreen extends StatefulWidget {
  final MissionNode node;
  const MissionScreen({super.key, required this.node});

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen>
    with TickerProviderStateMixin {

  final TextEditingController _cmdController = TextEditingController();
  final ScrollController _scrollController   = ScrollController();
  final FocusNode _focusNode                 = FocusNode();

  final List<_TerminalLine> _lines = [];
  bool _missionComplete = false;
  bool _isProcessing    = false;
  int  _commandCount    = 0;

  late final List<String> _requiredCommands;
  late final Map<String, String> _commandResponses;

  late AnimationController _completionController;

  // ═══════════════════════════════════════════════
  //  INICIALIZACIÓN
  // ═══════════════════════════════════════════════
  @override
  void initState() {
    super.initState();
    _completionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _setupMissionCommands();
    _startBootSequence();
  }

  @override
  void dispose() {
    _cmdController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _completionController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════
  //  CONFIGURACIÓN DE COMANDOS POR NODO
  // ═══════════════════════════════════════════════
  void _setupMissionCommands() {
    switch (widget.node.id) {

      case 'ALPHA':
        _requiredCommands = ['scan', 'connect', 'inject', 'extract'];
        _commandResponses = {
          'scan':
            '> Escaneando red ACADEMICA-NET...\n'
            '> 3 servicios detectados en puerto 8080\n'
            '> Vulnerabilidad SQL encontrada: CVE-2084-0042\n'
            '> [OK] Escaneo completado.',
          'connect':
            '> Estableciendo túnel cifrado...\n'
            '> Conexión SSH establecida: root@academica-server\n'
            '> Sesión activa. No dejes rastro.\n'
            '> [OK] Conexión establecida.',
          'inject':
            '> Inyectando payload en base de datos...\n'
            '> [████████░░] 80% — Bypasseando firewall\n'
            '> [██████████] 100% — Acceso root obtenido\n'
            '> [OK] Payload ejecutado.',
          'extract':
            '> Extrayendo base de datos de notas...\n'
            '> 247 registros descargados\n'
            '> Archivos cifrados con AES-256\n'
            '> [OK] Datos enviados a ShadowNet.',
        };
        break;

      case 'BETA':
        _requiredCommands = ['tune', 'listen', 'decode', 'relay'];
        _commandResponses = {
          'tune':
            '> Sintonizando frecuencia 98.7 MHz...\n'
            '> Señal detectada. Intensidad: -23 dBm\n'
            '> Ruido blanco filtrado.\n'
            '> [OK] Frecuencia bloqueada.',
          'listen':
            '> Capturando transmisión de audio...\n'
            '> Duración: 43 segundos\n'
            '> Archivo guardado: intercept_98.7_2084.wav\n'
            '> [OK] Transmisión capturada.',
          'decode':
            '> Decodificando cifrado de voz...\n'
            '> Algoritmo detectado: XOR-Vigenere-2084\n'
            '> Resultado: "Operativo Nexus iniciado a las 03:00"\n'
            '> [OK] Mensaje descifrado.',
          'relay':
            '> Retransmitiendo datos a ShadowNet...\n'
            '> Paquetes enviados al Nodo Central\n'
            '> Confirmación recibida: ACK-7743\n'
            '> [OK] Misión documentada.',
        };
        break;

      case 'GAMMA':
        _requiredCommands = ['ping', 'override', 'corrupt', 'redirect'];
        _commandResponses = {
          'ping':
            '> Detectando drones en la zona...\n'
            '> 7 unidades activas: DRN-01 al DRN-07\n'
            '> Protocolo de firmware: FW-v9.2\n'
            '> [OK] Drones identificados.',
          'override':
            '> Tomando control del firmware...\n'
            '> Enviando paquetes UDP malformados...\n'
            '> Control de 5/7 drones obtenido\n'
            '> [OK] Sistema comprometido.',
          'corrupt':
            '> Corrompiendo sistema de navegación GPS...\n'
            '> Spoofing de coordenadas activado\n'
            '> DRN-01 al DRN-07 en estado de pánico\n'
            '> [OK] Navegación saboteada.',
          'redirect':
            '> Redirigiendo drones a zona de exclusión K7...\n'
            '> DRN-01... fuera de servicio\n'
            '> DRN-02 al DRN-07... fuera de servicio\n'
            '> [OK] Sabotaje completado.',
        };
        break;

      default:
        _requiredCommands = [];
        _commandResponses = {};
    }
  }

  // ═══════════════════════════════════════════════
  //  SECUENCIA DE ARRANQUE DEL TERMINAL
  // ═══════════════════════════════════════════════
  void _startBootSequence() async {
    final bootLines = [
      '═══════════════════════════════════════════',
      'SHADOWNET TERMINAL v2.084',
      '═══════════════════════════════════════════',
      '',
      'INICIALIZANDO MÓDULO DE MISIÓN...',
      'CLASIFICACIÓN : ████████████ ULTRA SECRETO',
      'OPERADOR       : [IDENTIDAD VERIFICADA]',
      'NODO           : ${widget.node.codename}',
      'UBICACIÓN      : ${widget.node.location}',
      '',
      '═══[ BRIEFING ]════════════════════════════',
      widget.node.missionDetails,
      '',
      '═══[ COMANDOS DISPONIBLES ]════════════════',
      ...List.generate(
        _requiredCommands.length,
        (i) => '  [${i + 1}] ${_requiredCommands[i].toUpperCase()}',
      ),
      '',
      '  También puedes usar: help | status | clear | exit',
      '',
      '> Terminal lista. Ingresa el primer comando.',
    ];

    for (final line in bootLines) {
      await Future.delayed(const Duration(milliseconds: 55));
      if (!mounted) return;
      _addLine(
        line,
        color: line.startsWith('>') || line.startsWith('  [')
            ? TerminalTheme.amber
            : TerminalTheme.primaryGreen,
      );
    }
  }

  // ═══════════════════════════════════════════════
  //  MANEJO DE LÍNEAS DEL TERMINAL
  // ═══════════════════════════════════════════════
  void _addLine(String text, {Color? color, bool isInput = false}) {
    setState(() {
      _lines.add(_TerminalLine(
        text: text,
        color: color ?? TerminalTheme.primaryGreen,
        isInput: isInput,
      ));
    });
    // Scroll automático al fondo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ═══════════════════════════════════════════════
  //  EJECUCIÓN DE COMANDOS
  // ═══════════════════════════════════════════════
  void _executeCommand(String cmd) async {
    if (cmd.trim().isEmpty || _isProcessing || _missionComplete) return;

    final command = cmd.trim().toLowerCase();
    _cmdController.clear();

    // Mostrar el comando escrito por el usuario
    _addLine(
      'shadownet@operador:~\$ $command',
      isInput: true,
    );

    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 300));

    // ── Comandos especiales ──────────────────────
    if (command == 'help') {
      _addLine('> Comandos de esta misión:', color: TerminalTheme.amber);
      for (int i = 0; i < _requiredCommands.length; i++) {
        final done = i < _commandCount;
        _addLine(
          '  [${i + 1}] ${_requiredCommands[i].toUpperCase()}'
          '${done ? "  ✓" : ""}',
          color: done ? TerminalTheme.dimGreen : TerminalTheme.primaryGreen,
        );
      }
      _addLine('  help | status | clear | exit',
          color: TerminalTheme.dimGreen);

    } else if (command == 'status') {
      _addLine(
        '> Progreso: $_commandCount/${_requiredCommands.length} pasos',
        color: TerminalTheme.amber,
      );
      if (_commandCount < _requiredCommands.length) {
        _addLine(
          '> Siguiente comando: '
          '${_requiredCommands[_commandCount].toUpperCase()}',
          color: TerminalTheme.amber,
        );
      }

    } else if (command == 'clear') {
      setState(() => _lines.clear());

    } else if (command == 'exit' || command == 'quit') {
      _addLine('> Cerrando terminal...', color: TerminalTheme.amber);
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) Navigator.pop(context, false);

    // ── Comandos de misión ───────────────────────
    } else if (_commandResponses.containsKey(command)) {

      // Verificar si es el comando correcto en el orden correcto
      final expectedCommand = _commandCount < _requiredCommands.length
          ? _requiredCommands[_commandCount]
          : null;

      if (command == expectedCommand) {
        // Comando correcto en el orden correcto
        for (final line in _commandResponses[command]!.split('\n')) {
          await Future.delayed(const Duration(milliseconds: 120));
          if (!mounted) return;
          _addLine(line);
        }
        _commandCount++;

        // Verificar si completó todos los pasos
        if (_commandCount >= _requiredCommands.length) {
          await Future.delayed(const Duration(milliseconds: 500));
          _completeMission();
        }
      } else {
        // Comando válido pero fuera de orden
        _addLine(
          '> ERROR: Secuencia incorrecta.',
          color: TerminalTheme.red,
        );
        _addLine(
          '> Debes ejecutar primero: '
          '${expectedCommand?.toUpperCase() ?? "N/A"}',
          color: TerminalTheme.amber,
        );
      }

    // ── Comando desconocido ──────────────────────
    } else {
      _addLine(
        '> ERROR: Comando no reconocido: "$command"',
        color: TerminalTheme.red,
      );
      _addLine(
        '> Escribe "help" para ver los comandos disponibles.',
        color: TerminalTheme.dimGreen,
      );
    }

    setState(() => _isProcessing = false);
    _focusNode.requestFocus();
  }

  // ═══════════════════════════════════════════════
  //  COMPLETAR MISIÓN
  // ═══════════════════════════════════════════════
  void _completeMission() async {
    setState(() => _missionComplete = true);

    final hash = DateTime.now()
        .millisecondsSinceEpoch
        .toRadixString(16)
        .toUpperCase();

    final completionLines = [
      '',
      '╔══════════════════════════════════════════╗',
      '║                                          ║',
      '║   ✓  MISIÓN COMPLETADA EXITOSAMENTE      ║',
      '║   ${widget.node.codename.padRight(40)}║',
      '║                                          ║',
      '╚══════════════════════════════════════════╝',
      '',
      '> Registrando en blockchain de ShadowNet...',
      '> Hash de confirmación: 0x$hash',
      '> Operador acreditado.',
      '> Puntos obtenidos: +500 XP',
      '',
      '> Transmitiendo código Morse de confirmación...',
      '> . - - / - . -',
      '> (OK)',
    ];

    for (final line in completionLines) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      _addLine(
        line,
        color: line.contains('✓') || line.contains('╗') ||
               line.contains('╚') || line.contains('╔') ||
               line.contains('║')
            ? TerminalTheme.primaryGreen
            : TerminalTheme.cyan,
      );
    }

    // Vibración en código Morse
    await VibrationService.missionComplete();

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) _showCompletionDialog();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: TerminalTheme.bgColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: TerminalTheme.primaryGreen, width: 2),
        ),
        title: Text(
          '[ MISIÓN COMPLETADA ]',
          style: TerminalTheme.terminalTitle.copyWith(fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nodo     : ${widget.node.codename}',
                style: TerminalTheme.terminalText),
            Text('Misión   : ${widget.node.mission}',
                style: TerminalTheme.terminalText),
            Text('Estado   : COMPLETADO',
                style: TerminalTheme.terminalText
                    .copyWith(color: TerminalTheme.cyan)),
            const SizedBox(height: 16),
            Text('> Volviendo al geo-radar...',
                style: TerminalTheme.terminalSmall),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, true); // true = misión completada
            },
            child: Text('[ CONFIRMAR ]',
                style: TerminalTheme.terminalText),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TerminalTheme.bgColor,
      appBar: AppBar(
        backgroundColor: TerminalTheme.bgColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: TerminalTheme.primaryGreen, size: 16),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.node.codename,
                style: TerminalTheme.terminalSmall),
            Text(widget.node.location,
                style: TerminalTheme.terminalSmall
                    .copyWith(fontSize: 10)),
          ],
        ),
        actions: [
          if (_missionComplete)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.check_circle,
                  color: TerminalTheme.cyan, size: 20),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildProgressBar(),
          Expanded(child: _buildTerminalOutput()),
          if (!_missionComplete) _buildCommandInput(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  WIDGETS VISUALES
  // ═══════════════════════════════════════════════
  Widget _buildProgressBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PROGRESO: $_commandCount/${_requiredCommands.length} pasos',
          style: TerminalTheme.terminalSmall,
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: _requiredCommands.isEmpty
              ? 0
              : _commandCount / _requiredCommands.length,
          backgroundColor: TerminalTheme.bgColor,
          valueColor: AlwaysStoppedAnimation<Color>(
            _missionComplete
                ? TerminalTheme.cyan
                : TerminalTheme.primaryGreen,
          ),
          minHeight: 2,
        ),
      ],
    ),
  );

  Widget _buildTerminalOutput() => ListView.builder(
    controller: _scrollController,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    itemCount: _lines.length,
    itemBuilder: (_, i) {
      final line = _lines[i];
      return Text(
        line.text,
        style: TerminalTheme.terminalSmall.copyWith(
          color: line.isInput ? TerminalTheme.amber : line.color,
          fontSize: 13,
          fontWeight: line.isInput
              ? FontWeight.bold
              : FontWeight.normal,
        ),
      );
    },
  );

  Widget _buildCommandInput() => Container(
    decoration: BoxDecoration(
      color: TerminalTheme.bgColor,
      border: Border(
        top: BorderSide(
          color: TerminalTheme.dimGreen.withOpacity(0.4),
        ),
      ),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    child: Row(
      children: [
        Text(
          'shadownet\$> ',
          style: TerminalTheme.terminalText
              .copyWith(color: TerminalTheme.amber),
        ),
        Expanded(
          child: TextField(
            controller: _cmdController,
            focusNode: _focusNode,
            autofocus: true,
            style: TerminalTheme.terminalText,
            cursorColor: TerminalTheme.primaryGreen,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            onSubmitted: _executeCommand,
            enabled: !_isProcessing,
          ),
        ),
        if (_isProcessing)
          const TerminalLoader(message: ''),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════
//  MODELO INTERNO DE LÍNEA DE TERMINAL
// ═══════════════════════════════════════════════
class _TerminalLine {
  final String text;
  final Color color;
  final bool isInput;

  _TerminalLine({
    required this.text,
    required this.color,
    required this.isInput,
  });
}