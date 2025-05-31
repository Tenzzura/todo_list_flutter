import 'package:isar/isar.dart';

part 'todo.g.dart';

@Collection()
class Todo {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  String? title;
  String? description;

  DateTime? createdAt;
  bool isCompleted = false;

  Todo copyWith({
    String? title,
    String? description,
    DateTime? createdAt,
    bool? isCompleted,
  }) {
    return Todo()
      ..id = id
      ..title = title ?? this.title
      ..description = description ?? this.description
      ..createdAt = createdAt ?? this.createdAt
      ..isCompleted = isCompleted ?? this.isCompleted;
  }
}