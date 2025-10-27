import 'package:flutter/material.dart';
import 'package:flutter_kletterlogbuch/app/app_widget.dart';
import 'package:flutter_kletterlogbuch/screens/dashboard.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock für Hive-Box
class MockBox<T> extends Mock implements Box<T> {}

void main() {
  setUpAll(() {
    // Google Fonts im Test "überlisten" – verwenden Default-Font
    GoogleFonts.config.allowRuntimeFetching = false;
  });
  group('Kletterlogbuch App Tests', () {
    late Box box;

    setUp(() async {
      await setUpTestHive(); // Initialisiert Hive für Tests
      box = await Hive.openBox('kletterbox'); // Test-Box
    });

    tearDown(() async {
      await tearDownTestHive(); // Bereinigt Hive nach jedem Test
    });

    testWidgets('App startet und zeigt Startbildschirm', (tester) async {
      // Timer-Funktionen werden hier ignoriert
      await tester.runAsync(() async {
        await tester.pumpWidget(const MyApp());
        await tester.pump(); // baut das Widget einmal
      });

      expect(find.text('KLETTERLOGBUCH'), findsOneWidget);
    });

    testWidgets('Dashboard lädt Klettereinträge', (WidgetTester tester) async {
      // Simuliere Einträge in Hive
      await box.put('weg1', {'name': 'Route A', 'schwierigkeit': '5a'});
      await box.put('weg2', {'name': 'Route B', 'schwierigkeit': '6b'});

      await tester.pumpWidget(MaterialApp(home: Dashboard()));

      // Prüfen, dass die Einträge angezeigt werden
      expect(find.text('Route A'), findsOneWidget);
      expect(find.text('Route B'), findsOneWidget);
    });

    testWidgets('Neuer Klettereintrag wird hinzugefügt', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Dashboard()));

      // Füge über HiveHilfe ein neues Objekt hinzu
      await box.put('route1', {'name': 'Route C', 'schwierigkeit': '4c'});
      // Dashboard neu laden
      await tester.pump();

      expect(find.text('Route C'), findsOneWidget);
    });
  });

  testWidgets('App startet', (WidgetTester tester) async {
    // Minimaler Startscreen zum Testen
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Center(child: Text('App startet')),
      ),
    ));

    // Prüft, ob Text vorhanden ist
    expect(find.text('App startet'), findsOneWidget);
  });

  testWidgets('TextField kann Text aufnehmen', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: TextField(),
      ),
    ));

    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    await tester.enterText(textField, 'Hallo Test');
    expect(find.text('Hallo Test'), findsOneWidget);
  });

  testWidgets('Button reagiert auf Tap', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ElevatedButton(
          onPressed: () {
            tapped = true;
          },
          child: const Text('Tippe mich'),
        ),
      ),
    ));

    await tester.tap(find.text('Tippe mich'));
    await tester.pump(); // rebuild nach Tap

    expect(tapped, true);
  });
}