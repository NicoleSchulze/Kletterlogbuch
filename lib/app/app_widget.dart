import 'package:flutter/material.dart';
import 'package:flutter_kletterlogbuch/konstanten/farben.dart';
import 'package:flutter_kletterlogbuch/screens/startbildschirm.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Haupt-Widget der App mit Theme und Startbildschirm
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kletterlogbuch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppFarben.primaerygruen),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('de', 'DE')],
      home: const Startbildschirm(),
    );
  }
}