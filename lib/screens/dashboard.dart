import 'package:flutter/material.dart';
import '../../modelle/klettereintrag.dart';
import '../../screens/widgets/dialog_neuer_weg.dart';
import '../datenbank/hive_hilfe.dart';
import '../../screens/widgets/dialog_filter.dart';
import 'package:google_fonts/google_fonts.dart';

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

  bool _editMode = false;
  final Map<int, Map<String, TextEditingController>> _controllers = {};

  bool _deleteMode = false; // true, wenn Auswahlmodus aktiv
  Set<String> _selectedDatumGebietKeys = {}; // markierte Cards (Datum + Gebiet)

  @override
  void initState() {
    super.initState();
    _loadKletterwege(); // Daten beim Start laden
  }

  /// Alle Kletterwege aus der Datenbank laden
  Future<void> _loadKletterwege() async {
    final eintraegeListe = HiveHilfe.alle();

    // Gefilterte Liste anhand _filterMap
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

    // Map aufbauen für ListView
    Map<String, Map<String, List<KletterEintrag>>> tempMap = {};
    for (var eintrag in gefiltert) {
      final keyDatumGebiet = "${eintrag.datum} – ${eintrag.gebiet}";
      final keyGipfel = eintrag.gipfel;

      tempMap.putIfAbsent(keyDatumGebiet, () => {});
      tempMap[keyDatumGebiet]!.putIfAbsent(keyGipfel, () => []);
      tempMap[keyDatumGebiet]![keyGipfel]!.add(eintrag);

      // Controller nur einmalig anlegen
      if (!_controllers.containsKey(eintrag.key)) {
        _controllers[eintrag.key] = {
          'weg': TextEditingController(text: eintrag.weg),
          'schwierigkeit': TextEditingController(text: eintrag.schwierigkeit),
        };
      }
    }

    // Sortieren nach Datum absteigend
    final sortedKeys = tempMap.keys.toList()
      ..sort((a, b) {
        final dateA = DateTime.parse(a.split(' – ')[0].split('.').reversed.join('-'));
        final dateB = DateTime.parse(b.split(' – ')[0].split('.').reversed.join('-'));
        return dateB.compareTo(dateA);
      });

    final sortedMap = { for (var k in sortedKeys) k: tempMap[k]! };

    // In setState einfügen, damit UI neu baut
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
          await HiveHilfe.hinzufuegen(neuerEintrag);
          _loadKletterwege();
        },
      ),
    );
  }

  /// Filterungen
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9EB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF587C47),
        title: Text(
          "Dashboard",
          style: GoogleFonts.openSans(
            color: const Color(0xFFF1ECD7),
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
        actions: [
          Tooltip(
            message: "Filtermenü anzeigen",
            child: IconButton(
              icon: const Icon(Icons.filter_list),
              color: Color(0xFFF1ECD7),
              onPressed: () {
                showMenu<String>(
                  context: context,
                  position: RelativeRect.fromLTRB(100, 80, 0, 0),
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
          ),
          IconButton(
            icon: Icon(_editMode ? Icons.check : Icons.edit),
            color: Color(0xFFF1ECD7),
            tooltip: _editMode ? "Bearbeitung speichern" : "Einträge bearbeiten",
            onPressed: _deleteMode
                ? null
                : () async {
              if (_editMode) {
                // Änderungen speichern
                for (var keyDatumGebiet in _eintraegeNachDatumGebietGipfel.keys) {
                  final gipfelMap = _eintraegeNachDatumGebietGipfel[keyDatumGebiet]!;

                  for (var gipfel in gipfelMap.keys) {
                    final wegeListe = gipfelMap[gipfel]!;

                    for (var eintrag in wegeListe) {
                      // Text aus Controllern übernehmen (Weg + Schwierigkeit)
                      final controllerSet = _controllers[eintrag.key];
                      if (controllerSet != null) {
                        eintrag.weg = controllerSet['weg']!.text.trim();
                        eintrag.schwierigkeit = controllerSet['schwierigkeit']!.text.trim();
                      }

                      await HiveHilfe.aktualisieren(eintrag);
                    }
                  }
                }

                _loadKletterwege();
              }
              setState(() => _editMode = !_editMode);
            },
          ),
          IconButton(
            icon: Icon(_deleteMode ? Icons.check : Icons.delete),
            color: Color(0xFFF1ECD7),
            tooltip: _deleteMode
                ? (_selectedDatumGebietKeys.isEmpty
                ? "Keine Auswahl, Löschmodus beenden"
                : "Ausgewählte Einträge löschen")
                : (_editMode
                ? "Bearbeiten aktiv — Löschen nicht möglich"
                : "Einträge auswählen zum Löschen"),
            onPressed: _editMode
                ? null // 🔒 deaktiviert, wenn Bearbeitungsmodus aktiv
                : () async {
              if (_deleteMode) {
                if (_selectedDatumGebietKeys.isEmpty) {
                  setState(() => _deleteMode = false);
                  return;
                }

                // markierte Einträge löschen
                for (var key in _selectedDatumGebietKeys) {
                  final gipfelMap = _eintraegeNachDatumGebietGipfel[key]!;
                  for (var wege in gipfelMap.values) {
                    for (var eintrag in wege) {
                      await HiveHilfe.loeschen(eintrag);
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
                    elevation: 2,                    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadowColor: const Color(0xFF60594A).withValues(alpha: 0.4),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFEADABD)
                            : const Color(0xFFF1E8D7), // angepasste helle Cremefarbe
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF60594A).withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Zahl vorne
                              Text(
                                "$tagNummer) ",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF60594A),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: TextEditingController(
                                    text: "${datumUndGebiet.replaceFirst(' – ', ': ')}",
                                  ),
                                  enabled: _editMode,
                                  maxLines: null,
                                  minLines: 1,
                                  maxLength: 30,
                                  buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF60594A),
                                    height: 1.0,
                                  ),
                                  onChanged: (v) {
                                    if (_editMode) {
                                      final parts = v.split(':');
                                      if (parts.length == 2) {
                                        final datum = parts[0].trim();
                                        final gebiet = parts[1].trim();
                                        for (var wegeListe in gipfelMap.values) {
                                          for (var eintrag in wegeListe) {
                                            eintrag.datum = datum;
                                            eintrag.gebiet = gebiet;
                                          }
                                        }
                                      }
                                    }
                                  },
                                ),
                              ),
                            ],
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
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.filter_hdr, color: Color(0xFF60594A), size: 18),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Builder(builder: (context) {
                                          if (!_controllers.containsKey(gipfel.hashCode)) {
                                            _controllers[gipfel.hashCode] = {
                                              'gipfel': TextEditingController(text: gipfel),
                                            };
                                          }

                                          return TextField(
                                            controller: _controllers[gipfel.hashCode]!['gipfel'],
                                            enabled: _editMode,
                                            maxLines: null,
                                            minLines: 1,
                                            maxLength: 30,
                                            buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              isDense: true,
                                              contentPadding: EdgeInsets.symmetric(vertical: 2),
                                            ),
                                            style: const TextStyle(
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF60594A),
                                              height: 1.0,
                                            ),
                                            onChanged: (v) {
                                              if (_editMode) {
                                                for (var eintrag in wege) {
                                                  eintrag.gipfel = v;
                                                }
                                              }
                                            },
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                  ...wege.map((eintrag) {
                                    // Controller für Weg + Schwierigkeit anlegen, falls noch nicht vorhanden
                                    _controllers.putIfAbsent(eintrag.key, () => {});
                                    if (!_controllers[eintrag.key]!.containsKey('combined')) {
                                      _controllers[eintrag.key]!['combined'] =
                                          TextEditingController(text: "${eintrag.weg} (${eintrag.schwierigkeit})");
                                    }

                                    final combinedController = _controllers[eintrag.key]!['combined']!;

                                    return Padding(
                                      padding: const EdgeInsets.only(left: 22, top: 1),
                                      child: Row(
                                        children: [
                                          const Text("→ ", style: TextStyle(fontSize: 13.5, color: Color(0xFF60594A))),

                                          // IntrinsicWidth, damit Weg + Schwierigkeit nebeneinander bleiben
                                          Expanded(
                                            child: TextField(
                                              controller: combinedController,
                                              enabled: _editMode,
                                              maxLines: null,
                                              minLines: 1,
                                              maxLength: 30,
                                              buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                                              decoration: const InputDecoration(
                                                border: InputBorder.none,
                                                isDense: true,
                                                contentPadding: EdgeInsets.zero,
                                              ),
                                              style: const TextStyle(
                                                fontSize: 13.5,
                                                color: Color(0xFF60594A),
                                                height: 1.0,
                                              ),
                                              onChanged: (v) {
                                                final match = RegExp(r"^(.*) \((.*)\)$").firstMatch(v);
                                                if (match != null) {
                                                  eintrag.weg = match.group(1)!.trim();
                                                  eintrag.schwierigkeit = match.group(2)!.trim();
                                                } else {
                                                  eintrag.weg = v.trim();
                                                  eintrag.schwierigkeit = "";
                                                }
                                              },
                                            ),
                                          ),
                                        ],
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
        backgroundColor: const Color(0xFF587C47), // warmes dunkles Grün
        foregroundColor: const Color(0xFFF1ECD7), // helles Creme für das Icon
        elevation: 4,
        onPressed: _addKletterweg,
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}