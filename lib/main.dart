import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/terminal_theme.dart';
import 'screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Forzar orientación vertical
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Barra de estado oscura y transparente
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: TerminalTheme.bgColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const ShadowNetApp());
}

class ShadowNetApp extends StatelessWidget {
  const ShadowNetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShadowNet',
      debugShowCheckedModeBanner: false,
      theme: TerminalTheme.darkTheme,
      home: const AuthScreen(), // Siempre inicia en biometría
    );
  }
}