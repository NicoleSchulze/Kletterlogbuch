import 'package:flutter/material.dart';
import '../models/kletterweg.dart';

class AddKletterwegDialog extends StatefulWidget {
  final Function(Kletterweg) onSave;

  const AddKletterwegDialog({super.key, required this.onSave});

  @override
  State<AddKletterwegDialog> createState() => _AddKletterwegDialogState();
}

class _AddKletterwegDialogState extends State<AddKletterwegDialog> {
  String datum = "";
  String gebiet = "";
  String gipfel = "";
  String weg = "";
  String schwierigkeit = "";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Neuen Eintrag hinzufügen"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(decoration: const InputDecoration(labelText: "Datum"), onChanged: (val) => datum = val),
          TextField(decoration: const InputDecoration(labelText: "Gebiet"), onChanged: (val) => gebiet = val),
          TextField(decoration: const InputDecoration(labelText: "Gipfel"), onChanged: (val) => gipfel = val),
          TextField(decoration: const InputDecoration(labelText: "Weg"), onChanged: (val) => weg = val),
          TextField(decoration: const InputDecoration(labelText: "Schwierigkeit"), onChanged: (val) => schwierigkeit = val),
        ],
      ),
      actions: [
        TextButton(child: const Text("Abbrechen"), onPressed: () => Navigator.pop(context)),
        ElevatedButton(
          child: const Text("Speichern"),
          onPressed: () {
            if (weg.isNotEmpty && schwierigkeit.isNotEmpty) {
              widget.onSave(Kletterweg(
                datum: datum,
                gebiet: gebiet,
                gipfel: gipfel,
                weg: weg,
                schwierigkeit: schwierigkeit,
              ));
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}