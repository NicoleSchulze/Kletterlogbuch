import 'package:flutter/material.dart';
import 'dashboard.dart';

/// --- Splash Screen/Startscreen ---
// Statefullwidget = weil nach 2 Sekunden automatisch weiterleitet
// Widget-Klasse beschreibt nur
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

// Flutter baut SplashScreen auf und fragt, welche State-Klasse soll ich dazu verwenden?
// Antwort: createState() liefert _SplashScreenState
// Jeder StatefulWidget hat createState() Methode
// override = überschreibt Standard-Implementierung von Flutter
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// State-Klasse kümmert sich um alles, was sich ändert
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() { // startet Timer
    super.initState();

    // Nach 2 Sekunden weiter zum Dashboard
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Dashboard()),
      );
    });
  }

// Aufbau Inhalt Splashscreen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F5F5), // helles Grau
              Color(0xFF2E7D32), // sattes Grün
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.terrain, size: 80, color: Colors.white),
              const SizedBox(height: 20),
              Text(
                "KLETTERLOGBUCH",
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}