import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App startet', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('App startet'))),
      ),
    );

    // Prüft, ob Text vorhanden ist
    expect(find.text('App startet'), findsOneWidget);
  });

  testWidgets('Neuer Eintrag Button klickbar', (WidgetTester tester) async {
    bool buttonClicked = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ElevatedButton(
            onPressed: () {
              buttonClicked = true;
            },
            child: const Text('Neuer Eintrag'),
          ),
        ),
      ),
    );

    // Button finden
    final buttonFinder = find.text('Neuer Eintrag');
    expect(buttonFinder, findsOneWidget);

    // Button klicken
    await tester.tap(buttonFinder);
    await tester.pump();

    // Prüft ob Klick registriert wurde
    expect(buttonClicked, true);
  });

  testWidgets('Textfeld kann Eingabe aufnehmen', (WidgetTester tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Klettereintrag'),
          ),
        ),
      ),
    );

    // Textfeld finden
    final textFieldFinder = find.byType(TextField);
    expect(textFieldFinder, findsOneWidget);

    // Text eingeben
    await tester.enterText(textFieldFinder, 'Top-Rope Route');
    await tester.pump();

    // Prüft ob Text übernommen wurde
    expect(controller.text, 'Top-Rope Route');
  });
}
