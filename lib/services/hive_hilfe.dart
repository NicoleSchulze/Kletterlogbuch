import 'package:hive_flutter/hive_flutter.dart';
import '../modelle/klettereintrag.dart';

/// ============================================================
/// HiveHilfe – Serviceklasse für Hive-Datenbankzugriffe
/// ============================================================
/// Zuständig für:
///   - Öffnen und Zugriff auf die Hive-Box
///   - CRUD-Operationen (Create, Read, Update, Delete)
///   - Zentrale Verwaltung aller gespeicherten KletterEinträge
/// ============================================================

class HiveHilfe {
  static const String boxName = 'klettereintraege';

  static Box<KletterEintrag> get box => Hive.box<KletterEintrag>(boxName);

  /// Eintrag speichern
  static Future<void> hinzufuegen(KletterEintrag e) async => await box.add(e);

  /// Alle Einträge abrufen
  static List<KletterEintrag> alle() => box.values.toList();

  /// Eintrag aktualisieren
  static Future<void> aktualisieren(KletterEintrag e) async => await e.save();

  /// Eintrag löschen
  static Future<void> loeschen(KletterEintrag e) async => await e.delete();
}