import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'services/faction_provider.dart';
import 'screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bloquea la rotación a vertical
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

runApp(
  ChangeNotifierProvider(
    create: (_) => FactionProvider(),
    child: const ShadowNetApp(),
  ),
);

class ShadowNetApp extends StatelessWidget {
  const ShadowNetApp({super.key});

  @override 
  
Widget build(BuildContext context) {
  return Consumer<FactionProvider>(
    builder: (context, factionProvider, child) {
      return MaterialApp(
        title: 'ShadowNet',
        debugShowCheckedModeBanner: false,

        theme: factionProvider.currentTheme,

        home: const AuthScreen(),

        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(1.0),
            ),
            child: child!,
          );
        },
      );
    },
  );
}
SystemChrome.setSystemUIOverlayStyle(
  const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  ),
);
