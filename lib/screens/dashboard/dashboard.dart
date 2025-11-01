import 'package:flutter/material.dart';
import 'package:flutter_kletterlogbuch/konstanten/farben.dart';
import 'dashboard_hilfe.dart';
import 'dashboard_ui.dart';

/// ============================================================
/// Dashboard Screen (Kletterlogbuch)
/// ============================================================
/// Funktionalität:
///   - Zeigt alle Klettereinträge gruppiert nach Datum und Gebiet
///   - Unterstützt Editier- und Löschmodus
///   - Ermöglicht Filterung nach verschiedenen Kategorien
/// ============================================================
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // Logikklasse
  final DashboardHilfe _hilfe = DashboardHilfe();
  // UI-Klasse
  final DashboardUI _ui = DashboardUI();

  // Initialisierung
  @override
  void initState() {
    super.initState();
    _hilfe.init(context, setState);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppFarben.hellesCreme,
      appBar: _ui.erstelleAppBar(context, _hilfe),
      body: _ui.erstelleBody(_hilfe),
      floatingActionButton: _ui.erstelleAddButton(context, _hilfe),
    );
  }
}
