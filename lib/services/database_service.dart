import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:to_do_list/models/todo.dart';



class DatabaseService {
  static late final Isar db;
  static Future<void> inisialisasi() async {
    final dir = await getApplicationDocumentsDirectory();
    db = await Isar.open([TodoSchema], directory: dir.path);
  }
}
