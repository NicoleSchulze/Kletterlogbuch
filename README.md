# Kletterlogbuch
Ein digitales Kletter-Logbuch für die Sächsische Schweiz – Touren einfach dokumentieren, verwalten und auswerten.

## Inhalt

- [Projektstruktur](#projektstruktur)
- [Vorraussetzungen](#vorraussetzungen)
- [Projekt clonen](#projekt-klonen)
- [Anhängigkeiten](#abhängigkeiten)
- [Lokale Entwicklung](#lokale-entwicklung)
- [Hive Setup](#hive-setup)
- [Im Terminal](#im-terminal)
- [Aktueller Stand](#aktueller-stand)

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
│   ├── startbildschirm.dart               -> Startbildschirm
│   └── dashboard                          -> Haupt-Dashboard
│       ├── dasboard.dart
│       ├── dashboard_dialogFilter.dart    -> Filterdialog
│       ├── dashboard_dialogNeuerWeg.dart  -> Neuer Kletterweg hinzufügen
│       ├── dashboard_hilfe.dart           -> Dashboard-Hilfsklasse (Logik)
│       └── dashboard_ui.dart              -> Dashboard-UI-Komponeten
│
├── services/
│   └── hive_hilfe.dart                    -> Hive Helper mit CRUD-Methoden
│
├── modelle/
│   ├── klettereintrag.dart                -> Datenmodell
│   ├── klettereintrag.g.dart              -> Generierter Adapter
│   └── klettertag.dart                    -> Modell: Klettertag, Gipfel, Route  
│
└── konstanten/
    ├── farben.dart    
    └── fehlermeldungen.dart       
````
## Vorraussetzungen
- Flutter SDK installiert -> https://docs.flutter.dev/get-started
- Test Flutter Version: ````flutter --version````
- Dart SDK (wird mit Flutter geliefert)
- IDE wie IntelliJ oder ähnliches
- Xcode (für IOS-Entwicklung auf macOS)
- Git (Versionierung)
- Prüfen, ob alles korrekt installiert: ````flutter doctor````

## Projekt klonen
- ````git clone <repository-url>````
- ````cd <projektordner>````

## Abhängigkeiten
-  ````flutter pub get````

## Lokale Entwicklung
- App für macOS bauen: ````flutter build macos````
- App starten: ````flutter run -d macos````
- Tests ausführen: ````flutter test````

## Hive Setup
- Hive wird automatisch beim Start geöffnet (app_start.dart)
- Box-Namen: klettereintraege

## Im Terminal
- Hot Reload: ````r```` 
- Hot Restart: ````R````
- Alle Abhängigkeiten aktualisieren: ````flutter pub upgrade````

## Aktueller Stand
- MacOS build
- Wenige Tests
- Mobile first 