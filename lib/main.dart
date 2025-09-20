import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

/// Starte meine App und zeige das Widget MyApp
void main() {
  runApp(const MyApp());
}

/// --- Haupt-App ---
// Wurzel-Widget
// Festlegen Titel, Theme/Farben, Startbildschirm = home (Splitscreen)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kletterlogbuch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
