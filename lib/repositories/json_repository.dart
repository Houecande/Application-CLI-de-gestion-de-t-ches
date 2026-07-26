import 'dart:convert';
import 'dart:io';
import 'package:dart_task_cli/exceptions/custom_exceptions.dart';
import 'package:dart_task_cli/interfaces/repository_interface.dart';
import 'package:dart_task_cli/models/priority.dart';
import 'package:dart_task_cli/models/standard_task.dart';
import 'package:dart_task_cli/models/task.dart';
import 'package:dart_task_cli/models/urgent_task.dart';

class JsonTaskRepository implements Repository<Task> {
  final String filePath;
  List<Task> _cachedTasks = [];

  JsonTaskRepository(this.filePath);

  @override
  Future<void> init() async {
    final file = File(filePath);
    if (!await file.exists()) {
      try {
        await file.writeAsString(jsonEncode([]));
      } catch (e) {
        throw StorageException('Impossible d\'initialiser le fichier de stockage : $e');
      }
    }
    await _readFromFile();
  }

  Future<void> _readFromFile() async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();
      final jsonList = jsonDecode(content) as List<dynamic>;

      _cachedTasks = jsonList.map((item) {
        final map = item as Map<String, dynamic>;
        final id = map['id'] as String;
        final title = map['title'] as String;
        final priorityStr = map['priority'] as String;
        final priority = Priority.fromString(priorityStr);
        final isCompleted = map['isCompleted'] as bool;
        final type = map['type'] as String?;
        final dueDateStr = map['dueDate'] as String?;

        DateTime? dueDate;
        if (dueDateStr != null) {
          dueDate = DateTime.tryParse(dueDateStr);
        }

        if (type == 'Urgent' || priority == Priority.high) {
          return UrgentTask(
            id: id,
            title: title,
            priority: priority,
            dueDate: dueDate,
            isCompleted: isCompleted,
          );
        } else {
          return StandardTask(
            id: id,
            title: title,
            priority: priority,
            dueDate: dueDate,
            isCompleted: isCompleted,
          );
        }
      }).toList();
    } catch (e) {
      if (e is StorageException || e is TaskNotFoundException || e is InvalidInputException) rethrow;
      throw StorageException('Erreur de lecture du fichier JSON : $e');
    }
  }

  @override
  Future<void> save() async {
    try {
      final file = File(filePath);
      final jsonList = _cachedTasks.map((t) => t.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      throw StorageException('Erreur d\'écriture dans le fichier JSON : $e');
    }
  }

  @override
  Future<List<Task>> getAll() async {
    await _readFromFile();
    return List.unmodifiable(_cachedTasks);
  }

  @override
  Future<Task?> getById(String id) async {
    await _readFromFile();
    try {
      return _cachedTasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> add(Task item) async {
    _cachedTasks.add(item);
    await save();
  }

  @override
  Future<void> update(Task item) async {
    final index = _cachedTasks.indexWhere((t) => t.id == item.id);
    if (index == -1) {
      throw TaskNotFoundException('Impossible de mettre à jour : tâche introuvable (ID: ${item.id})');
    }
    _cachedTasks[index] = item;
    await save();
  }

  @override
  Future<void> delete(String id) async {
    final initialLength = _cachedTasks.length;
    _cachedTasks.removeWhere((t) => t.id == id);

    if (_cachedTasks.length == initialLength) {
      throw TaskNotFoundException('Impossible de supprimer : tâche introuvable (ID: $id)');
    }

    await save();
  }
}