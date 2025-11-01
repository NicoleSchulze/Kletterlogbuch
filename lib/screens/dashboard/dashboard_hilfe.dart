import 'package:flutter/material.dart';
import 'package:flutter_kletterlogbuch/modelle/klettereintrag.dart';
import 'package:flutter_kletterlogbuch/services/hive_hilfe.dart';
import 'package:flutter_kletterlogbuch/screens/dashboard/dashboard_dialogNeuerWeg.dart';
import 'dashboard_dialogFilter.dart';

/// ----------------------------
/// DashboardHilfe
/// ----------------------------
class DashboardHilfe {
  late BuildContext context;
  late void Function(VoidCallback fn) aktualisieren;

  // Aktueller Filterstatus
  Map<String, dynamic> filterMap = {
    "datum": null,
    "gebiet": null,
    "gipfel": null,
    "weg": null,
    "schwierigkeit": null,
  };

  // Gruppierte Daten
  Map<String, Map<String, List<KletterEintrag>>>
  eintraegeNachDatumGebietGipfel = {};

  // Edit/Delete State
  bool editierModus = false;
  bool loeschModus = false;
  Set<String> ausgewaehlteKeys = {};

  // Controller-Verwaltung
  final Map<int, Map<String, TextEditingController>> controllers = {};

  // Initialisierung
  void init(BuildContext ctx, void Function(VoidCallback fn) setState) {
    context = ctx;
    aktualisieren = setState;
    ladeKletterwege();
  }

  // Daten aus Hive laden + gruppieren
  Future<void> ladeKletterwege() async {
    final alleEintraege = HiveHilfe.alle();

    final gefiltert = alleEintraege.where((e) {
      bool match = true;
      filterMap.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          switch (key) {
            case "datum":
              match &= e.datum == value;
              break;
            case "gebiet":
              match &= e.gebiet == value;
              break;
            case "gipfel":
              match &= e.gipfel.contains(value);
              break;
            case "weg":
              match &= e.weg.contains(value);
              break;
            case "schwierigkeit":
              match &= e.schwierigkeit == value;
              break;
          }
        }
      });
      return match;
    }).toList();

    Map<String, Map<String, List<KletterEintrag>>> tempMap = {};
    for (var e in gefiltert) {
      final keyDatumGebiet = "${e.datum} – ${e.gebiet}";
      final keyGipfel = e.gipfel;
      tempMap.putIfAbsent(keyDatumGebiet, () => {});
      tempMap[keyDatumGebiet]!.putIfAbsent(keyGipfel, () => []);
      tempMap[keyDatumGebiet]![keyGipfel]!.add(e);

      if (controllers.containsKey(e.key)) {
        controllers[e.key]!['weg']!.text = e.weg;
        controllers[e.key]!['schwierigkeit']!.text = e.schwierigkeit;
      } else {
        controllers[e.key] = {
          'weg': TextEditingController(text: e.weg),
          'schwierigkeit': TextEditingController(text: e.schwierigkeit),
        };
      }
    }

    final sortedKeys = tempMap.keys.toList()
      ..sort((a, b) {
        final dateA = DateTime.parse(
          a.split(' – ')[0].split('.').reversed.join('-'),
        );
        final dateB = DateTime.parse(
          b.split(' – ')[0].split('.').reversed.join('-'),
        );
        return dateB.compareTo(dateA);
      });

    eintraegeNachDatumGebietGipfel
      ..clear()
      ..addAll({for (var k in sortedKeys) k: tempMap[k]!});

    aktualisieren(() {});
  }

  // Neuer Kletterweg
  void neuerKletterweg(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => DialogNeuerKletterweg(
        beimSpeichern: (KletterEintrag neu) async {
          await HiveHilfe.hinzufuegen(neu);
          await ladeKletterwege();
        },
      ),
    );
    aktualisieren(() {});
  }

  // Änderungen speichern
  Future<void> speichereAenderungen() async {
    for (var map in eintraegeNachDatumGebietGipfel.values) {
      for (var liste in map.values) {
        for (var e in liste) {
          final c = controllers[e.key];
          if (c != null && c['combined'] != null) {
            final text = c['combined']!.text.trim();
            final match = RegExp(r"^(.*) \((.*)\)$").firstMatch(text);
            if (match != null) {
              e.weg = match.group(1)!.trim();
              e.schwierigkeit = match.group(2)!.trim();
            } else {
              e.weg = text;
              e.schwierigkeit = "";
            }
            await HiveHilfe.aktualisieren(e);
          }
        }
      }
    }
    await ladeKletterwege();
    aktualisieren(() {});
  }

  // Auswahl löschen
  Future<void> loeschenAusgewaehlte() async {
    for (var key in ausgewaehlteKeys) {
      final gipfelMap = eintraegeNachDatumGebietGipfel[key]!;
      for (var wege in gipfelMap.values) {
        for (var e in wege) {
          await HiveHilfe.loeschen(e);
        }
      }
    }
    ausgewaehlteKeys.clear();
    loeschModus = false;
    await ladeKletterwege();
    aktualisieren(() {});
  }

  // Filter anzeigen
  void zeigeFilterDialog(BuildContext context) async {
    final value = await showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(100, 80, 0, 0),
      items: const [
        PopupMenuItem(value: "alle", child: Text("Alle anzeigen")),
        PopupMenuItem(value: "datum", child: Text("Datum")),
        PopupMenuItem(value: "gebiet", child: Text("Gebiet")),
        PopupMenuItem(value: "gipfel", child: Text("Gipfel")),
        PopupMenuItem(value: "weg", child: Text("Weg")),
        PopupMenuItem(value: "schwierigkeit", child: Text("Schwierigkeit")),
      ],
    );

    if (value == null) return; // Abbruch, wenn nichts gewählt

    if (value == "alle") {
      await filterZuruecksetzen();
    } else {
      oeffneKategorieFilterDialog(value, context);
    }
  }

  Future<void> filterZuruecksetzen() async {
    filterMap.updateAll((key, value) => null);
    await ladeKletterwege();
  }

  void oeffneKategorieFilterDialog(String category, BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => KletterwegEinzelFilterDialog(
        filterKategorie: category,
        beimAnwenden: (filterData) async {
          filterMap[category] = filterData[category]; // Filterwert speichern
          await ladeKletterwege(); // Einträge neu laden & filtern
          Navigator.of(ctx).pop();
        },
      ),
    );
  }
}
