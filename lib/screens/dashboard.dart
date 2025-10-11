import 'package:flutter/material.dart';
import '../models/kletterweg_datenmodell.dart';
import '../widgets/popup_add_kletterweg.dart';
import '../database/hive_database_helper.dart';
import '../widgets/popup_einzel_filter.dart';

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
  Map<String, dynamic> _filterMap = {
    "datum": null,
    "gebiet": null,
    "gipfel": null,
    "weg": null,
    "schwierigkeit": null,
  };

  // Map für gruppierte Anzeige nach Datum + Gebiet
  Map<String, Map<String, List<KletterEintrag>>> _eintraegeNachDatumGebietGipfel = {};

  bool _deleteMode = false; // true, wenn Auswahlmodus aktiv
  Set<String> _selectedDatumGebietKeys = {}; // markierte Cards (Datum + Gebiet)

  @override
  void initState() {
    super.initState();
    _loadKletterwege(); // Daten beim Start laden
  }

  /// Alle Kletterwege aus der Datenbank laden
  Future<void> _loadKletterwege() async {
    final eintraegeListe = HiveDatabaseHelper.queryAllKletterEintraege();

    // 1️⃣ Gefilterte Liste anhand _filterMap
    final gefiltert = eintraegeListe.where((e) {
      bool match = true;

      if (_filterMap["datum"] != null && _filterMap["datum"]!.isNotEmpty)
        match &= e.datum == _filterMap["datum"];
      if (_filterMap["gebiet"] != null && _filterMap["gebiet"]!.isNotEmpty)
        match &= e.gebiet == _filterMap["gebiet"];
      if (_filterMap["gipfel"] != null && _filterMap["gipfel"]!.isNotEmpty)
        match &= e.gipfel.contains(_filterMap["gipfel"]!);
      if (_filterMap["weg"] != null && _filterMap["weg"]!.isNotEmpty)
        match &= e.weg.contains(_filterMap["weg"]!);
      if (_filterMap["schwierigkeit"] != null && _filterMap["schwierigkeit"]!.isNotEmpty)
        match &= e.schwierigkeit == _filterMap["schwierigkeit"];

      return match;
    }).toList();

    // 2️⃣ Map aufbauen für ListView
    Map<String, Map<String, List<KletterEintrag>>> tempMap = {};
    for (var eintrag in gefiltert) {
      final keyDatumGebiet = "${eintrag.datum} – ${eintrag.gebiet}";
      final keyGipfel = eintrag.gipfel;

      tempMap.putIfAbsent(keyDatumGebiet, () => {});
      tempMap[keyDatumGebiet]!.putIfAbsent(keyGipfel, () => []);
      tempMap[keyDatumGebiet]![keyGipfel]!.add(eintrag);
    }

    // 3️⃣ Sortieren nach Datum absteigend
    final sortedKeys = tempMap.keys.toList()
      ..sort((a, b) {
        final dateA = DateTime.parse(a.split(' – ')[0].split('.').reversed.join('-'));
        final dateB = DateTime.parse(b.split(' – ')[0].split('.').reversed.join('-'));
        return dateB.compareTo(dateA);
      });

    final sortedMap = { for (var k in sortedKeys) k: tempMap[k]! };

    // 4️⃣ In setState einfügen, damit UI neu baut
    setState(() {
      _eintraegeNachDatumGebietGipfel.clear();
      _eintraegeNachDatumGebietGipfel.addAll(sortedMap);
    });
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

  /// Filterungen
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Dashboard", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(_deleteMode ? Icons.check : Icons.delete),
            tooltip: _deleteMode
                ? (_selectedDatumGebietKeys.isEmpty ? "Keine Auswahl, Löschmodus beenden" : "Ausgewählte Einträge löschen")
                : "Einträge auswählen zum Löschen",
            onPressed: () async {
              if (_deleteMode) {
                if (_selectedDatumGebietKeys.isEmpty) {
                  setState(() => _deleteMode = false);
                  return;
                }
                for (var key in _selectedDatumGebietKeys) {
                  final gipfelMap = _eintraegeNachDatumGebietGipfel[key]!;
                  for (var wege in gipfelMap.values) {
                    for (var eintrag in wege) {
                      await HiveDatabaseHelper.deleteKletterEintrag(eintrag);
                    }
                  }
                }
                _selectedDatumGebietKeys.clear();
                setState(() => _deleteMode = false);
                _loadKletterwege();
              } else {
                setState(() {
                  _deleteMode = true;
                  _selectedDatumGebietKeys.clear();
                });
              }
            },
          ),
          Tooltip(
            message: "Filtermenü anzeigen",
            child: IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                showMenu<String>(
                  context: context,
                  position: RelativeRect.fromLTRB(100, 80, 0, 0), // Position über dem Icon anpassen
                  items: const [
                    PopupMenuItem(value: "alle", child: Text("Alle anzeigen")),
                    PopupMenuItem(value: "datum", child: Text("Datum")),
                    PopupMenuItem(value: "gebiet", child: Text("Gebiet")),
                    PopupMenuItem(value: "gipfel", child: Text("Gipfel")),
                    PopupMenuItem(value: "weg", child: Text("Weg")),
                    PopupMenuItem(value: "schwierigkeit", child: Text("Schwierigkeit")),
                  ],
                ).then((value) {
                  if (value == null) return;

                  if (value == "alle") {
                    setState(() => _filterMap.updateAll((key, value) => null));
                    _loadKletterwege();
                  } else {
                    showDialog(
                      context: context,
                      builder: (_) => KletterwegEinzelFilterDialog(
                        filterKategorie: value,
                        onApply: (filterMap) {
                          setState(() => _filterMap = filterMap);
                          _loadKletterwege();
                        },
                      ),
                    );
                  }
                });
              },
            ),
          )
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
                final tagNummer = _eintraegeNachDatumGebietGipfel.keys.length - index;
                final isSelected = _selectedDatumGebietKeys.contains(datumUndGebiet);

                return InkWell(
                  onTap: _deleteMode
                      ? () {
                    setState(() {
                      if (isSelected) {
                        _selectedDatumGebietKeys.remove(datumUndGebiet);
                      } else {
                        _selectedDatumGebietKeys.add(datumUndGebiet);
                      }
                    });
                  }
                      : null,
                  child: Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.green.withOpacity(0.2) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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