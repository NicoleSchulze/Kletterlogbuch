import 'package:flutter/material.dart';


class KletterwegEinzelFilterDialog extends StatefulWidget {
  final String filterKategorie; // NEU: sagt, welcher Filter geöffnet wird
  final Function(Map<String, dynamic>) onApply; // Callback für Filter

  const KletterwegEinzelFilterDialog({
    super.key,
    required this.filterKategorie,
    required this.onApply,
  });

  @override
  State<KletterwegEinzelFilterDialog> createState() => _KletterwegEinzelFilterDialogState();
}

class _KletterwegEinzelFilterDialogState extends State<KletterwegEinzelFilterDialog> {
  String? datum;
  String? gebiet;
  String? gipfel;
  String? weg;
  String? schwierigkeit;

  final TextEditingController _datumController = TextEditingController();

  // 👇 Fehlertexte für Validierung
  String? datumError;
  String? gebietError;
  String? gipfelError;
  String? wegError;
  String? schwierigkeitError;

  final List<String> gebieteListe = [
    "Erzgebirgsgrenzgebiet", "Bielatal", "Gebiet der Steine", "Wehlen",
    "Rathen", "Brand", "Schrammsteine", "Affensteine", "Schmilka",
    "Wildenstein", "Kleiner Zschand", "Großer Zschand", "Hinterhermsdorf"
  ];

  final List<String> schwierigkeitenListe = [
    "I", "II", "III", "IV", "V", "VI", "VIIa", "VIIb", "VIIc", "VIIIa",
    "VIIIb", "VIIIc", "IXa", "IXb", "IXc", "Xa", "Xb", "Xc", "XIa", "XIb", "XIc"
  ];


  // --- pickDate muss hier IN der State-Klasse ---
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
        "${picked.day.toString().padLeft(2, '0')}.${picked.month
            .toString()
            .padLeft(2, '0')}.${picked.year}";
        _datumController.text = datum!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    switch (widget.filterKategorie) {
      case "datum":
        content = TextField(
          controller: _datumController,
          readOnly: true,
          decoration: InputDecoration(
            labelText: "Datum",
            suffixIcon: const Icon(Icons.calendar_today),
            errorText: datumError,
          ),
            onTap: () async {
              await pickDate();
              setState(() {
                datumError = null; // Fehler entfernen, sobald Datum gewählt
              });
            }        );
        break;
      case "gebiet":
        content = DropdownButtonFormField<String>(
          value: gebiet,
          decoration: InputDecoration(
              labelText: "Gebiet",
              errorText: gebietError,
          ),
          items: gebieteListe.map((g) =>
              DropdownMenuItem(value: g, child: Text(g))).toList(),
          onChanged: (val) => setState(() {
            gebiet = val;
            gebietError = null; // Fehler entfernen
          }),
        );
        break;
      case "schwierigkeit":
        content = DropdownButtonFormField<String>(
          value: schwierigkeit,
          decoration: InputDecoration(
              labelText: "Schwierigkeit",
              errorText: schwierigkeitError
          ),
          items: schwierigkeitenListe.map((s) =>
              DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (val) => setState(() {
            schwierigkeit = val;
            schwierigkeitError = null; // Fehler entfernen
          }),        );
        break;
      case "gipfel":
        content = TextField(
          maxLength: 30,
          decoration: InputDecoration(
              labelText: "Gipfel",
              errorText: gipfelError),
          onChanged: (val) => setState(() {
            gipfel = val;
            gipfelError = val.isEmpty ? "Bitte Gipfel eingeben" : null;
          }),
        );
        break;
      case "weg":
        content = TextField(
          maxLength: 30,
          decoration: InputDecoration(
              labelText: "Weg",
              errorText: wegError),
          onChanged: (val) => setState(() {
            weg = val;
            wegError = val.isEmpty ? "Bitte Weg eingeben" : null;
          }),
        );
        break;
      default:
        content = const SizedBox.shrink();
    }

    return AlertDialog(
      title: const Text("Filter auswählen"),
      content: SingleChildScrollView(child: content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Abbrechen"),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              // Erst alle Fehler zurücksetzen
              datumError = gebietError = gipfelError = wegError = schwierigkeitError = null;

              switch (widget.filterKategorie) {
                case "datum":
                  if (datum == null || datum!.isEmpty) datumError = "Bitte Datum auswählen";
                  break;
                case "gebiet":
                  if (gebiet == null || gebiet!.isEmpty) gebietError = "Bitte Gebiet auswählen";
                  break;
                case "gipfel":
                  if (gipfel == null || gipfel!.isEmpty) gipfelError = "Bitte Gipfel eingeben";
                  break;
                case "weg":
                  if (weg == null || weg!.isEmpty) wegError = "Bitte Weg eingeben";
                  break;
                case "schwierigkeit":
                  if (schwierigkeit == null || schwierigkeit!.isEmpty || schwierigkeit == "Alle") {
                    schwierigkeitError = "Bitte Schwierigkeit auswählen";
                  }
                  break;
              }
            });

            // Wenn es irgendeinen Fehlertext gibt → abbrechen
            if (datumError != null ||
                gebietError != null ||
                gipfelError != null ||
                wegError != null ||
                schwierigkeitError != null) {
              return;
            }

            // Wenn Eingabe vorhanden → anwenden
            widget.onApply({
              "datum": datum,
              "gebiet": gebiet,
              "gipfel": gipfel,
              "weg": weg,
              "schwierigkeit": schwierigkeit,
            });

            Navigator.pop(context);
          },
          child: const Text("Anwenden"),
        ),
      ],
    );
  }
}