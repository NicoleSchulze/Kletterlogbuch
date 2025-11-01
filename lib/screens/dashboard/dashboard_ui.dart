import 'package:flutter/material.dart';
import 'package:flutter_kletterlogbuch/konstanten/farben.dart';
import 'package:flutter_kletterlogbuch/modelle/klettereintrag.dart';
import 'package:flutter_kletterlogbuch/screens/dashboard/dashboard_hilfe.dart';
import 'dashboard_dialogFilter.dart';

/// ----------------------------
/// UI - Gerüst
/// ----------------------------
class DashboardUI {
  AppBar erstelleAppBar(BuildContext context, DashboardHilfe hilfe) {
    return AppBar(
      backgroundColor: AppFarben.primaeresgruen,
      title: const Text(
        "Dashboard",
        style: TextStyle(
          color: AppFarben.dunklesCreme,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          color: AppFarben.dunklesCreme,
          onPressed: () async {
            // Popup-Menü für Kategorie auswählen
            final value = await showMenu<String>(
              context: context,
              position: const RelativeRect.fromLTRB(100, 80, 0, 0),
              items: const [
                PopupMenuItem(value: "alle", child: Text("Alle anzeigen")),
                PopupMenuItem(value: "datum", child: Text("Datum")),
                PopupMenuItem(value: "gebiet", child: Text("Gebiet")),
                PopupMenuItem(value: "gipfel", child: Text("Gipfel")),
                PopupMenuItem(value: "weg", child: Text("Weg")),
                PopupMenuItem(value: "schwierigkeit", child: Text("Schwierigkeit")),
              ],
            );

            if (value == null) return;

            // "Alle anzeigen" → Filter zurücksetzen
            if (value == "alle") {
              hilfe.filterMap.updateAll((key, value) => null);
              hilfe.ladeKletterwege();
              hilfe.aktualisieren(() {});
            } else {
              // Dialog für die gewählte Kategorie öffnen
              await showDialog(
                context: context,
                builder: (ctx) => KletterwegEinzelFilterDialog(
                  filterKategorie: value,
                  beimAnwenden: (filterData) {
                    hilfe.filterMap[value] = filterData[value];
                    hilfe.ladeKletterwege();
                    hilfe.aktualisieren(() {});
                  },
                ),
              );
            }
          },
        ),
        IconButton(
          icon: Icon(hilfe.editierModus ? Icons.check : Icons.edit),
          color: hilfe.loeschModus ? Colors.grey : AppFarben.dunklesCreme,
          tooltip: hilfe.editierModus ? "Bearbeitung speichern" : "Einträge bearbeiten",
          onPressed: hilfe.loeschModus
              ? null // Stift deaktiviert, wenn Löschmodus aktiv
              : () async {
            if (hilfe.editierModus) {
              await hilfe.speichereAenderungen(); // Änderungen speichern
            }
            hilfe.editierModus = !hilfe.editierModus;
            hilfe.aktualisieren(() {});
          },
        ),
        IconButton(
          icon: Icon(hilfe.loeschModus ? Icons.check : Icons.delete),
          color: hilfe.editierModus ? Colors.grey : AppFarben.dunklesCreme,
          onPressed: hilfe.editierModus
              ? null // Mülleimer deaktiviert, wenn Editiermodus aktiv
              : () {
            if (hilfe.loeschModus) {
              if (hilfe.ausgewaehlteKeys.isNotEmpty) {
                hilfe.loeschenAusgewaehlte(); // löschen
              } else {
                hilfe.loeschModus = false; // Löschmodus verlassen, wenn nichts ausgewählt
              }
            } else {
              hilfe.loeschModus = true;
              hilfe.ausgewaehlteKeys.clear();
            }
            hilfe.aktualisieren(() {});
          },
        ),
      ],
    );
  }

  // Body (Hauptinhalt des Dashboards)
  Widget erstelleBody(DashboardHilfe hilfe) {
    // Wenn keine Einträge vorhanden → Platzhalter
    if (hilfe.eintraegeNachDatumGebietGipfel.isEmpty) {
      return const Center(child: Text("Noch keine Einträge"));
    }

    // Liste aller gruppierten Einträge (Datum + Gebiet)
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      children: [
        for (
          var index = 0;
          index < hilfe.eintraegeNachDatumGebietGipfel.keys.length;
          index++
        )
          erstelleKletterkarte(index, hilfe),
      ],
    );
  }

  // FloatingActionButton
  Widget erstelleAddButton(BuildContext context, DashboardHilfe hilfe) {
    return FloatingActionButton(
      backgroundColor: AppFarben.primaeresgruen,
      foregroundColor: AppFarben.dunklesCreme,
      elevation: 4,
      onPressed: () => hilfe.neuerKletterweg(context),
      child: const Icon(Icons.add, size: 30),
    );
  }

  // Karte für jeden Klettertag (Datum + Gebiet)
  Widget erstelleKletterkarte(int index, DashboardHilfe hilfe) {
    final datumUndGebiet = hilfe.eintraegeNachDatumGebietGipfel.keys.elementAt(
      index,
    );
    final gipfelMap = hilfe.eintraegeNachDatumGebietGipfel[datumUndGebiet]!;
    final tagNummer = hilfe.eintraegeNachDatumGebietGipfel.keys.length - index;
    final isSelected = hilfe.ausgewaehlteKeys.contains(datumUndGebiet);

    return InkWell(
      onTap: hilfe.loeschModus
          ? () {
              if (isSelected) {
                hilfe.ausgewaehlteKeys.remove(datumUndGebiet);
              } else {
                hilfe.ausgewaehlteKeys.add(datumUndGebiet);
              }
              hilfe.aktualisieren(() {});
            }
          : null,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadowColor: AppFarben.dunkelbraun.withValues(alpha: 0.4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: isSelected
                ? AppFarben.ausgewaehlteKarteCreme
                : AppFarben.dunklesCreme,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppFarben.dunkelbraun.withValues(alpha: 0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: _erstelleKartenInhalt(
            tagNummer,
            datumUndGebiet,
            gipfelMap,
            hilfe,
          ),
        ),
      ),
    );
  }

  // Inhalt innerhalb einer Karte
  Widget _erstelleKartenInhalt(
    int tagNummer,
    String datumUndGebiet,
    Map<String, List<KletterEintrag>> gipfelMap,
    DashboardHilfe hilfe,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _erstelleDatumUndGebietZeile(tagNummer, datumUndGebiet, gipfelMap, hilfe),
        const SizedBox(height: 4),
        ...gipfelMap.entries.map(
          (e) => _erstelleGipfelBlock(e.key, e.value, hilfe),
        ),
      ],
    );
  }

  // Datum- und Gebietszeile
  Widget _erstelleDatumUndGebietZeile(
    int tagNummer,
    String datumUndGebiet,
    Map<String, List<KletterEintrag>> gipfelMap,
    DashboardHilfe hilfe,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "$tagNummer) ",
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppFarben.dunkelbraun,
          ),
        ),
        Expanded(
          child: TextField(
            controller: TextEditingController(
              text: datumUndGebiet.replaceFirst(' – ', ': '),
            ),
            enabled: hilfe.editierModus,
            maxLines: null,
            minLines: 1,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppFarben.dunkelbraun,
            ),
            onChanged: (v) {
              if (!hilfe.editierModus) return;
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
            },
          ),
        ),
      ],
    );
  }

  // Gipfelblock
  Widget _erstelleGipfelBlock(
    String gipfel,
    List<KletterEintrag> wege,
    DashboardHilfe hilfe,
  ) {
    hilfe.controllers.putIfAbsent(
      gipfel.hashCode,
      () => {'gipfel': TextEditingController(text: gipfel)},
    );
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.filter_hdr,
                color: AppFarben.dunkelbraun,
                size: 18,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: TextField(
                  controller: hilfe.controllers[gipfel.hashCode]!['gipfel'],
                  enabled: hilfe.editierModus,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 2),
                  ),
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppFarben.dunkelbraun,
                  ),
                  onChanged: (v) {
                    if (!hilfe.editierModus) return;
                    for (var e in wege) e.gipfel = v;
                  },
                ),
              ),
            ],
          ),
          ...wege.map((e) => _erstelleWegZeile(e, hilfe)),
        ],
      ),
    );
  }

  // Wegzeile mit Schwierigkeit
  Widget _erstelleWegZeile(KletterEintrag eintrag, DashboardHilfe hilfe) {
    hilfe.controllers.putIfAbsent(eintrag.key, () => {});
    hilfe.controllers[eintrag.key]!['combined'] ??= TextEditingController(
      text: "${eintrag.weg} (${eintrag.schwierigkeit})",
    );

    final controller = hilfe.controllers[eintrag.key]!['combined']!;
    return Padding(
      padding: const EdgeInsets.only(left: 22, top: 1),
      child: Row(
        children: [
          const Text(
            "→ ",
            style: TextStyle(fontSize: 13.5, color: AppFarben.dunkelbraun),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: hilfe.editierModus,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                fontSize: 13.5,
                color: AppFarben.dunkelbraun,
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
  }
}
