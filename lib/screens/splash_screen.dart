import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'package:google_fonts/google_fonts.dart';

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
              Color(0xFFE6DFC9), // etwas dunkleres Beige oben
              Color(0xFF60594A), // dunkleres Braun unten
            ],
            stops: [0, 0.7], // 0.33 = erstes Drittel hell, Rest dunkel
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.terrain, size: 90, color: Color(0xFF60594A)),
              const SizedBox(height: 8),

              Text(
                "KLETTERLOGBUCH",
                style: GoogleFonts.openSans(
                  color: const Color(0xFFF1ECD7),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0
                ),
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(color: Color(0xFFF1ECD7)),
            ],
          ),
        ),
      ),
    );
  }
}