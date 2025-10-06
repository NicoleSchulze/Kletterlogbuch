import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/kletterweg_datenmodell.dart';

class HiveDatabaseHelper {
  static const String boxName = 'klettereintraege';

  static Future<void> initHive() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(KletterEintragAdapter());
    }
    await Hive.openBox<KletterEintrag>(boxName);
  }

  static Box<KletterEintrag> get box => Hive.box<KletterEintrag>(boxName);

  /// --- CRUD Operationen ---
  // Insert
  static Future<void> insertKletterEintrag(KletterEintrag eintrag) async {
    await box.add(eintrag);
  }
  // Query All
  static List<KletterEintrag> queryAllKletterEintraege() {
    return box.values.toList();
  }
  // Update
  static Future<void> updateKletterEintrag(KletterEintrag eintrag) async {
    await eintrag.save(); // HiveObject Methode
  }
  // Delete
  static Future<void> deleteKletterEintrag(KletterEintrag eintrag) async {
    await eintrag.delete(); // HiveObject Methode
  }
  // Löschen
  static Future<void> clearAll() async {
    await box.clear();
  }
}