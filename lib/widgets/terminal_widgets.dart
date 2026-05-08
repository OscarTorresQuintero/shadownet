import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/terminal_theme.dart';

class BlinkingCursor extends StatefulWidget {
  const BlinkingCursor({super.key});

  @override
  State<BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<BlinkingCursor> {
  bool _visible = true;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Cambia entre visible e invisible cada 500ms
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) setState(() => _visible = !_visible);
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Siempre cancela el timer al salir
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _visible ? '█' : ' ',
      style: TerminalTheme.terminalText,
    );
  }
}

class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration speed;
  final VoidCallback? onComplete;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.speed = const Duration(milliseconds: 30),
    this.onComplete,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayed = '';
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.speed, (_) {
      if (_index < widget.text.length) {
        if (mounted) {
          setState(() {
            _displayed += widget.text[_index];
            _index++;
          });
        }
      } else {
        _timer?.cancel();
        widget.onComplete?.call(); // Avisa cuando termina
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayed,
      style: widget.style ?? TerminalTheme.terminalText,
    );
  }
}

class TerminalDivider extends StatelessWidget {
  final String? label;
  const TerminalDivider({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        label != null
            ? '═══[ $label ]══════════════════════'
            : '═══════════════════════════════════',
        style: TerminalTheme.terminalSmall,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class TerminalButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  const TerminalButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? TerminalTheme.primaryGreen;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: c, width: 1.5),
          color: c.withOpacity(0.08),
        ),
        child: Text(
          '[ $label ]',
          style: TerminalTheme.terminalText.copyWith(color: c),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class TerminalLoader extends StatefulWidget {
  final String message;
  const TerminalLoader({super.key, required this.message});

  @override
  State<TerminalLoader> createState() => _TerminalLoaderState();
}

class _TerminalLoaderState extends State<TerminalLoader> {
  final List<String> _frames = [
    '⠋','⠙','⠹','⠸','⠼','⠴','⠦','⠧','⠇','⠏'
  ];
  int _frame = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) setState(() => _frame = (_frame + 1) % _frames.length);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_frames[_frame], style: TerminalTheme.terminalText),
        const SizedBox(width: 8),
        Text(widget.message, style: TerminalTheme.terminalSmall),
      ],
    );
  }
}
