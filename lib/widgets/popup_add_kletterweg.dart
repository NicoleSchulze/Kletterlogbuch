import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/kletterweg_datenmodell.dart';

/// --- Dialog zum Hinzufügen eines neuen Kletterwegs ---
//Callback-Funktion, die aufgerufen wird, wenn der Benutzer speichert
class AddKletterwegDialog extends StatefulWidget {
  final Function(KletterEintrag) onSave;

  const AddKletterwegDialog({super.key, required this.onSave});

  @override
  State<AddKletterwegDialog> createState() => _AddKletterwegDialogState();
}

// --- State für den Dialog ---
// Variablen für die Eingaben des Benutzers
// Speichert die Benutzereingaben temporär
class _AddKletterwegDialogState extends State<AddKletterwegDialog> {
  String datum = "";
  String gebiet = "";
  String gipfel = "";
  String weg = "";
  String schwierigkeit = "";

  String? datumError;
  String? gebietError;
  String? gipfelError;
  String? wegError;
  String? schwierigkeitError;

  final TextEditingController _datumController = TextEditingController();

// --- Konstanten für einheitliches Layout ---
  static const double fieldHeight = 65;  // Höhe für alle Felder
  static const double fieldSpacing = 2;  // Abstand zwischen Feldern

  // Liste Gebiete
  final List<String> gebieteListe = [
    "Erzgebirgsgrenzgebiet",
    "Bielatal",
    "Gebiet der Steine",
    "Wehlen",
    "Rathen",
    "Brand",
    "Schrammsteine",
    "Affensteine",
    "Schmilka",
    "Wildenstein",
    "Kleiner Zschand",
    "Großer Zschand",
    "Hinterhermsdorf",
  ];

  // Schwierigkeit in römischen Zahlen direkt
  final List<String> schwierigkeitenListe = [
    "I", "II", "III", "IV", "V", "VI", "VIIa", "VIIb", "VIIc", "VIIIa", "VIIIb", "VIIIc",
    "IXa", "IXb", "IXc", "Xa", "Xb", "Xc", "XIa", "XIb", "XIc",
  ];

  // Prüfen aller Pflichtfelder und Speichern
  void validateAndSave() {
    setState(() {
      datumError = datum.isEmpty ? "Bitte Datum auswählen" : null;
      gebietError = gebiet.isEmpty ? "Bitte Gebiet wählen" : null;
      gipfelError = gipfel.isEmpty ? "Bitte Gipfel eingeben" : null;
      wegError = weg.isEmpty ? "Bitte Weg eingeben" : null;
      schwierigkeitError = schwierigkeit.isEmpty ? "Bitte Schwierigkeit wählen" : null;
    });

    if ([datum, gebiet, gipfel, weg, schwierigkeit].any((e) => e.isEmpty))
      return;

    widget.onSave(
      KletterEintrag(
        datum: datum,
        gebiet: gebiet,
        gipfel: gipfel,
        weg: weg,
        schwierigkeit: schwierigkeit,
      ),
    );
    Navigator.pop(context);
  }

  // Datumsauswahl mit DatePicker
  Future<void> pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        datum =
            "${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}";
        _datumController.text = datum;
        datumError = null; // Fehler entfernen, sobald Datum gewählt
      });
    }
  }

  Widget buildTextField({
    required String label,
    required String value,
    required Function(String) onChanged,
    required String? errorText,
    int maxLength = 30,
    RegExp? allowedPattern,
  }) {
    return TextField(
      decoration: InputDecoration(labelText: label, errorText: errorText),
      maxLength: maxLength,
      inputFormatters: allowedPattern != null
          ? [FilteringTextInputFormatter.allow(allowedPattern)]
          : [],
      buildCounter:
          (
            BuildContext context, {
            required int currentLength,
            required bool isFocused,
            required int? maxLength,
          }) {
            return Text(
              "$currentLength/$maxLength",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            );
          },
      onChanged: onChanged,
    );
  }

  //Inhalt Dialog/Overlay
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Neuen Eintrag hinzufügen"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Datum
            SizedBox(
              height: fieldHeight,
              child: TextField(
                controller: _datumController,
                readOnly: true,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  labelText: "Datum",
                  errorText: datumError,
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                onTap: pickDate,
              ),
            ),
            SizedBox(height: fieldSpacing),

            // Gebiet Dropdown
            SizedBox(
              height: fieldHeight,
              child: DropdownButtonFormField<String>(
                value: gebiet.isEmpty ? null : gebiet,
                decoration: InputDecoration(labelText: "Gebiet", errorText: gebietError),
                items: gebieteListe.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (val) => setState(() => gebiet = val ?? ""),
              ),
            ),
            SizedBox(height: fieldSpacing),

            // Gipfel
            buildTextField(
              label: "Gipfel",
              value: gipfel,
              maxLength: 30,
              allowedPattern: RegExp(r'[a-zA-ZäöüÄÖÜß\s]'),
              errorText: gipfelError,
              onChanged: (val) => setState(() {
                gipfel = val;
                gipfelError = val.isEmpty ? "Bitte Gipfel eingeben" : null;
              }),
            ),
            SizedBox(height: fieldSpacing),

            // Weg
            buildTextField(
              label: "Weg",
              value: weg,
              maxLength: 30,
              allowedPattern: RegExp(r'[a-zA-ZäöüÄÖÜß\s\-]'),
              errorText: wegError,
              onChanged: (val) => setState(() {
                weg = val;
                wegError = val.isEmpty ? "Bitte Weg eingeben" : null;
              }),
            ),
            SizedBox(height: fieldSpacing),

            // Schwierigkeit Dropdown
            SizedBox(
              height: fieldHeight,
              child: DropdownButtonFormField<String>(
                value: schwierigkeit.isEmpty ? null : schwierigkeit,
                decoration: InputDecoration(labelText: "Schwierigkeit", errorText: schwierigkeitError),
                items: schwierigkeitenListe.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) {
                  setState(() {
                    schwierigkeit = val ?? "";
                    schwierigkeitError = null;
                  });
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Abbrechen")),
        ElevatedButton(onPressed: validateAndSave, child: const Text("Speichern")),
      ],
    );
  }
}