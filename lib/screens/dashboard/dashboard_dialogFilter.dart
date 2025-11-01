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
  final Function(Map<String, dynamic>) beimAnwenden;

  const KletterwegEinzelFilterDialog({
    super.key,
    required this.filterKategorie,
    required this.beimAnwenden,
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
  String? datumFehler;
  String? gebietFehler;
  String? gipfelFehler;
  String? wegFehler;
  String? schwierigkeitFehler;

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
  Future<void> datumWaehlen() async {
    final DateTime? ausgewaehltesDatum = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (ausgewaehltesDatum != null) {
      setState(() {
        datum =
        "${ausgewaehltesDatum.day.toString().padLeft(2, '0')}.${ausgewaehltesDatum.month
            .toString()
            .padLeft(2, '0')}.${ausgewaehltesDatum.year}";
        _datumController.text = datum!;
        datumFehler = null; // Fehler entfernen, sobald Datum gewählt
      });
    }
  }

  // ----------------------------
  // Filterfeld bauen
  // ----------------------------
  Widget baueFilterFeld() {
    switch (widget.filterKategorie) {
      case "datum":
        return TextField(
          controller: _datumController,
          readOnly: true,
          decoration: InputDecoration(
            labelText: "Datum",
            suffixIcon: const Icon(Icons.calendar_today),
            errorText: datumFehler,
          ),
          onTap: datumWaehlen,
        );

      case "gebiet":
        return DropdownButtonFormField<String>(
          value: gebiet,
          decoration: InputDecoration(
            labelText: "Gebiet",
            errorText: gebietFehler,
          ),
          items: gebieteListe
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
          onChanged: (val) => setState(() {
            gebiet = val;
            gebietFehler = null;
          }),
        );

      case "schwierigkeit":
        return DropdownButtonFormField<String>(
          value: schwierigkeit,
          decoration: InputDecoration(
            labelText: "Schwierigkeit",
            errorText: schwierigkeitFehler,
          ),
          items: schwierigkeitenListe
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (val) => setState(() {
            schwierigkeit = val;
            schwierigkeitFehler = null;
          }),
        );

      case "gipfel":
        return TextField(
          maxLength: 30,
          decoration: InputDecoration(
            labelText: "Gipfel",
            errorText: gipfelFehler,
          ),
          onChanged: (val) => setState(() {
            gipfel = val;
            gipfelFehler = val.isEmpty ? FilterFehler.fehlermeldungGipfel : null;
          }),
        );

      case "weg":
        return TextField(
          maxLength: 30,
          decoration: InputDecoration(
            labelText: "Weg",
            errorText: wegFehler,
          ),
          onChanged: (val) => setState(() {
            weg = val;
            wegFehler = val.isEmpty ? FilterFehler.fehlermeldungWeg : null;
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
      content: SingleChildScrollView(child: baueFilterFeld()),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Abbrechen"),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              // Fehler zurücksetzen
              datumFehler =
                  gebietFehler = gipfelFehler = wegFehler = schwierigkeitFehler = null;

              switch (widget.filterKategorie) {
                case "datum":
                  if (datum == null || datum!.isEmpty) datumFehler = FilterFehler.fehlermeldungDatum;
                  break;
                case "gebiet":
                  if (gebiet == null || gebiet!.isEmpty) gebietFehler = FilterFehler.fehlermeldungGebiet;
                  break;
                case "gipfel":
                  if (gipfel == null || gipfel!.isEmpty) gipfelFehler = FilterFehler.fehlermeldungGipfel;
                  break;
                case "weg":
                  if (weg == null || weg!.isEmpty) wegFehler = FilterFehler.fehlermeldungWeg;
                  break;
                case "schwierigkeit":
                  if (schwierigkeit == null || schwierigkeit!.isEmpty) schwierigkeitFehler = FilterFehler.fehlermeldungSchwierigkeit;
                  break;
              }
            });

            // Wenn Fehler vorhanden → abbrechen
            if (datumFehler != null ||
                gebietFehler != null ||
                gipfelFehler != null ||
                wegFehler != null ||
                schwierigkeitFehler != null) {
              return;
            }

            // Filter anwenden
            widget.beimAnwenden({
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