import 'package:flutter/material.dart';
import '../models/kletterweg_datenmodell.dart';

/// --- Datenmodell für einen Klettertag ---
// Ein Tag, an dem mehrere Kletterwege dokumentiert werden
class Klettertag {
  final int nummer; // Nummerierung des Tages
  final String datum;
  final String gebiet;
  final List<Gipfel> gipfel; // Alle Gipfel eines Tages

  // Konstruktor für Klettertag
  Klettertag({
    required this.nummer,
    required this.datum,
    required this.gebiet,
    List<Gipfel>? gipfel,
  }) : gipfel = gipfel ?? []; // Jeder Klettertag genau ein Datum + Gebiet

  // Prüfen, ob es Gipfel schon in Liste gibt
  void addRoute(String gipfelName, String routeName, String schwierigkeit) {
    final existingGipfel = gipfel.firstWhere(
      (g) => g.name == gipfelName,
      orElse: () {
        //Wenn nicht: neuen Gipfel anlegen und hinzufügen
        final newGipfel = Gipfel(name: gipfelName);
        gipfel.add(newGipfel);
        return newGipfel;
      },
    );
    existingGipfel.routen.add(Route(name: routeName, schwierigkeit: schwierigkeit));
  }
}

class Gipfel {
  final String name;
  final List<Route> routen;

  // Konstruktor für Gipfel
  Gipfel({required this.name, List<Route>? routen}) : routen = routen ?? [];
}

class Route {
  final String name;
  final String schwierigkeit;

  // Konstruktor für Route
  Route({required this.name, required this.schwierigkeit});
}

/// --- Schwierigkeit ins Römische übersetzen ---
String schwierigkeitsgradInRoemisch(String grad) {
  const mapping = {
    "1": "I",
    "2": "II",
    "3": "III",
    "4": "IV",
    "5": "V",
    "6": "VI",
    "7a": "VIIa",
    "7b": "VIIb",
    "7c": "VIIc",
    "8a": "VIIIa",
    "8b": "VIIIb",
    "8c": "VIIIc",
    "9a": "IXa",
    "9b": "IXb",
    "9c": "IXc",
    "10a": "Xa",
    "10b": "Xb",
    "10c": "Xc",
  };
  return mapping[grad] ??
      grad; // Falls keine Zuordnung existiert, Original zurückgeben
}

/// --- Sterneanzeige Widget ---
// Zeigt bis zu 3 Sterne für Bewertung an
Widget buildStars(int stars) {
  return Row(
    mainAxisSize: MainAxisSize.min, // Nur so breit wie nötig
    children: List.generate(3, (index) {
      // Index kleiner als Anzahl Sterne → gefüllt, sonst leer
      return Icon(
        index < stars ? Icons.star : Icons.star_border,
        size: 16,
        color: Colors.amber,
      );
    }),
  );
}

/// --- Gruppierung der Kletterwege nach Datum ---
List<Klettertag> gruppiereNachDatum(List<KletterEintrag> eintraege) {
  // Map erstellen: Schlüssel = Datum, Wert = Liste von Klettereinträgen an diesem Datum
  final Map<String, List<KletterEintrag>> map = {};

  // Alle Eintreage in Map nach Datum gruppieren
  // Falls Datum noch nicht in der Map → neue Liste anlegen und dann den Eintrag hinzufügen
  for (var e in eintraege) {
    map.putIfAbsent(e.datum, () => []).add(e);
  }

  int counter = 1; // Zähler für die Nummerierung der Klettertage

  // Map-Eintraege (bestimmtes Datum) in Klettertag umwandeln
  return map.entries.map((entry) {
    final List<Gipfel> gipfelListe = [];

    // Alle Eintraege (Routen) an diesem Datum durchgehen
    // Prüfen, ob der Gipfel schon in der Liste existiert
    // Falls Gipfel noch nicht existiert → neuen Gipfel anlegen
    for (var e in entry.value) {
      var existing = gipfelListe.where((g) => g.name == e.gipfel).toList();
      if (existing.isEmpty) {
        final newGipfel = Gipfel(name: e.gipfel);
        newGipfel.routen.add(
          Route(name: e.weg, schwierigkeit: e.schwierigkeit),
        );
        gipfelListe.add(newGipfel);
      } else {
        existing.first.routen.add(
          Route(name: e.weg, schwierigkeit: e.schwierigkeit),
        );
      }
    }

    return Klettertag(
      nummer: counter++,
      datum: entry.key,
      gebiet: entry.value.first.gebiet,
      gipfel: gipfelListe,
    );
  }).toList();
}
