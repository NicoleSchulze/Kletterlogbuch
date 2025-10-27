# Kletterlogbuch

Ein digitales Kletter-Logbuch für die Sächsische Schweiz – 
<br>
Touren einfach dokumentieren, verwalten und auswerten.


## Inhalt

- [Projektstruktur](#projektstruktur)
- [Initiales Setup](#initiales-setup)
- [Vorraussetzungen](#vorraussetzungen)
- [Anhängigkeiten](#abhängigkeiten)
- [Lokale Entwicklung](#lokale-entwicklung)
- [Staging & Production Setup](#staging--production-setup)
- [Best Practices](#best-practices)
- [Hinweise](#hinweise)

---

## Projektstruktur
````
lib/
│
├── main.dart                              -> Einstiegspunkt der App
│
├── app/
│   ├── app_widget.dart                    -> MyApp (Theme, Lokalisierung, Startscreen)
│   └── app_start.dart                     -> Hive-Initialisierung und runApp()
│
├── screens/
│   ├── startbildschirm.dart               -> SplashScreen
│   ├── dashboard.dart                     -> Haupt-Dashboard
│   └── widgets/
│       ├── dialog_neuer_weg.dart          -> Neuer Kletterweg hinzufügen
│       ├── dialog_filter.dart             -> Filterdialog
│       └── helper_dashboard.dart          -> Hilfsfunktionen & Modelle fürs Dashboard
│
├── datenbank/
│   ├── hive_hilfe.dart                    -> Hive Helper mit CRUD-Methoden
│
├── modelle/
│   ├── klettereintrag.dart                -> Datenmodell
│   └── klettereintrag.g.dart              -> Generierter Adapter
│
└── utils/
    └── konvertierungen.dart               -> (optional) z. B. Schwierigkeit → Römisch
````
## Initiales Setup

### Vorraussetzungen
- Flutter SDK installiert -> https://docs.flutter.dev/get-started
- Dart SDK (wird mit Flutter geliefert)
- IDE wie IntelliJ oder ähnliches
- Xcode (für IOS-Entwicklung auf macOS)
- Git (Versionierung)


- Prüfen, ob alles korrekt installiert: ````flutter doctor````


### Projekt klonen
- ````git clone <repository-url>````

## Abhängigkeiten
-  ````flutter pub get````

## Lokale Entwicklung
- App starten: ````flutter run````
- Tests ausführen: ````flutter test````

## Staging & Production Setup

## Hinweise:
- Google Fonts: müssen lokal eingebunden werden, wenn allowRuntimeFetching = false
- Hive boxen: Vor jedem Zugriff Hive.openBox() aufrufen
- Tests: Netzwerkzugriffe blockiert → keine echten HTTP Calls in Tests

### Im Terminal
- Hot Reload: ````r```` 
- Hot Restart: ````R````
- Alle Abhängigkeiten aktualisieren: ````flutter pub upgrade````

## Best Practices
- Widgets klein und wiederverwendbar halten
- Geschäftslogik von UI trennen
- Hive nur über Helper-Klasse HiveHilfe ansprechen
- Tests isoliert halten und Timer/Future korrekt mocken
