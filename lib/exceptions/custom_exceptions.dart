// Exception levée lorqu'une tâche est introuvable.
class TaskNotFoundException implements Exception {
  final String message;
  TaskNotFoundException(this.message);

  @override
  String toString() => 'TaskNotFoundException: $message'; 
}

// Exception levée en cas d'erreur de stockage ou de parsing JSON.
class StorageException implements Exception {
  final String message;
  StorageException(this.message);

  @override
  String toString() => 'StorageException: $message';
}

// Exception levée lors de la validation des entrées utilisateur.
class InvalidInputException implements Exception {
  final String message;
  InvalidInputException(this.message);

  @override
  String toString() => 'InvalidInputException: $message';
}