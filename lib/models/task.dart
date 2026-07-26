import 'priority.dart';

abstract class Task {
  final String id;
  String title;
  Priority priority;
  DateTime? dueDate;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.priority,
    this.dueDate,
    this.isCompleted = false,
  });

  // Méthode abstraite pour afficher le type/résumé de la tâche.
  String getTaskType();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': getTaskType(),
      'title': title,
      'priority': priority.name,
      'dueDate': dueDate?.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }
}