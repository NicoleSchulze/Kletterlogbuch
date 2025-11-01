import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_kletterlogbuch/modelle/klettereintrag.dart';
import 'app_widget.dart';

/// Initialisiert Hive und startet die App
Future<void> starteApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive initialisieren
  await Hive.initFlutter();
  // Adapter registrieren
  Hive.registerAdapter(KletterEintragAdapter());
  // Box öffnen
  await Hive.openBox<KletterEintrag>('klettereintraege');
  // App starten
  runApp(const MeineApp());
}
