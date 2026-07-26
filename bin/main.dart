import 'dart:io';
import 'package:dart_task_cli/exceptions/custom_exceptions.dart';
import 'package:dart_task_cli/models/priority.dart';
import 'package:dart_task_cli/models/standard_task.dart';
import 'package:dart_task_cli/models/task.dart';
import 'package:dart_task_cli/models/urgent_task.dart';
import 'package:dart_task_cli/repositories/json_repository.dart';

void main() async {
  final repository = JsonTaskRepository('tasks.json');
  await repository.init();

  print('     ______GESTIONNAIRE DE TÂCHES (CLI) ______     ');

  bool running = true;

  while (running) {
    print('\n--- MENU PRINCIPAL ---');
    print('1. Ajouter une tâche');
    print('2. Lister les tâches');
    print('3. Marquer une tâche comme terminée');
    print('4. Supprimer une tâche');
    print('5. Quitter');
    stdout.write('Choisissez une option (1-5) : ');

    final choice = stdin.readLineSync();

    try {
      switch (choice) {
        case '1':
          await _addTask(repository);
          break;
        case '2':
          await _listTasks(repository);
          break;
        case '3':
          await _completeTask(repository);
          break;
        case '4':
          await _deleteTask(repository);
          break;
        case '5':
          running = false;
          print('Au revoir !');
          break;
        default:
          print('Option invalide, veuillez réespayer.');
      }
    } catch (e) {
      print('Erreur : $e');
    }
  }
}

Future<void> _addTask(JsonTaskRepository repo) async {
  stdout.write('Titre de la tâche : ');
  final title = stdin.readLineSync() ?? '';
  if (title.trim().isEmpty) {
    throw InvalidInputException('Le titre ne peut pas être vide.');
  }

  stdout.write('Priorité (low, medium, high) [default: medium] : ');
  final priorityInput = stdin.readLineSync() ?? 'medium';
  final priority = Priority.fromString(priorityInput.isEmpty ? 'medium' : priorityInput);

  stdout.write('Date limite (AAAA-MM-JJ) (optionnelle) : ');
  final dateInput = stdin.readLineSync();
  DateTime? dueDate;
  if (dateInput != null && dateInput.trim().isNotEmpty) {
    try {
      dueDate = DateTime.parse(dateInput.trim());
    } catch (_) {
      throw InvalidInputException('Format de date invalide. Utilisez AAAA-MM-JJ.');
    }
  }

  final id = DateTime.now().millisecondsSinceEpoch.toString();

  Task task;
  if (priority == Priority.high) {
    task = UrgentTask(id: id, title: title, priority: priority, dueDate: dueDate);
  } else {
    task = StandardTask(id: id, title: title, priority: priority, dueDate: dueDate);
  }

  await repo.add(task);
  print('Tâche ajoutée avec succès ! (ID: $id)');
}

Future<void> _listTasks(JsonTaskRepository repo) async {
  final tasks = await repo.getAll();

  if (tasks.isEmpty) {
    print('Aucune tâche enregistrée.');
    return;
  }

  print('\nTrier par : 1. Priorité | 2. Date limite | 3. Ordre par défaut');
  stdout.write('Choix du tri (1-3) : ');
  final sortChoice = stdin.readLineSync();

  List<Task> sortedList = List.from(tasks);

  if (sortChoice == '1') {
    sortedList.sort((a, b) => b.priority.value.compareTo(a.priority.value));
  } else if (sortChoice == '2') {
    sortedList.sort((a, b) {
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });
  }

  print('\n=== LISTE DES TÂCHES ===');
  for (var t in sortedList) {
    final status = t.isCompleted ? '[✓]' : '[ ]';
    final dateStr = t.dueDate != null ? ' (Échéance: ${t.dueDate.toString().split(' ')[0]})' : '';
    print('$status ID: ${t.id} | [${t.getTaskType().toUpperCase()}] ${t.title} - Priorité: ${t.priority.name.toUpperCase()}$dateStr');
  }
}

Future<void> _completeTask(JsonTaskRepository repo) async {
  stdout.write('ID de la tâche à marquer comme terminée : ');
  final id = stdin.readLineSync() ?? '';
  final task = await repo.getById(id);

  if (task == null) {
    throw TaskNotFoundException('Aucune tâche ne correspond à l\'ID : $id');
  }

  task.isCompleted = true;
  await repo.update(task);
  print('Tâche marquée comme terminée !');
}

Future<void> _deleteTask(JsonTaskRepository repo) async {
  stdout.write('ID de la tâche à supprimer : ');
  final id = stdin.readLineSync() ?? '';
  await repo.delete(id);
  print('Tâche supprimée avec succès !');
}