import 'priority.dart';
import 'task.dart';

class UrgentTask extends Task {
  UrgentTask({
    required super.id,
    required super.title,
    super.priority = Priority.high,
    super.dueDate,
    super.isCompleted = false,
  });

  @override
  String getTaskType() => 'Urgent';
}