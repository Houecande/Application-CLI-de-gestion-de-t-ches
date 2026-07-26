import 'dart:io';
import 'package:test/test.dart';
import 'package:dart_task_cli/models/priority.dart';
import 'package:dart_task_cli/models/standard_task.dart';
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

  group('Tests de l\'application CLI & Repository', () {
    test('1. Ajout et stockage d\'une tâche', () async {
      final task = StandardTask(id: '1', title: 'Faire les courses');
      await repository.add(task);

      final tasks = await repository.getAll();
      expect(tasks.length, equals(1));
      expect(tasks.first.title, equals('Faire les courses'));
    });

    test('2. Modification d\'une tâche existante', () async {
      final task = StandardTask(id: '2', title: 'Titre initial');
      await repository.add(task);

      final updatedTask = StandardTask(id: '2', title: 'Titre Modifié', priority: Priority.high);
      await repository.update(updatedTask);

      final fetched = await repository.getById('2');
      expect(fetched?.title, equals('Titre Modifié'));
    });

    test('3. Marquer une tâche comme terminée', () async {
      final task = StandardTask(id: '3', title: 'Tâche à terminer');
      await repository.add(task);

      task.isCompleted = true;
      await repository.update(task);

      final fetched = await repository.getById('3');
      expect(fetched?.isCompleted, isTrue);
    });

    test('4. Suppression d\'une tâche', () async {
      final task = StandardTask(id: '4', title: 'À supprimer');
      await repository.add(task);

      await repository.delete('4');
      final tasks = await repository.getAll();
      expect(tasks.isEmpty, isTrue);
    });

    test('5. Gestion d\'exception si tâche non trouvée', () async {
      expect(() => repository.delete('999'), throwsA(isA<TaskNotFoundException>()));
    });
  });
}