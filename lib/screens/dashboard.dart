import 'package:flutter/material.dart';
import '../models/kletterweg.dart';
import '../widgets/add_kletterweg.dart';
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
  final List<Kletterweg> _wege = [];
  String _filter = "Alle";

  @override
  void initState() {
    super.initState();
    _loadKletterwege(); // Daten beim Start laden
  }

  /// Alle Kletterwege aus der Datenbank laden
  Future<void> _loadKletterwege() async {
    final data = await DatabaseHelper.instance.queryAllKletterwege();
    setState(() {
      _wege.clear();
      _wege.addAll(data.map((e) => Kletterweg.fromMap(e)));
    });
  }

  /// Kletterwege hinzufügen
  // Methode des States (zum Hinzufügen eines Kletterwegs)
  void _addKletterweg() {
    showDialog(
      context: context,
      builder: (context) => AddKletterwegDialog(
        onSave: (neuerWeg) async {
          await DatabaseHelper.instance.insertKletterweg(neuerWeg.toMap());
          _loadKletterwege(); // Liste aktualisieren
        },
      ),
    );
  }

  /// Kletterweg bearbeiten
  Future<void> _editKletterweg(Kletterweg weg) async {
    final datumController = TextEditingController(text: weg.datum);
    final gebietController = TextEditingController(text: weg.gebiet);
    final gipfelController = TextEditingController(text: weg.gipfel);
    final wegController = TextEditingController(text: weg.weg);
    final schwierigkeitController = TextEditingController(
      text: weg.schwierigkeit,
    );

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
                final updatedWeg = Kletterweg(
                  id: weg.id,
                  // wichtig fürs Update
                  datum: datumController.text,
                  gebiet: gebietController.text,
                  gipfel: gipfelController.text,
                  weg: wegController.text,
                  schwierigkeit: schwierigkeitController.text,
                );

                await DatabaseHelper.instance.updateKletterweg(
                  updatedWeg.toMap(),
                );
                Navigator.of(context).pop();
                _loadKletterwege(); // Liste aktualisieren
              },
              child: const Text("Speichern"),
            ),
          ],
        );
      },
    );
  }

  /// Kletterweg löschen
  Future<void> _deleteKletterweg(int id) async {
    await DatabaseHelper.instance.deleteKletterweg(id);
    _loadKletterwege();
  }

  //
  @override
  Widget build(BuildContext context) {
    // Gefilterte Liste erstellen: entweder alle Wege oder nur passende Schwierigkeit
    final gefilterteWege = _filter == "Alle"
        ? _wege
        : _wege.where((weg) => weg.schwierigkeit == _filter).toList();

    // Grundgerüst der Seite
    return Scaffold(
      appBar: AppBar(
        // obere Leiste
        backgroundColor: Colors.green,
        title: const Text("Dashboard", style: TextStyle(color: Colors.white)),
        actions: [
          // rechts: Filter Icon
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filter = value;
              });
            },
            itemBuilder: (context) => const [
              // Auswahlmöglichkeiten für Filter
              PopupMenuItem(value: "Alle", child: Text("Alle")),
              PopupMenuItem(value: "5a", child: Text("5a")),
              PopupMenuItem(value: "6a", child: Text("6a")),
              PopupMenuItem(value: "7a", child: Text("7a")),
            ],
          ),
        ],
      ),
      body:
          gefilterteWege
              .isEmpty // Prüfen, ob Liste leer ist
          ? const Center(child: Text("Noch keine Einträge"))
          : ListView.builder(
              itemCount: gefilterteWege.length,
              itemBuilder: (context, index) {
                final weg = gefilterteWege[index];
                return ListTile(
                  leading: const Icon(Icons.terrain),
                  title: Text("${weg.datum} (${weg.schwierigkeit})"),
                  subtitle: Text(weg.weg),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ✏️ Bearbeiten-Button
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editKletterweg(weg),
                      ),
                      // 🗑️ Löschen-Button
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteKletterweg(weg.id!),
                      ),
                    ],
                  ),
                );
              },
            ),
      // Button + rechts unten
      floatingActionButton: FloatingActionButton(
        onPressed: _addKletterweg,
        child: const Icon(Icons.add),
      ),
    );
  }
}
