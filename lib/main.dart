import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';       // Hive initialisieren & verwenden
import 'models/kletterweg_datenmodell.dart';


/// Starte meine App und zeige das Widget MyApp
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter(); // Hive initialisieren
  Hive.registerAdapter(KletterEintragAdapter()); // Adapter registrieren
  await Hive.openBox<KletterEintrag>('klettereintraege');

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
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('de', 'DE'), // Deutsch
      ],
      home: const SplashScreen(),
    );
  }
}
