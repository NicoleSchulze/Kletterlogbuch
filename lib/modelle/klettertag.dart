import 'klettereintrag.dart';

/// ============================================================
///  Modell: Klettertag, Gipfel, Route
/// ============================================================
/// Beschreibt die hierarchische Struktur:
///   - Ein `Klettertag` enthält mehrere `Gipfel`
///   - Jeder `Gipfel` enthält mehrere `Routen`
/// ============================================================

class Klettertag {
  final int nummer; // fortlaufende Nummer
  final String datum;
  final String gebiet;
  final List<Gipfel> gipfel; // Liste alle Gipfel eines Tages

  // Konstruktor für Klettertag
  Klettertag({
    required this.nummer,
    required this.datum,
    required this.gebiet,
    List<Gipfel>? gipfel,
  }) : gipfel = gipfel ?? []; // Jeder Klettertag besutzt genau ein Datum + Gebiet

  // Fügt eine neue Kletterroute einem Gipfel hinzu
  // Falls Gipfel noch nicht existiert -> automatisch erstellt
  void addKletterroute(String gipfelName, String kletterrouteName, String schwierigkeit) {
    final existingGipfel = gipfel.firstWhere((g) => g.name == gipfelName,
      orElse: () {
        final newGipfel = Gipfel(name: gipfelName);
        gipfel.add(newGipfel);
        return newGipfel;
      },
    );
    existingGipfel.kletterrouten.add(Kletterroute(name: kletterrouteName, schwierigkeit: schwierigkeit));
  }
}

// Zeigt einen einzelnen Gipfel mit seinen Kletterrouten
class Gipfel {
  final String name;
  final List<Kletterroute> kletterrouten;

  // Konstruktor für Gipfel
  Gipfel({required this.name, List<Kletterroute>? routen}) : kletterrouten = routen ?? [];
}

// Zeigt eine einzelne Kletterroute
class Kletterroute {
  final String name;
  final String schwierigkeit;

  // Konstruktor für Route
  Kletterroute({required this.name, required this.schwierigkeit});
}

/// ============================================================
///  Hilfsfunktion
/// ============================================================

/// Gruppiert alle Klettereinträge nach Datum
/// Erstellt daraus eine Liste von Klettertagen
/// Jeder `Klettertag` ist ein Datum, an dem mehrere Gipfel mit ihren Kletterrouten eingetragen sind

List<Klettertag> gruppiereNachDatum(List<KletterEintrag> eintraege) {
  final Map<String, List<KletterEintrag>> map = {};

  // Jeden Eintrag nach Datum gruppieren
  // Falls Datum noch nicht in der Map → neue Liste anlegen und dann den Eintrag hinzufügen
  for (var e in eintraege) {
    map.putIfAbsent(e.datum, () => []).add(e);
  }
  int counter = 1; // Laufende Nummerierung für Klettertage

  // Jedes Datum in Klettertag umwandeln
  return map.entries.map((entry) {
    final List<Gipfel> gipfelListe = [];

    // Alle Eintraege durchgehen, prüfen ob Gipfel schon existiert
    // Falls Gipfel noch nicht existiert → neuen Gipfel anlegen
    for (var e in entry.value) {
      var existing = gipfelListe.where((g) => g.name == e.gipfel).toList();
      if (existing.isEmpty) {
        final newGipfel = Gipfel(name: e.gipfel);
        newGipfel.kletterrouten.add(Kletterroute(name: e.weg, schwierigkeit: e.schwierigkeit),);
        gipfelListe.add(newGipfel);
      } else {
        existing.first.kletterrouten.add(Kletterroute(name: e.weg, schwierigkeit: e.schwierigkeit),);
      }
    }
    // Klettertag für dieses Datum erstellen
    return Klettertag(
      nummer: counter++,
      datum: entry.key,
      gebiet: entry.value.first.gebiet,
      gipfel: gipfelListe,
    );
  }).toList();
}