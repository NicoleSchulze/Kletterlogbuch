import 'package:flutter/material.dart';
import 'package:flutter_kletterlogbuch/konstanten/fehlermeldungen.dart';

/// ============================================================
/// Kletterweg Filter
/// ============================================================
/// Funktionalität:
/// - Zeigt ein passendes Eingabefeld basierend auf `filterKategorie`
///   (Datum, Gebiet, Gipfel, Weg, Schwierigkeit)
/// - Validiert die Eingabe und zeigt ggf. Fehlertexte an
/// ============================================================

class KletterwegEinzelFilterDialog extends StatefulWidget {
  final String filterKategorie;
  final Function(Map<String, dynamic>) onApply;

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

  // Fehlertexte für Validierung
  String? datumError;
  String? gebietError;
  String? gipfelError;
  String? wegError;
  String? schwierigkeitError;

  // ----------------------------
  // Auswahlmöglichkeiten
  // ----------------------------
  final List<String> gebieteListe = [
    "Erzgebirgsgrenzgebiet", "Bielatal", "Gebiet der Steine", "Wehlen",
    "Rathen", "Brand", "Schrammsteine", "Affensteine", "Schmilka",
    "Wildenstein", "Kleiner Zschand", "Großer Zschand", "Hinterhermsdorf"
  ];

  final List<String> schwierigkeitenListe = [
    "I", "II", "III", "IV", "V", "VI", "VIIa", "VIIb", "VIIc", "VIIIa",
    "VIIIb", "VIIIc", "IXa", "IXb", "IXc", "Xa", "Xb", "Xc", "XIa", "XIb", "XIc"
  ];

  // ----------------------------
  // Datumsauswahl
  // ----------------------------
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
        datumError = null; // Fehler entfernen, sobald Datum gewählt
      });
    }
  }

  // ----------------------------
  // Filterfeld bauen
  // ----------------------------
  Widget buildFilterField() {
    switch (widget.filterKategorie) {
      case "datum":
        return TextField(
          controller: _datumController,
          readOnly: true,
          decoration: InputDecoration(
            labelText: "Datum",
            suffixIcon: const Icon(Icons.calendar_today),
            errorText: datumError,
          ),
          onTap: pickDate,
        );

      case "gebiet":
        return DropdownButtonFormField<String>(
          value: gebiet,
          decoration: InputDecoration(
            labelText: "Gebiet",
            errorText: gebietError,
          ),
          items: gebieteListe
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
          onChanged: (val) => setState(() {
            gebiet = val;
            gebietError = null;
          }),
        );

      case "schwierigkeit":
        return DropdownButtonFormField<String>(
          value: schwierigkeit,
          decoration: InputDecoration(
            labelText: "Schwierigkeit",
            errorText: schwierigkeitError,
          ),
          items: schwierigkeitenListe
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (val) => setState(() {
            schwierigkeit = val;
            schwierigkeitError = null;
          }),
        );

      case "gipfel":
        return TextField(
          maxLength: 30,
          decoration: InputDecoration(
            labelText: "Gipfel",
            errorText: gipfelError,
          ),
          onChanged: (val) => setState(() {
            gipfel = val;
            gipfelError = val.isEmpty ? FilterFehler.fehlermeldungGipfel : null;
          }),
        );

      case "weg":
        return TextField(
          maxLength: 30,
          decoration: InputDecoration(
            labelText: "Weg",
            errorText: wegError,
          ),
          onChanged: (val) => setState(() {
            weg = val;
            wegError = val.isEmpty ? FilterFehler.fehlermeldungWeg : null;
          }),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  // ----------------------------
  // Build-Methode
  // ----------------------------
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Filter auswählen"),
      content: SingleChildScrollView(child: buildFilterField()),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Abbrechen"),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              // Fehler zurücksetzen
              datumError =
                  gebietError = gipfelError = wegError = schwierigkeitError = null;

              switch (widget.filterKategorie) {
                case "datum":
                  if (datum == null || datum!.isEmpty) datumError = FilterFehler.fehlermeldungDatum;
                  break;
                case "gebiet":
                  if (gebiet == null || gebiet!.isEmpty) gebietError = FilterFehler.fehlermeldungGebiet;
                  break;
                case "gipfel":
                  if (gipfel == null || gipfel!.isEmpty) gipfelError = FilterFehler.fehlermeldungGipfel;
                  break;
                case "weg":
                  if (weg == null || weg!.isEmpty) wegError = FilterFehler.fehlermeldungWeg;
                  break;
                case "schwierigkeit":
                  if (schwierigkeit == null || schwierigkeit!.isEmpty) schwierigkeitError = FilterFehler.fehlermeldungSchwierigkeit;
                  break;
              }
            });

            // Wenn Fehler vorhanden → abbrechen
            if (datumError != null ||
                gebietError != null ||
                gipfelError != null ||
                wegError != null ||
                schwierigkeitError != null) {
              return;
            }

            // Filter anwenden
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