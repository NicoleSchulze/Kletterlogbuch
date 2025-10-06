// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kletterweg_datenmodell.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KletterEintragAdapter extends TypeAdapter<KletterEintrag> {
  @override
  final int typeId = 0;

  @override
  KletterEintrag read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KletterEintrag(
      id: fields[0] as int?,
      datum: fields[1] as String,
      gebiet: fields[2] as String,
      gipfel: fields[3] as String,
      weg: fields[4] as String,
      schwierigkeit: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, KletterEintrag obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.datum)
      ..writeByte(2)
      ..write(obj.gebiet)
      ..writeByte(3)
      ..write(obj.gipfel)
      ..writeByte(4)
      ..write(obj.weg)
      ..writeByte(5)
      ..write(obj.schwierigkeit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KletterEintragAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
