import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';

part 'hive_input.g.dart';

@HiveType(typeId: 0)
class History {
  @HiveField(1)
  String? calculations;
  @HiveField(2)
  String? ans;

  History({required this.calculations, required this.ans});
}

@HiveType(typeId: 1)
class PrivateFiles {
  @HiveField(1)
  String? path;
  @HiveField(2)
  int? size;
  @HiveField(3)
  String? name;
  @HiveField(4)
  String? extension;

  PrivateFiles(
      {required this.path,
      required this.size,
      required this.name,
      required this.extension});
}
