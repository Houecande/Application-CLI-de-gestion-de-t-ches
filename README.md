# Application CLI de Gestion de Tâches en Dart

Application en ligne de commande (CLI) construite en Dart permettant de gérer une liste de tâches quotidiennes avec persistance des données sous format JSON.

---

## 🛠️ Exigences Techniques Couvertes

- **Héritage et Classes Abstraites** : Classe abstraite `Task` avec sous-classes `StandardTask` et `UrgentTask`.
- **Interface & Génériques** : `Repository<T>` générique implémenté par `JsonTaskRepository`.
- **Exceptions Personnalisées** : `TaskNotFoundException`, `StorageException`, et `InvalidInputException`.
- **Persistance** : Fichier JSON local (`tasks.json`).
- **Tests Unitaires** : Couverture par au moins 5 tests automatisés.

---

## 🚀 Installation & Lancement

1. S'assurer d'avoir le SDK Dart installé (`dart --version`).
2. Récupérer les dépendances :
   ```bash
   dart pub get
3. Lancer l'application :
   ```bash
   dart run main.dart
   