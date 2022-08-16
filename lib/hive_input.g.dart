// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_input.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HistoryAdapter extends TypeAdapter<History> {
  @override
  final int typeId = 0;

  @override
  History read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return History(
      calculations: fields[1] as String?,
      ans: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, History obj) {
    writer
      ..writeByte(2)
      ..writeByte(1)
      ..write(obj.calculations)
      ..writeByte(2)
      ..write(obj.ans);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PrivateFilesAdapter extends TypeAdapter<PrivateFiles> {
  @override
  final int typeId = 1;

  @override
  PrivateFiles read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrivateFiles(
      path: fields[1] as String?,
      size: fields[2] as int?,
      name: fields[3] as String?,
      extension: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PrivateFiles obj) {
    writer
      ..writeByte(4)
      ..writeByte(1)
      ..write(obj.path)
      ..writeByte(2)
      ..write(obj.size)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.extension);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrivateFilesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
