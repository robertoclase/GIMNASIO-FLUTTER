import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../data/default_data.dart';
import 'storage_service.dart';

class ExerciseService extends ChangeNotifier {
  static const String _key = 'exercises';
  final StorageService _storage;
  final Uuid _uuid = const Uuid();
  
  List<Exercise> _exercises = [];

  ExerciseService(this._storage) {
    _loadFromStorage();
  }

  List<Exercise> get exercises => List.unmodifiable(_exercises);

  void _loadFromStorage() {
    final data = _storage.read<List<dynamic>>(_key, []);

    final existing = data
      .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
      .toList();

    final existingIds = existing.map((e) => e.id).toSet();
    final existingNames = existing
      .map((e) => e.name.toLowerCase().trim())
      .toSet();

    final defaults = defaultExercises
      .map((e) => Exercise.fromJson(e))
      .where((e) =>
        !existingIds.contains(e.id) &&
        !existingNames.contains(e.name.toLowerCase().trim()))
      .toList();

    _exercises = [...existing, ...defaults];
    if (defaults.isNotEmpty) {
      _persist();
    }

    notifyListeners();
  }

  Exercise add(String name, {String? muscleGroup}) {
    final cleanName = name.trim();
    final cleanGroup = muscleGroup?.trim();
    
    final existing = _exercises.firstWhere(
      (e) => e.name.toLowerCase() == cleanName.toLowerCase(),
      orElse: () => Exercise(id: '', name: ''),
    );
    
    if (existing.id.isNotEmpty) {
      return existing;
    }

    final created = Exercise(
      id: _uuid.v4(),
      name: cleanName,
      muscleGroup: cleanGroup?.isNotEmpty == true ? cleanGroup : null,
    );

    _exercises = [..._exercises, created];
    _persist();
    return created;
  }

  void update(Exercise updated) {
    _exercises = _exercises.map((e) => e.id == updated.id ? updated : e).toList();
    _persist();
  }

  void remove(String id) {
    _exercises = _exercises.where((e) => e.id != id).toList();
    _persist();
  }

  void replaceAll(List<Exercise> next) {
    _exercises = next;
    _persist();
  }

  void _persist() {
    _storage.write(_key, _exercises.map((e) => e.toJson()).toList());
    notifyListeners();
  }
}
