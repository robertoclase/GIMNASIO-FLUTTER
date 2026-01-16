import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  String? _selectedExerciseId;
  final Map<RoutineDayType, bool> _expandedDays = {
    RoutineDayType.push: true,
    RoutineDayType.pull: false,
    RoutineDayType.legs: false,
  };

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _formKey = GlobalKey();

  void _scrollToForm() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_formKey.currentContext != null) {
        Scrollable.ensureVisible(
          _formKey.currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _handleQuickLog(String name, String? muscleGroup) {
    final exerciseService = context.read<ExerciseService>();
    final exercise = exerciseService.add(name, muscleGroup: muscleGroup);
    setState(() {
      _selectedExerciseId = exercise.id;
    });
    _scrollToForm();
  }

  void _handleSaveEntry(String exerciseId, String weight, String? reps, String date) {
    final trainingService = context.read<TrainingService>();
    trainingService.add(
      exerciseId: exerciseId,
      weight: weight,
      reps: reps,
      date: date,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ExerciseService, TrainingService>(
      builder: (context, exerciseService, trainingService, child) {
        final exercises = exerciseService.exercises;
        final selectedExercise = exercises.where((e) => e.id == _selectedExerciseId).firstOrNull;

        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Vamos a entrenar! 💪',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Registra tu progreso diario',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Ejercicio seleccionado badge
            if (selectedExercise != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.lavender.withOpacity(0.4),
                          AppTheme.blue.withOpacity(0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.fitness_center, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Registrando:',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppTheme.inkMuted,
                                ),
                              ),
                              Text(
                                selectedExercise.name,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _selectedExerciseId = null;
                            });
                          },
                          icon: const Icon(Icons.close_rounded, size: 20),
                          style: IconButton.styleFrom(
                            backgroundColor: AppTheme.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Formulario de registro
            SliverToBoxAdapter(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: TrainingFormWidget(
                  exercises: exercises,
                  selectedExerciseId: _selectedExerciseId,
                  onSave: _handleSaveEntry,
                ),
              ),
            ),

            // Título rutina
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.peach.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.calendar_view_day, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rutina Push / Pull / Legs',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            'Pulsa "Log" para anotar peso rápidamente',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Días de rutina
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final day = defaultRoutine[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: RoutineDayCard(
                        day: day,
                        isExpanded: _expandedDays[day.key] ?? false,
                        onToggle: () {
                          setState(() {
                            _expandedDays[day.key] = !(_expandedDays[day.key] ?? false);
                          });
                        },
                        onLogExercise: _handleQuickLog,
                      ),
                    );
                  },
                  childCount: defaultRoutine.length,
                ),
              ),
            ),

            // Espacio final
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        );
      },
    );
  }
}
