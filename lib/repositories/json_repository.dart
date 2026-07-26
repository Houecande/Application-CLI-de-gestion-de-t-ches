import 'dart:convert';
import 'dart:io';
import '../exceptions/custom_exceptions.dart';
import '../interfaces/repository_interface.dart';
import '../models/priority.dart';
import '../models/standard_task.dart';
import '../models/task.dart';
import '../models/urgent_task.dart';

class JsonTaskRepository implements Repository<Task> {
  final String filePath;
  final List<Task> _tasks = [];

  JsonTaskRepository(this.filePath);

  Future<void> init() async {
    final file = File(filePath);
    if (!await file.exists()) {
      await file.create(recursive: true);
      await file.writeAsString('[]');
    } else {
      await _load();
    }
  }

  Future<void> _load() async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();
      if (content.trim().isEmpty) return;

      final List<dynamic> jsonList = jsonDecode(content);
      _tasks.clear();

      for (var item in jsonList) {
        final String id = item['id'];
        final String title = item['title'];
        final Priority priority = Priority.fromString(item['priority']);
        final DateTime? dueDate = item['dueDate'] != null ? DateTime.parse(item['dueDate']) : null;
        final bool isCompleted = item['isCompleted'] ?? false;
        final String type = item['type'] ?? 'Standard';

        if (type == 'Urgent') {
          _tasks.add(UrgentTask(
            id: id,
            title: title,
            priority: priority,
            dueDate: dueDate,
            isCompleted: isCompleted,
          ));
        } else {
          _tasks.add(StandardTask(
            id: id,
            title: title,
            priority: priority,
            dueDate: dueDate,
            isCompleted: isCompleted,
          ));
        }
      }
    } catch (e) {
      throw StorageException('Erreur lors de la lecture du fichier JSON : $e');
    }
  }

  @override
  Future<List<Task>> getAll() async => List.unmodifiable(_tasks);

  @override
  Future<Task?> getById(String id) async {
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> add(Task item) async {
    _tasks.add(item);
    await save();
  }

  @override
  Future<void> update(Task item) async {
    final index = _tasks.indexWhere((t) => t.id == item.id);
    if (index == -1) {
      throw TaskNotFoundException('Impossible de mettre à jour. Tâche introuvable (ID: ${item.id}).');
    }
    _tasks[index] = item;
    await save();
  }

  @override
  Future<void> delete(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) {
      throw TaskNotFoundException('Impossible de supprimer. Tâche introuvable (ID: $id).');
    }
    _tasks.removeAt(index);
    await save();
  }

  @override
  Future<void> save() async {
    try {
      final file = File(filePath);
      final jsonList = _tasks.map((t) => t.toJson()).toList();
      await file.writeAsString(const JsonEncoder.withIndent('  ').convert(jsonList));
    } catch (e) {
      throw StorageException('Erreur lors de la sauvegarde JSON : $e');
    }
  }
}