import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'package:google_fonts/google_fonts.dart';

/// Kurzer Startbildschirm mit Logo & Übergang nach 2 Sekunden
class Startbildschirm extends StatefulWidget {
  const Startbildschirm({super.key});

  @override
  State<Startbildschirm> createState() => _StartbildschirmState();
}

class _StartbildschirmState extends State<Startbildschirm> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Dashboard()),
      );
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
            colors: [Color(0xFFE6DFC9), Color(0xFF60594A)],
            stops: [0, 0.7],
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
                  letterSpacing: 2,
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