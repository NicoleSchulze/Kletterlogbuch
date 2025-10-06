import 'package:hive/hive.dart';

part 'kletterweg_datenmodell.g.dart'; // Für generierten Adapter

/// --- Datenmodell ---
// Wie sieht Eintrag im Logbuch aus
// Final = Werte sind unveränderbar
// required = Werte müssen immer bei erstellen eingegeben werden
@HiveType(typeId: 0)
class KletterEintrag extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String datum;

  @HiveField(2)
  String gebiet;

  @HiveField(3)
  String gipfel;

  @HiveField(4)
  String weg;

  @HiveField(5)
  String schwierigkeit;

  // Konstruktor um neue Objekte erzeugen zu können
  // this = zeigt auf das aktuelle Objekt selbst
  // this.datum = das datum, das im Kletterweg gespeichert ist oder this. gebiet auf das Gebiet
  // Meine Variable in der Klasse nicht nur Namen im Konstruktor
  KletterEintrag({
    this.id,
    required this.datum,
    required this.gebiet,
    required this.gipfel,
    required this.weg,
    required this.schwierigkeit,
  });

  // Für SQLite speichern
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'datum': datum,
      'gebiet': gebiet,
      'gipfel': gipfel,
      'weg': weg,
      'schwierigkeit': schwierigkeit,
    };
  }

// Für SQLite laden
  factory KletterEintrag.fromMap(Map<String, dynamic> map) {
    return KletterEintrag(
      id: map['id'],
      datum: map['datum'],
      gebiet: map['gebiet'],
      gipfel: map['gipfel'],
      weg: map['weg'],
      schwierigkeit: map['schwierigkeit'],
    );
  }
}