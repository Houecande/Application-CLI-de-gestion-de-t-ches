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

  JsonTaskRepository(this.filePath);

  Future<void> init() async {
    final file = File(filePath);
    if (!await file.exists()) {
      await file.writeAsString(jsonEncode([]));
    }
  }

  Future<List<Task>> _readAllRaw() async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();
      final jsonList = jsonDecode(content) as List<dynamic>;

      return jsonList.map((item) {
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

        Task task;
        if (type == 'Urgent' || priority == Priority.high) {
          task = UrgentTask(
            id: id,
            title: title,
            priority: priority,
            dueDate: dueDate,
            isCompleted: isCompleted,
          );
        } else {
          task = StandardTask(
            id: id,
            title: title,
            priority: priority,
            dueDate: dueDate,
            isCompleted: isCompleted,
          );
        }
        return task;
      }).toList();
    } catch (e) {
      if (e is StorageException || e is TaskNotFoundException || e is InvalidInputException) {
        rethrow;
      }
      throw StorageException('Erreur lors de la lecture du fichier JSON: $e');
    }
  }

  Future<void> _writeAllRaw(List<Task> tasks) async {
    try {
      final file = File(filePath);
      final jsonList = tasks.map((t) => t.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      throw StorageException('Erreur lors de l\'écriture dans le fichier JSON: $e');
    }
  }

  @override
  Future<List<Task>> getAll() async {
    return await _readAllRaw();
  }

  @override
  Future<Task?> getById(String id) async {
    final tasks = await _readAllRaw();
    try {
      return tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> add(Task item) async {
    final tasks = await _readAllRaw();
    tasks.add(item);
    await _writeAllRaw(tasks);
  }

  @override
  Future<void> update(Task item) async {
    final tasks = await _readAllRaw();
    final index = tasks.indexWhere((t) => t.id == item.id);
    if (index == -1) {
      throw TaskNotFoundException('Impossible de mettre à jour : tâche introuvable (ID: ${item.id})');
    }
    tasks[index] = item;
    await _writeAllRaw(tasks);
  }

  @override
  Future<void> delete(String id) async {
    final tasks = await _readAllRaw();
    final initialLength = tasks.length;
    tasks.removeWhere((t) => t.id == id);

    if (tasks.length == initialLength) {
      throw TaskNotFoundException('Impossible de supprimer : tâche introuvable (ID: $id)');
    }

    await _writeAllRaw(tasks);
  }

  @override
  Future<void> save() async {
    // Méthode requise par l'interface Repository si présente
    final tasks = await _readAllRaw();
    await _writeAllRaw(tasks);
  }
}