# 📋 Application CLI de Gestion de Tâches en Dart

Une application en ligne de commande (CLI) modulaire et robuste construite en **Dart pur**, permettant de gérer efficacement des tâches quotidiennes avec persistance JSON locale.

---

## 🏗️ Architecture du Projet

- `lib/models/` : Modèles POO (`Task`, `StandardTask`, `UrgentTask`, `Priority`).
- `lib/repositories/` : Implémentation du stockage persistant JSON (`JsonTaskRepository`).
- `lib/interfaces/` : Contrats d'interfaces génériques (`Repository<T>`).
- `lib/exceptions/` : Exceptions métier sur-mesure.
- `bin/main.dart` : Interface CLI interactive.
- `test/` : Suite complète de tests unitaires automatisés.

---

## 🚀 Guide d'Exécution

### 1. Lancer l'application :
```bash
dart run bin/main.dart