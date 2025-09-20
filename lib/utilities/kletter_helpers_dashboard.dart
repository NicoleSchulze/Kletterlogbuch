import 'package:flutter/material.dart';
import '../models/kletterweg.dart';

class Klettertag {
  final int nummer;
  final String datum;
  final String gebiet;
  final List<Kletterweg> wege;

  Klettertag({required this.nummer, required this.datum, required this.gebiet, required this.wege});
}

String schwierigkeitsgradInRoemisch(String grad) {
  const mapping = {
    "1": "I", "2": "II", "3": "III", "4": "IV", "5": "V", "6": "VI",
    "7a": "VIIa", "7b": "VIIb", "7c": "VIIc",
    "8a": "VIIIa", "8b": "VIIIb", "8c": "VIIIc",
    "9a": "IXa", "9b": "IXb", "9c": "IXc",
    "10a": "Xa", "10b": "Xb", "10c": "Xc",
  };
  return mapping[grad] ?? grad;
}

Widget buildStars(int stars) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(3, (index) {
      return Icon(index < stars ? Icons.star : Icons.star_border, size: 16, color: Colors.amber);
    }),
  );
}

List<Klettertag> gruppiereNachDatum(List<Kletterweg> wege) {
  final Map<String, List<Kletterweg>> map = {};
  for (var weg in wege) {
    map.putIfAbsent(weg.datum, () => []).add(weg);
  }
  int counter = 1;
  return map.entries.map((e) => Klettertag(
    nummer: counter++,
    datum: e.key,
    gebiet: e.value.first.gebiet,
    wege: e.value,
  )).toList();
}