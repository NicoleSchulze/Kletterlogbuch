import 'package:flutter/material.dart';
import '../models/kletterweg_datenmodell.dart';

/// --- Datenmodell für einen Klettertag ---
// Ein Tag, an dem mehrere Kletterwege dokumentiert werden
class Klettertag {
  final int nummer;             // Nummerierung des Tages
  final String datum;
  final String gebiet;
  final List<Kletterweg> wege;  // Alle Kletterwege dieses Tages

  // Konstruktor für Klettertag
  Klettertag({required this.nummer, required this.datum, required this.gebiet, required this.wege});
}

/// --- Schwierigkeit ins Römische übersetzen ---
String schwierigkeitsgradInRoemisch(String grad) {
  const mapping = {
    "1": "I", "2": "II", "3": "III", "4": "IV", "5": "V", "6": "VI",
    "7a": "VIIa", "7b": "VIIb", "7c": "VIIc",
    "8a": "VIIIa", "8b": "VIIIb", "8c": "VIIIc",
    "9a": "IXa", "9b": "IXb", "9c": "IXc",
    "10a": "Xa", "10b": "Xb", "10c": "Xc",
  };
  return mapping[grad] ?? grad; // Falls keine Zuordnung existiert, Original zurückgeben
}

/// --- Sterneanzeige Widget ---
// Zeigt bis zu 3 Sterne für Bewertung an
Widget buildStars(int stars) {
  return Row(
    mainAxisSize: MainAxisSize.min, // Nur so breit wie nötig
    children: List.generate(3, (index) {
      // Index kleiner als Anzahl Sterne → gefüllt, sonst leer
      return Icon(index < stars ? Icons.star : Icons.star_border, size: 16, color: Colors.amber);
    }),
  );
}

/// --- Gruppierung der Kletterwege nach Datum ---
// Nimmt eine Liste von Kletterwegen und erzeugt daraus Klettertag-Objekte
List<Klettertag> gruppiereNachDatum(List<Kletterweg> wege) {
  final Map<String, List<Kletterweg>> map = {}; // Datum → Liste der Wege

  // Alle Wege in Map nach Datum gruppieren
  for (var weg in wege) {
    map.putIfAbsent(weg.datum, () => []).add(weg);
  }

  int counter = 1; // Zähler für die Nummerierung der Klettertage

  // Map-Einträge in Klettertag-Objekte umwandeln
  return map.entries.map((e) => Klettertag(
    nummer: counter++,                // fortlaufende Nummer
    datum: e.key,                     // Datum
    gebiet: e.value.first.gebiet,     // Gebiet vome ersten Weg
    wege: e.value,                    // Alle Wege an diesem Datum
  )).toList();
}