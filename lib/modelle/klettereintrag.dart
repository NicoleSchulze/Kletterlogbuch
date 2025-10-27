import 'package:hive/hive.dart';
part 'klettereintrag.g.dart';

/// Modell eines Klettereintrags
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

  KletterEintrag({
    this.id,
    required this.datum,
    required this.gebiet,
    required this.gipfel,
    required this.weg,
    required this.schwierigkeit,
  });
}