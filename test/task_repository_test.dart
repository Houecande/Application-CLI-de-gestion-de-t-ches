import 'dart:io';
import 'package:test/test.dart';
import 'package:dart_task_cli/models/priority.dart';
import 'package:dart_task_cli/models/standard_task.dart';
import 'package:dart_task_cli/models/urgent_task.dart';
import 'package:dart_task_cli/repositories/json_repository.dart';
import 'package:dart_task_cli/exceptions/custom_exceptions.dart';

void main() {
  const testFilePath = 'test_tasks.json';
  late JsonTaskRepository repository;

  setUp(() async {
    repository = JsonTaskRepository(testFilePath);
    await repository.init();
  });

  tearDown(() async {
    final file = File(testFilePath);
    if (await file.exists()) {
      await file.delete();
    }
  });

  test('1. Ajouter une tâche et la récupérer', () async {
    final task = StandardTask(id: '1', title: 'Test Task', priority: Priority.medium);
    await repository.add(task);

    final tasks = await repository.getAll();
    expect(tasks.length, equals(1));
    expect(tasks.first.title, equals('Test Task'));
  });

  test('2. Distinguer UrgentTask et StandardTask (Héritage & Abstraction)', () async {
    final urgent = UrgentTask(id: '1', title: 'Tâche Urgente');
    final standard = StandardTask(id: '2', title: 'Tâche Normale');

    expect(urgent.getTaskType(), equals('Urgent'));
    expect(standard.getTaskType(), equals('Standard'));
  });

  test('3. Marquer une tâche comme terminée', () async {
    final task = StandardTask(id: '1', title: 'Faire les courses');
    await repository.add(task);

    task.isCompleted = true;
    await repository.update(task);

    final updatedTask = await repository.getById('1');
    expect(updatedTask?.isCompleted, isTrue);
  });

  test('4. Supprimer une tâche', () async {
    final task = StandardTask(id: '1', title: 'A supprimer');
    await repository.add(task);

    await repository.delete('1');
    final tasks = await repository.getAll();
    expect(tasks.isEmpty, isTrue);
  });

  test('5. Lever TaskNotFoundException lors de la suppression d\'un ID inexistant', () async {
    expect(() => repository.delete('999'), throwsA(isA<TaskNotFoundException>()));
  });
}