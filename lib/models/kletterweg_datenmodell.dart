/// --- Datenmodell ---
// Wie sieht Eintrag im Logbuch aus
// Final = Werte sind unveränderbar
// required = Werte müssen immer bei erstellen eingegeben werden
class Kletterweg {
  final int? id;
  final String datum;
  final String gebiet;
  final String gipfel;
  final String weg;
  final String schwierigkeit;

  // Konstruktor um neue Objekte erzeugen zu können
  // this = zeigt auf das aktuelle Objekt selbst
  // this.datum = das datum, das im Kletterweg gespeichert ist oder this. gebiet auf das Gebiet
  // Meine Variable in der Klasse nicht nur Namen im Konstruktor
  Kletterweg({
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
  factory Kletterweg.fromMap(Map<String, dynamic> map) {
    return Kletterweg(
      id: map['id'],
      datum: map['datum'],
      gebiet: map['gebiet'],
      gipfel: map['gipfel'],
      weg: map['weg'],
      schwierigkeit: map['schwierigkeit'],
    );
  }
}