import 'package:flutter/material.dart';
import '../models/kletterweg_datenmodell.dart';
import '../widgets/popup_add_kletterweg.dart';
import '../database/database_helper.dart';

/// --- Dashboard (Kletterlogbuch) ---
// Neues Widget definieren
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  // Seitenaufbau, Welchen State nutzen?
  @override
  State<Dashboard> createState() => _DashboardState();
}

// Definition State
class _DashboardState extends State<Dashboard> {
  String _filter = "Alle";

  // Map für gruppierte Anzeige nach Datum + Gebiet
  Map<String, Map<String, List<KletterEintrag>>> _eintraegeNachDatumGebietGipfel = {};

  @override
  void initState() {
    super.initState();
    _loadKletterwege(); // Daten beim Start laden
  }

  /// Alle Kletterwege aus der Datenbank laden
  Future<void> _loadKletterwege() async {
    final data = await DatabaseHelper.instance.queryAllKletterEintraege();
    final eintraegeListe = data.map((e) => KletterEintrag.fromMap(e)).toList();

    _eintraegeNachDatumGebietGipfel.clear();

    for (var eintrag in eintraegeListe) {
      if (_filter != "Alle" && eintrag.schwierigkeit != _filter) continue;

      final keyDatumGebiet = "${eintrag.datum} – ${eintrag.gebiet}";
      final keyGipfel = eintrag.gipfel;

      // Map für Datum+Gebiet anlegen
      _eintraegeNachDatumGebietGipfel.putIfAbsent(keyDatumGebiet, () => {});
      final gipfelMap = _eintraegeNachDatumGebietGipfel[keyDatumGebiet]!;

      // Liste für Gipfel anlegen
      gipfelMap.putIfAbsent(keyGipfel, () => []);
      gipfelMap[keyGipfel]!.add(eintrag);
      }

    setState(() {}); // UI aktualisieren
  }

  /// Kletterwege hinzufügen
  // Methode des States (zum Hinzufügen eines Kletterwegs)
  void _addKletterweg() {
    showDialog(
      context: context,
      builder: (context) => AddKletterwegDialog(
        onSave: (KletterEintrag? neuerEintrag) async {
          if (neuerEintrag != null) {
            await DatabaseHelper.instance.insertKletterEintrag(
              neuerEintrag.toMap(),
            );
            _loadKletterwege();
          }
        },
      ),
    );
  }

  /// Kletterweg bearbeiten
  Future<void> _editKletterweg(KletterEintrag eintrag) async {
    final datumController = TextEditingController(text: eintrag.datum);

    final gebietController = TextEditingController(text: eintrag.gebiet);
    final gipfelController = TextEditingController(text: eintrag.gipfel);
    final wegController = TextEditingController(text: eintrag.weg);
    final schwierigkeitController = TextEditingController(text: eintrag.schwierigkeit);

    // Diaglogfester öffnet sich wieder, wie bei Erstellen
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Kletterweg bearbeiten"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: datumController,
                  decoration: const InputDecoration(labelText: "Datum"),
                ),
                TextField(
                  controller: gebietController,
                  decoration: const InputDecoration(labelText: "Gebiet"),
                ),
                TextField(
                  controller: gipfelController,
                  decoration: const InputDecoration(labelText: "Gipfel"),
                ),
                TextField(
                  controller: wegController,
                  decoration: const InputDecoration(labelText: "Weg"),
                ),
                TextField(
                  controller: schwierigkeitController,
                  decoration: const InputDecoration(labelText: "Schwierigkeit"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Abbrechen"),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedEintrag = KletterEintrag(
                  id: eintrag.id,
                  datum: datumController.text,
                  gebiet: gebietController.text,
                  gipfel: gipfelController.text,
                  weg: wegController.text,
                  schwierigkeit: schwierigkeitController.text,
                );

                await DatabaseHelper.instance.updateKletterEintrag(updatedEintrag.toMap());
                Navigator.of(context).pop();
                _loadKletterwege(); // aktualisieren
              },
              child: const Text("Speichern"),
            ),
          ],
        );
      },
    );
  }

  /// Kletterweg löschen
  Future<void> _deleteKletterEintrag(int id) async {
    await DatabaseHelper.instance.deleteKletterEintrag(id);
    _loadKletterwege();
  }

  /// Filterungen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Dashboard", style: TextStyle(color: Colors.white)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              _filter = value;
              _loadKletterwege(); // Filter anwenden
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: "Alle", child: Text("Alle")),
              PopupMenuItem(value: "5a", child: Text("5a")),
              PopupMenuItem(value: "6a", child: Text("6a")),
              PopupMenuItem(value: "7a", child: Text("7a")),
            ],
          ),
        ],
      ),
      body: _eintraegeNachDatumGebietGipfel.isEmpty
          ? const Center(child: Text("Noch keine Einträge"))
          : ListView(
        children: _eintraegeNachDatumGebietGipfel.entries.map((datumEntry) {
          final datumUndGebiet = datumEntry.key;
          final gipfelMap = datumEntry.value;

          return ExpansionTile(
            title: Text(datumUndGebiet),
            children: gipfelMap.entries.map((gipfelEntry) {
              final gipfel = gipfelEntry.key;
              final eintraege = gipfelEntry.value;

              return ExpansionTile(
                title: Text(gipfel),
                children: eintraege.map((eintrag) {
                  return ListTile(
                    title: Text("${eintrag.weg} (${eintrag.schwierigkeit})"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editKletterweg(eintrag),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteKletterEintrag(eintrag.id!),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addKletterweg,
        child: const Icon(Icons.add),
      ),
    );
  }
}