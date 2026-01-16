import 'package:flutter/foundation.dart';

@immutable
class RoutineExercise {
  final String name;
  final String detail;
  final String? muscleGroup;

  const RoutineExercise({
    required this.name,
    required this.detail,
    this.muscleGroup,
  });
}

enum RoutineDayType { push, pull, legs }

@immutable
class RoutineDay {
  final RoutineDayType key;
  final String title;
  final String icon;
  final List<String> warmup;
  final List<RoutineExercise> training;
  final List<String>? finish;

  const RoutineDay({
    required this.key,
    required this.title,
    required this.icon,
    required this.warmup,
    required this.training,
    this.finish,
  });
}

enum Trend { up, down, equal, solo }

const List<RoutineDay> defaultRoutine = [
  RoutineDay(
    key: RoutineDayType.push,
    title: 'PUSH (empuje)',
    icon: '💪',
    warmup: [
      'Manguito rotador 2-3 ejercicios con goma',
      'Series de aproximación del press principal',
    ],
    training: [
      RoutineExercise(name: 'Press de banca con barra', detail: '4x6-8 (fuerza)', muscleGroup: 'Pecho'),
      RoutineExercise(name: 'Press de banca inclinado con máquina', detail: '3x8-10 (fuerza e hipertrofia)', muscleGroup: 'Pecho'),
      RoutineExercise(name: 'Pec Deck', detail: '3x12-15 (hipertrofia)', muscleGroup: 'Pecho'),
      RoutineExercise(name: 'Extensión de tríceps en polea', detail: '3x10-12 (hipertrofia)', muscleGroup: 'Tríceps'),
      RoutineExercise(name: 'Tríceps katana', detail: '2x12-15 (hipertrofia)', muscleGroup: 'Tríceps'),
      RoutineExercise(name: 'Crunch en polea', detail: '3x12-15 (hipertrofia)', muscleGroup: 'Core'),
      RoutineExercise(name: 'Crunch abdominal con discos', detail: '3x10-12 (hipertrofia) *', muscleGroup: 'Core'),
      RoutineExercise(name: 'Russian twists', detail: '3x12-15 (hipertrofia) *', muscleGroup: 'Core'),
    ],
    finish: ['Colgarse de la barra 1-2x30-60s'],
  ),
  RoutineDay(
    key: RoutineDayType.pull,
    title: 'PULL (tirón)',
    icon: '🔥',
    warmup: [
      '5 min remo en máquina',
      'Movilidad escapular',
      '2 series ligeras de jalón',
    ],
    training: [
      RoutineExercise(name: 'Dominadas asistidas/libres', detail: '4x6-8 (fuerza)', muscleGroup: 'Espalda'),
      RoutineExercise(name: 'Remo con barra', detail: '4x8-10 (fuerza e hipertrofia)', muscleGroup: 'Espalda'),
      RoutineExercise(name: 'Jalón al pecho', detail: '3x10-12 (fuerza e hipertrofia)', muscleGroup: 'Espalda'),
      RoutineExercise(name: 'Rear delt en Pec Deck inverso', detail: '3x12-15 (hipertrofia)', muscleGroup: 'Hombro'),
      RoutineExercise(name: 'Curl de bíceps martillo con mancuernas', detail: '3x8-10 (hipertrofia)', muscleGroup: 'Bíceps'),
      RoutineExercise(name: 'Curl predicador', detail: '2x10-12 (hipertrofia)', muscleGroup: 'Bíceps'),
      RoutineExercise(name: 'Curl de bíceps con mancuernas', detail: '3x12-15 (hipertrofia) *', muscleGroup: 'Bíceps'),
      RoutineExercise(name: 'Elevaciones frontales con mancuernas', detail: '3x12-15 (hipertrofia) *', muscleGroup: 'Hombro'),
      RoutineExercise(name: 'Elevaciones laterales con mancuernas', detail: '3x12-15 (hipertrofia) *', muscleGroup: 'Hombro'),
    ],
    finish: ['Colgarse de la barra 1-2x30-60 s'],
  ),
  RoutineDay(
    key: RoutineDayType.legs,
    title: 'LEGS (pierna)',
    icon: '🦵',
    warmup: [
      '5-7 min andando',
      'Movilidad cadera/rodilla/tobillo/femoral',
      'Activación de glúteo y core',
    ],
    training: [
      RoutineExercise(name: 'Sentadilla con barra', detail: '4x6-8 (fuerza)', muscleGroup: 'Pierna'),
      RoutineExercise(name: 'Peso muerto rumano', detail: '3x8-10 (hipertrofia)', muscleGroup: 'Pierna'),
      RoutineExercise(name: 'Extensión de cuádriceps', detail: '3x12-15 (hipertrofia)', muscleGroup: 'Cuádriceps'),
      RoutineExercise(name: 'Curl femoral', detail: '3x10-12 (hipertrofia)', muscleGroup: 'Femoral'),
      RoutineExercise(name: 'Hip Thrust', detail: '3x8-10 (hipertrofia)', muscleGroup: 'Glúteo'),
      RoutineExercise(name: 'Adductores en máquina', detail: '2x15-20 (hipertrofia)', muscleGroup: 'Aductores'),
      RoutineExercise(name: 'Abductores en máquina', detail: '2x15-20 (hipertrofia) *', muscleGroup: 'Glúteo'),
      RoutineExercise(name: 'Elevaciones de talones de pie', detail: '4x12-15 (hipertrofia) *', muscleGroup: 'Gemelos'),
    ],
  ),
];
