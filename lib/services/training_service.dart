import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../data/default_data.dart';
import 'storage_service.dart';

class TrainingService extends ChangeNotifier {
  static const String _key = 'training_entries';
  final StorageService _storage;
  final Uuid _uuid = const Uuid();
  
  List<TrainingEntry> _entries = [];

  TrainingService(this._storage) {
    _loadFromStorage();
  }

  List<TrainingEntry> get entries {
    final sorted = List<TrainingEntry>.from(_entries);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  void _loadFromStorage() {
    final data = _storage.read<List<dynamic>>(_key, []);

    final existing = data
        .map((e) => TrainingEntry.fromJson(e as Map<String, dynamic>))
        .toList();

    final existingIds = existing.map((e) => e.id).toSet();

    final defaults = defaultEntries
        .map((e) => TrainingEntry.fromJson(e))
        .where((e) => !existingIds.contains(e.id))
        .toList();

    _entries = [...existing, ...defaults];
    if (defaults.isNotEmpty) {
      _persist();
    }

    notifyListeners();
  }

  TrainingEntry add({
    required String exerciseId,
    required String weight,
    String? reps,
    required String date,
  }) {
    final entry = TrainingEntry(
      id: _uuid.v4(),
      exerciseId: exerciseId,
      weight: weight,
      reps: reps,
      date: date,
    );

    _entries = [entry, ..._entries];
    _persist();
    return entry;
  }

  void update(TrainingEntry entry) {
    final exists = _entries.any((e) => e.id == entry.id);
    if (!exists) return;
    
    _entries = _entries.map((e) => e.id == entry.id ? entry : e).toList();
    _persist();
  }

  void remove(String id) {
    _entries = _entries.where((e) => e.id != id).toList();
    _persist();
  }

  void clearForExercise(String exerciseId) {
    _entries = _entries.where((e) => e.exerciseId != exerciseId).toList();
    _persist();
  }

  void replaceAll(List<TrainingEntry> next) {
    _entries = next;
    _persist();
  }

  List<TrainingEntry> entriesForExercise(String exerciseId) {
    return entries.where((e) => e.exerciseId == exerciseId).toList();
  }

  void _persist() {
    _storage.write(_key, _entries.map((e) => e.toJson()).toList());
    notifyListeners();
  }
}
