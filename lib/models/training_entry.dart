import 'package:flutter/foundation.dart';

@immutable
class TrainingEntry {
  final String id;
  final String exerciseId;
  final String weight;
  final String? reps;
  final String date; // ISO string (yyyy-MM-dd)

  const TrainingEntry({
    required this.id,
    required this.exerciseId,
    required this.weight,
    this.reps,
    required this.date,
  });

  TrainingEntry copyWith({
    String? id,
    String? exerciseId,
    String? weight,
    String? reps,
    String? date,
  }) {
    return TrainingEntry(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'weight': weight,
      'reps': reps,
      'date': date,
    };
  }

  factory TrainingEntry.fromJson(Map<String, dynamic> json) {
    return TrainingEntry(
      id: json['id'] as String,
      exerciseId: json['exerciseId'] as String,
      weight: json['weight'] as String,
      reps: json['reps'] as String?,
      date: json['date'] as String,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrainingEntry && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
