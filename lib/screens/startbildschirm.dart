import 'package:flutter/material.dart';
import 'package:flutter_kletterlogbuch/konstanten/farben.dart';
import 'dashboard.dart';

/// ============================================================
/// Startbildschirm / Splash Screen
/// ============================================================
/// Funktionalität:
/// - Zeigt Logo & App-Namen
/// - Automatische Weiterleitung zum Dashboard wechseln
/// ============================================================
class Startbildschirm extends StatefulWidget {
  const Startbildschirm({super.key});

  @override
  State<Startbildschirm> createState() => _StartbildschirmState();
}

class _StartbildschirmState extends State<Startbildschirm> {
  @override
  void initState() {
    super.initState();
    // Nach 2 Sekunden zum Dashboard wechseln
    Future.delayed(const Duration(seconds: 2), () {
      //Best Practice ???
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Dashboard()),);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppFarben.dunklesCreme, AppFarben.dunkelbraun],
            stops: [0, 0.7],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.terrain,
                  size: 90,
                  color: AppFarben.dunkelbraun,
                ),
                const SizedBox(height: 8),
                Text(
                  "KLETTERLOGBUCH",
                  style: TextStyle(
                    color: AppFarben.dunklesCreme,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 20),
                const CircularProgressIndicator(color: AppFarben.dunklesCreme),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
