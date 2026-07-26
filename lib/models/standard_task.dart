import 'priority.dart';
import 'task.dart';

class StandardTask extends Task {
  StandardTask({
    required super.id,
    required super.title,
    super.priority = Priority.low,
    super.dueDate,
    super.isCompleted = false,
  });

  @override
  String getTaskType() => 'Standard';
}