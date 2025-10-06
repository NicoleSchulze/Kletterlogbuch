import 'package:flutter/material.dart';
import '../models/kletterweg_datenmodell.dart';
import '../widgets/popup_add_kletterweg.dart';
import '../database/hive_database_helper.dart';

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
    final eintraegeListe = HiveDatabaseHelper.queryAllKletterEintraege();

    _eintraegeNachDatumGebietGipfel.clear();

    for (var eintrag in eintraegeListe) {
      final keyDatumGebiet = "${eintrag.datum} – ${eintrag.gebiet}";
      final keyGipfel = eintrag.gipfel;

      _eintraegeNachDatumGebietGipfel.putIfAbsent(keyDatumGebiet, () => {});
      _eintraegeNachDatumGebietGipfel[keyDatumGebiet]!
          .putIfAbsent(keyGipfel, () => [])
          .add(eintrag);
    }

    // Sortieren nach Datum absteigend (neueste zuerst)
    final sortedKeys = _eintraegeNachDatumGebietGipfel.keys.toList()
      ..sort((a, b) {
        final dateA = DateTime.parse(a.split(' – ')[0].split('.').reversed.join('-'));
        final dateB = DateTime.parse(b.split(' – ')[0].split('.').reversed.join('-'));
        return dateB.compareTo(dateA); // b.compareTo(a) für absteigend
      });

    final sortedMap = { for (var k in sortedKeys) k: _eintraegeNachDatumGebietGipfel[k]! };
    _eintraegeNachDatumGebietGipfel = sortedMap;

    setState(() {});
  }

  /// Kletterwege hinzufügen
  // Methode des States (zum Hinzufügen eines Kletterwegs)
  void _addKletterweg() {
    showDialog(
      context: context,
      builder: (context) => AddKletterwegDialog(
        onSave: (KletterEintrag neuerEintrag) async {
          await HiveDatabaseHelper.insertKletterEintrag(neuerEintrag);
          _loadKletterwege();
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

                await HiveDatabaseHelper.updateKletterEintrag(updatedEintrag);
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
  Future<void> _deleteKletterEintrag(KletterEintrag eintrag) async {
    await HiveDatabaseHelper.deleteKletterEintrag(eintrag);
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        children: [
          for (int index = 0; index < _eintraegeNachDatumGebietGipfel.keys.length; index++)
            Builder(
              builder: (context) {
                final datumUndGebiet = _eintraegeNachDatumGebietGipfel.keys.elementAt(index);
                final gipfelMap = _eintraegeNachDatumGebietGipfel[datumUndGebiet]!;

                // Nummerierung invertiert: ältester = 1, neuester = letzte Zahl
                final tagNummer = _eintraegeNachDatumGebietGipfel.keys.length - index;

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Datum + Gebiet mit Nummerierung
                        Text(
                          "$tagNummer) ${datumUndGebiet.replaceFirst(' – ', ': ')}",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...gipfelMap.entries.map((gipfelEntry) {
                          final gipfel = gipfelEntry.key;
                          final wege = gipfelEntry.value;

                          return Padding(
                            padding: const EdgeInsets.only(top: 4, left: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.filter_hdr, color: Colors.grey, size: 18),
                                    const SizedBox(width: 4),
                                    Text(
                                      gipfel,
                                      style: const TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                ...wege.map((eintrag) {
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 22, top: 1),
                                    child: Text(
                                      "→ ${eintrag.weg} (${eintrag.schwierigkeit})",
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addKletterweg,
        child: const Icon(Icons.add),
      ),
    );
  }
}