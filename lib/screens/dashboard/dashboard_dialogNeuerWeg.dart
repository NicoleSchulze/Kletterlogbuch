import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kletterlogbuch/konstanten/fehlermeldungen.dart';
import 'package:flutter_kletterlogbuch/modelle/klettereintrag.dart';

/// ============================================================
/// Dialog zum Hinzufügen eines neuen Kletterwegs
/// ============================================================
/// Stellt ein Formular bereit, in dem der Benutzer:
/// - Datum wählt
/// - Gebiet aus einer Liste auswählt
/// - Gipfel und Weg eingibt
/// - Schwierigkeit auswählt
/// Validierung erfolgt vor speichern
/// ============================================================

class DialogNeuerKletterweg extends StatefulWidget {
  final Function(KletterEintrag) beimSpeichern;
  const DialogNeuerKletterweg({super.key, required this.beimSpeichern});

  @override
  State<DialogNeuerKletterweg> createState() => _DialogNeuerKletterwegState();
}

class _DialogNeuerKletterwegState extends State<DialogNeuerKletterweg> {
  // ----------------------------
  // Benutzereingaben
  // ----------------------------
  String datum = "";
  String gebiet = "";
  String gipfel = "";
  String weg = "";
  String schwierigkeit = "";

  // Fehlertexte für Validierung
  String? datumFehler;
  String? gebietFehler;
  String? gipfelFehler;
  String? wegFehler;
  String? schwierigkeitFehler;

  final TextEditingController _datumController = TextEditingController();

  // ----------------------------
  // Auswahlmöglichkeiten
  // ----------------------------
  final List<String> gebieteListe = [
    "Erzgebirgsgrenzgebiet", "Bielatal", "Gebiet der Steine", "Wehlen", "Rathen",
    "Brand", "Schrammsteine", "Affensteine", "Schmilka", "Wildenstein",
    "Kleiner Zschand", "Großer Zschand", "Hinterhermsdorf",
  ];

  // Schwierigkeit in römischen Zahlen direkt
  final List<String> schwierigkeitenListe = [
    "I", "II", "III", "IV", "V", "VI", "VIIa", "VIIb", "VIIc", "VIIIa", "VIIIb", "VIIIc",
    "IXa", "IXb", "IXc", "Xa", "Xb", "Xc", "XIa", "XIb", "XIc",
  ];

  // ----------------------------
  // Validierung und Speichern
  // ----------------------------
  void validierenUndSpeichern() {
    setState(() {
      datumFehler = datum.isEmpty ? FilterFehler.fehlermeldungDatum : null;
      gebietFehler = gebiet.isEmpty ? FilterFehler.fehlermeldungGebiet : null;
      gipfelFehler = gipfel.isEmpty ? FilterFehler.fehlermeldungGipfel : null;
      wegFehler = weg.isEmpty ? FilterFehler.fehlermeldungWeg : null;
      schwierigkeitFehler = schwierigkeit.isEmpty ? FilterFehler.fehlermeldungSchwierigkeit : null;
    });

    if ([datum, gebiet, gipfel, weg, schwierigkeit].any((e) => e.isEmpty)) return;

    // Callback aufrufen, Dialog schließen
    widget.beimSpeichern(
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

  // ----------------------------
  // Datumsauswahl
  // ----------------------------
  Future<void> datumWaehlen() async {
    final DateTime? ausgewaehltesDatum = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (ausgewaehltesDatum != null) {
      setState(() {
        datum = "${ausgewaehltesDatum.day.toString().padLeft(2, '0')}.${ausgewaehltesDatum.month.toString().padLeft(2, '0')}.${ausgewaehltesDatum.year}";
        _datumController.text = datum;
        datumFehler = null; // Fehler entfernen, sobald Datum gewählt
      });
    }
  }

  // ----------------------------
  // Hilfsmethode: Textfelder bauen
  // ----------------------------
  Widget baueTextFeld({
    required String label,
    required String value,
    required Function(String) onChanged,
    required String? fehlerText,
    int maxLaenge = 30,
    RegExp? erlaubtesPattern,
  }) {
    return TextField(
      decoration: InputDecoration(labelText: label, errorText: fehlerText),
      maxLength: maxLaenge,
      inputFormatters: erlaubtesPattern != null ? [FilteringTextInputFormatter.allow(erlaubtesPattern)] : [],
      buildCounter: (BuildContext context, {
        required int currentLength,
        required bool isFocused,
        required int? maxLength,
      }) => Text("$currentLength/$maxLength", style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      onChanged: onChanged,
    );
  }

  // ----------------------------
  // Build-Methode Dialog
  // ----------------------------
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
              height: 65,
              child: TextField(
                controller: _datumController,
                readOnly: true,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  labelText: "Datum",
                  errorText: datumFehler,
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                onTap: datumWaehlen,
              ),
            ),
            SizedBox(height: 8),

            // Gebiet
            SizedBox(
              height: 65,
              child: DropdownButtonFormField<String>(
                value: gebiet.isEmpty ? null : gebiet,
                decoration: InputDecoration(labelText: "Gebiet", errorText: gebietFehler),
                items: gebieteListe.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (val) => setState(() => gebiet = val ?? ""),
              ),
            ),
            SizedBox(height: 8),

            // Gipfel
            baueTextFeld(
              label: "Gipfel",
              value: gipfel,
              maxLaenge: 30,
              erlaubtesPattern: RegExp(r'[a-zA-ZäöüÄÖÜß\s]'),
              fehlerText: gipfelFehler,
              onChanged: (val) => setState(() {
                gipfel = val;
                gipfelFehler = val.isEmpty ? FilterFehler.fehlermeldungGipfel: null;
              }),
            ),
            SizedBox(height: 8),

            // Weg
            baueTextFeld(
              label: "Weg",
              value: weg,
              maxLaenge: 30,
              erlaubtesPattern: RegExp(r'[a-zA-ZäöüÄÖÜß\s\-]'),
              fehlerText: wegFehler,
              onChanged: (val) => setState(() {
                weg = val;
                wegFehler = val.isEmpty ? FilterFehler.fehlermeldungWeg : null;
              }),
            ),
            SizedBox(height: 8),

            // Schwierigkeit
            SizedBox(
              height: 65,
              child: DropdownButtonFormField<String>(
                value: schwierigkeit.isEmpty ? null : schwierigkeit,
                decoration: InputDecoration(labelText: "Schwierigkeit", errorText: schwierigkeitFehler),
                items: schwierigkeitenListe.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() {
                  schwierigkeit = val ?? "";
                  schwierigkeitFehler = null;
                }),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Abbrechen")),
        ElevatedButton(onPressed: validierenUndSpeichern, child: const Text("Speichern")),
      ],
    );
  }
}