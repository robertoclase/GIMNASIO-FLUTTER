import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  RoutineDayType? _selectedDay;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Consumer2<ExerciseService, TrainingService>(
            builder: (context, exerciseService, trainingService, child) {
              final todayEntries = _getTodayEntries(trainingService);
              
              return CustomScrollView(
                slivers: [
                  // Header minimalista estilo Apple
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getGreeting(),
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppTheme.inkMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          'Mara',
                                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -1,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '❤️',
                                          style: Theme.of(context).textTheme.headlineLarge,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              _buildSettingsButton(context),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tarjeta de resumen del día
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: _buildTodaySummaryCard(context, todayEntries, exerciseService),
                    ),
                  ),

                  // Selector de día de entrenamiento
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 12),
                            child: Text(
                              '¿Qué entrenas hoy?',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              _buildDayChip(context, RoutineDayType.push, '💪', 'Push'),
                              const SizedBox(width: 10),
                              _buildDayChip(context, RoutineDayType.pull, '🔥', 'Pull'),
                              const SizedBox(width: 10),
                              _buildDayChip(context, RoutineDayType.legs, '🦵', 'Legs'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Lista de ejercicios del día seleccionado
                  if (_selectedDay != null) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                        child: Row(
                          children: [
                            Text(
                              'Ejercicios',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Toca para registrar',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildExercisesList(context, exerciseService, trainingService),
                  ] else
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppTheme.lavender.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Text('🏋️', style: TextStyle(fontSize: 48)),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Selecciona tu día de entrenamiento',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.inkMuted,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              );
            },
          ),
        ),
      ),
      // FAB para acceso rápido al historial
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showHistorySheet(context),
        backgroundColor: AppTheme.lavender,
        foregroundColor: AppTheme.inkStrong,
        elevation: 2,
        icon: const Icon(Icons.history_rounded),
        label: const Text('Historial', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  String _getGreeting() {
    return 'Te amoooo AMOOOOOR';
  }

  List<TrainingEntry> _getTodayEntries(TrainingService service) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return service.entries.where((e) => e.date == today).toList();
  }

  Widget _buildSettingsButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: IconButton(
        onPressed: () => _showSettingsSheet(context),
        icon: const Icon(Icons.more_horiz_rounded),
        color: AppTheme.inkMuted,
      ),
    );
  }

  Widget _buildTodaySummaryCard(BuildContext context, List<TrainingEntry> todayEntries, ExerciseService exerciseService) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.lavender.withOpacity(0.4),
            AppTheme.blue.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.today_rounded, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hoy',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      DateFormat('EEEE, d MMM', 'es').format(DateTime.now()),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(
                context,
                '${todayEntries.length}',
                'Registros',
                Icons.fitness_center_rounded,
              ),
              const SizedBox(width: 16),
              _buildStatItem(
                context,
                '${_getUniqueExercisesCount(todayEntries)}',
                'Ejercicios',
                Icons.category_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _getUniqueExercisesCount(List<TrainingEntry> entries) {
    return entries.map((e) => e.exerciseId).toSet().length;
  }

  Widget _buildStatItem(BuildContext context, String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.inkMuted),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.inkMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayChip(BuildContext context, RoutineDayType type, String emoji, String label) {
    final isSelected = _selectedDay == type;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() {
            _selectedDay = _selectedDay == type ? null : type;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.lavender : AppTheme.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? AppTheme.lavender : AppTheme.grayLavender.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.lavender.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: AppTheme.inkStrong,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExercisesList(BuildContext context, ExerciseService exerciseService, TrainingService trainingService) {
    final day = defaultRoutine.firstWhere((d) => d.key == _selectedDay);
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final exercise = day.training[index];
            
            // Buscar si ya tiene registro hoy
            final existingExercise = exerciseService.exercises
                .where((e) => e.name == exercise.name)
                .firstOrNull;
            final todayEntry = existingExercise != null
                ? trainingService.entries
                    .where((e) => e.exerciseId == existingExercise.id && e.date == today)
                    .firstOrNull
                : null;
            
            // Último peso registrado
            final lastEntry = existingExercise != null
                ? trainingService.entriesForExercise(existingExercise.id).firstOrNull
                : null;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ExerciseListTile(
                exercise: exercise,
                todayEntry: todayEntry,
                lastEntry: lastEntry,
                onTap: () => _showLogSheet(
                  context,
                  exercise,
                  existingExercise,
                  exerciseService,
                  trainingService,
                ),
              ),
            );
          },
          childCount: day.training.length,
        ),
      ),
    );
  }

  void _showLogSheet(
    BuildContext context,
    RoutineExercise routineExercise,
    Exercise? existingExercise,
    ExerciseService exerciseService,
    TrainingService trainingService,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LogBottomSheet(
        routineExercise: routineExercise,
        existingExercise: existingExercise,
        exerciseService: exerciseService,
        trainingService: trainingService,
      ),
    );
  }

  void _showHistorySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const HistoryBottomSheet(),
    );
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const SettingsBottomSheet(),
    );
  }
}

// Tile individual de ejercicio
class _ExerciseListTile extends StatelessWidget {
  final RoutineExercise exercise;
  final TrainingEntry? todayEntry;
  final TrainingEntry? lastEntry;
  final VoidCallback onTap;

  const _ExerciseListTile({
    required this.exercise,
    this.todayEntry,
    this.lastEntry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasLoggedToday = todayEntry != null;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: hasLoggedToday 
              ? AppTheme.green.withOpacity(0.15) 
              : AppTheme.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: hasLoggedToday
                ? AppTheme.green.withOpacity(0.4)
                : AppTheme.grayLavender.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            // Indicador de completado
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: hasLoggedToday
                    ? AppTheme.green.withOpacity(0.3)
                    : AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                hasLoggedToday ? Icons.check_rounded : Icons.fitness_center_rounded,
                color: hasLoggedToday ? AppTheme.inkStrong : AppTheme.inkMuted,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            
            // Info del ejercicio
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          exercise.detail,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.inkMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (lastEntry != null) ...[
                        const SizedBox(width: 8),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 110),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${lastEntry!.weight} kg',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.inkStrong,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            
            // Flecha o peso de hoy
            if (hasLoggedToday)
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 90),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.green.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${todayEntry!.weight} kg',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppTheme.lavender.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppTheme.lavender,
                    size: 20,
                  ),
                ),
                if (hasLoggedToday)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppTheme.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: AppTheme.inkStrong,
                        size: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Bottom Sheet para registrar peso
class LogBottomSheet extends StatefulWidget {
  final RoutineExercise routineExercise;
  final Exercise? existingExercise;
  final ExerciseService exerciseService;
  final TrainingService trainingService;

  const LogBottomSheet({
    super.key,
    required this.routineExercise,
    this.existingExercise,
    required this.exerciseService,
    required this.trainingService,
  });

  @override
  State<LogBottomSheet> createState() => _LogBottomSheetState();
}

class _LogBottomSheetState extends State<LogBottomSheet> {
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Pre-rellenar con el último peso
    if (widget.existingExercise != null) {
      final lastEntry = widget.trainingService
          .entriesForExercise(widget.existingExercise!.id)
          .firstOrNull;
      if (lastEntry != null) {
        _weightController.text = lastEntry.weight;
        _repsController.text = lastEntry.reps ?? '';
      }
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _save() {
    if (_weightController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el peso')),
      );
      return;
    }

    // Crear o usar ejercicio existente
    Exercise exercise;
    if (widget.existingExercise != null) {
      exercise = widget.existingExercise!;
    } else {
      exercise = widget.exerciseService.add(
        widget.routineExercise.name,
        muscleGroup: widget.routineExercise.muscleGroup,
      );
    }

    // Guardar entrada
    widget.trainingService.add(
      exerciseId: exercise.id,
      weight: _weightController.text.trim(),
      reps: _repsController.text.trim().isEmpty ? null : _repsController.text.trim(),
      date: DateFormat('yyyy-MM-dd').format(_selectedDate),
    );

    HapticFeedback.mediumImpact();
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text('${widget.routineExercise.name} guardado'),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final history = widget.existingExercise != null
        ? widget.trainingService.entriesForExercise(widget.existingExercise!.id)
        : <TrainingEntry>[];

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.grayLavender.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.lavender.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.fitness_center, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.routineExercise.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.routineExercise.detail,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.surface,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Formulario de entrada
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.cardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nuevo registro',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Peso y Reps
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Peso (kg)',
                                    style: Theme.of(context).textTheme.labelMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _weightController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      hintText: '0.0',
                                      filled: true,
                                      fillColor: AppTheme.blue.withOpacity(0.1),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(vertical: 20),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Reps',
                                    style: Theme.of(context).textTheme.labelMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _repsController,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      hintText: '0',
                                      filled: true,
                                      fillColor: AppTheme.green.withOpacity(0.15),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(vertical: 20),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Fecha
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now().add(const Duration(days: 1)),
                            );
                            if (picked != null) {
                              setState(() => _selectedDate = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 20, color: AppTheme.inkMuted),
                                const SizedBox(width: 12),
                                Text(
                                  DateFormat('EEEE, d MMM yyyy', 'es').format(_selectedDate),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const Spacer(),
                                const Icon(Icons.edit, size: 18, color: AppTheme.inkMuted),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Botón guardar
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _save,
                            icon: const Icon(Icons.check_rounded),
                            label: const Text('Guardar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.lavender,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Historial del ejercicio (visible inmediatamente)
                  if (history.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Text(
                          'Historial',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${history.length}',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...history.take(10).map((entry) => _buildHistoryItem(context, entry, canEdit: true)),
                    if (history.length > 10)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '+${history.length - 10} registros más',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.inkMuted,
                          ),
                        ),
                      ),
                  ] else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.history_rounded,
                              size: 48,
                              color: AppTheme.inkMuted.withOpacity(0.3),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Sin historial aún',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.inkMuted,
                              ),
                            ),
                            Text(
                              'Este será tu primer registro',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, TrainingEntry entry, {bool canEdit = false}) {
    return GestureDetector(
      onLongPress: canEdit ? () => _showEntryOptions(context, entry) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.grayLavender.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Text(
              DateFormat('dd/MM/yy').format(DateTime.parse(entry.date)),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.inkMuted,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.blue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${entry.weight} kg',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (entry.reps != null) ...[
              const SizedBox(width: 8),
              Text(
                '${entry.reps} reps',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.inkMuted,
                ),
              ),
            ],
            if (canEdit) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showEntryOptions(context, entry),
                child: Icon(
                  Icons.more_vert,
                  size: 20,
                  color: AppTheme.inkMuted.withOpacity(0.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showEntryOptions(BuildContext context, TrainingEntry entry) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        decoration: const BoxDecoration(
          color: AppTheme.cream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.grayLavender.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Opciones del registro',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${entry.weight} kg • ${DateFormat('dd/MM/yyyy').format(DateTime.parse(entry.date))}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.inkMuted,
              ),
            ),
            const SizedBox(height: 20),
            
            // Editar
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.edit_rounded, color: AppTheme.inkStrong),
              ),
              title: const Text('Editar registro'),
              subtitle: const Text('Cambiar peso, reps o fecha'),
              onTap: () {
                Navigator.pop(ctx);
                _showEditDialog(context, entry);
              },
            ),
            
            // Eliminar
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete_rounded, color: AppTheme.error),
              ),
              title: const Text('Eliminar registro'),
              subtitle: const Text('Esta acción no se puede deshacer'),
              onTap: () {
                Navigator.pop(ctx);
                _showDeleteConfirmation(context, entry);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, TrainingEntry entry) {
    final weightController = TextEditingController(text: entry.weight);
    final repsController = TextEditingController(text: entry.reps ?? '');
    DateTime selectedDate = DateTime.parse(entry.date);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            decoration: const BoxDecoration(
              color: AppTheme.cream,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.grayLavender.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Editar registro',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Peso y Reps
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Peso (kg)', style: Theme.of(context).textTheme.labelMedium),
                          const SizedBox(height: 8),
                          TextField(
                            controller: weightController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppTheme.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Reps', style: Theme.of(context).textTheme.labelMedium),
                          const SizedBox(height: 8),
                          TextField(
                            controller: repsController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppTheme.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Fecha
                Text('Fecha', style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 1)),
                    );
                    if (picked != null) {
                      setModalState(() => selectedDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20, color: AppTheme.inkMuted),
                        const SizedBox(width: 12),
                        Text(
                          DateFormat('dd/MM/yyyy').format(selectedDate),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Botones
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final updated = TrainingEntry(
                            id: entry.id,
                            exerciseId: entry.exerciseId,
                            weight: weightController.text.trim(),
                            reps: repsController.text.trim().isEmpty ? null : repsController.text.trim(),
                            date: DateFormat('yyyy-MM-dd').format(selectedDate),
                          );
                          widget.trainingService.update(updated);
                          Navigator.pop(ctx);
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(width: 12),
                                  Text('Registro actualizado'),
                                ],
                              ),
                              backgroundColor: AppTheme.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.lavender,
                        ),
                        child: const Text('Guardar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, TrainingEntry entry) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Eliminar registro?'),
        content: Text(
          'Se eliminará el registro de ${entry.weight} kg del ${DateFormat('dd/MM/yyyy').format(DateTime.parse(entry.date))}.\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.trainingService.remove(entry.id);
              Navigator.pop(ctx);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Registro eliminado'),
                    ],
                  ),
                  backgroundColor: AppTheme.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

// Bottom Sheet de Historial completo
class HistoryBottomSheet extends StatefulWidget {
  const HistoryBottomSheet({super.key});

  @override
  State<HistoryBottomSheet> createState() => _HistoryBottomSheetState();
}

class _HistoryBottomSheetState extends State<HistoryBottomSheet> {
  String? _selectedExerciseId;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Consumer2<ExerciseService, TrainingService>(
        builder: (context, exerciseService, trainingService, child) {
          final exercises = List<Exercise>.from(exerciseService.exercises)
            ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
          final historyEntries = _selectedExerciseId != null
              ? trainingService.entriesForExercise(_selectedExerciseId!)
              : <TrainingEntry>[];

          return Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.grayLavender.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.blue.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.history_rounded, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Historial completo',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${exercises.length} ejercicios • ${trainingService.entries.length} registros',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.surface,
                      ),
                    ),
                  ],
                ),
              ),

              // Contenido
              Expanded(
                child: exercises.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.fitness_center_outlined,
                              size: 64,
                              color: AppTheme.inkMuted.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Sin ejercicios registrados',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.inkMuted,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Registra tu primer ejercicio\ndesde el dashboard',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.inkMuted,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : Row(
                        children: [
                          // Lista de ejercicios (izquierda)
                          SizedBox(
                            width: 140,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 0, 8, 16),
                              itemCount: exercises.length,
                              itemBuilder: (context, index) {
                                final exercise = exercises[index];
                                final isSelected = _selectedExerciseId == exercise.id;
                                final entryCount = trainingService
                                    .entriesForExercise(exercise.id)
                                    .length;
                                
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedExerciseId = exercise.id;
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppTheme.lavender
                                          : AppTheme.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppTheme.lavender
                                            : AppTheme.grayLavender.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          exercise.name,
                                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$entryCount regs',
                                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                            color: AppTheme.inkMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          // Detalle del historial (derecha)
                          Expanded(
                            child: _selectedExerciseId == null
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.touch_app_outlined,
                                          size: 48,
                                          color: AppTheme.inkMuted.withOpacity(0.3),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Selecciona un ejercicio',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: AppTheme.inkMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.fromLTRB(8, 0, 16, 16),
                                    itemCount: historyEntries.length,
                                    itemBuilder: (context, index) {
                                      final entry = historyEntries[index];
                                      return GestureDetector(
                                        onLongPress: () => _showEntryOptions(context, entry, trainingService),
                                        child: Container(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: AppTheme.white,
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(
                                            color: AppTheme.grayLavender.withOpacity(0.2),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    DateFormat('dd MMM yyyy', 'es')
                                                        .format(DateTime.parse(entry.date)),
                                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                      color: AppTheme.inkMuted,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    DateFormat('EEEE', 'es')
                                                        .format(DateTime.parse(entry.date)),
                                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                      color: AppTheme.inkMuted,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.blue.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Text(
                                                    '${entry.weight} kg',
                                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                                if (entry.reps != null) ...[
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    '${entry.reps}r',
                                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                      color: AppTheme.inkMuted,
                                                    ),
                                                  ),
                                                ],
                                                const SizedBox(width: 8),
                                                GestureDetector(
                                                  onTap: () => _showEntryOptions(context, entry, trainingService),
                                                  child: Icon(
                                                    Icons.more_vert,
                                                    size: 20,
                                                    color: AppTheme.inkMuted.withOpacity(0.5),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEntryOptions(BuildContext context, TrainingEntry entry, TrainingService trainingService) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        decoration: const BoxDecoration(
          color: AppTheme.cream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.grayLavender.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Opciones del registro',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${entry.weight} kg • ${DateFormat('dd/MM/yyyy').format(DateTime.parse(entry.date))}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.inkMuted,
              ),
            ),
            const SizedBox(height: 20),
            
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.edit_rounded, color: AppTheme.inkStrong),
              ),
              title: const Text('Editar registro'),
              subtitle: const Text('Cambiar peso, reps o fecha'),
              onTap: () {
                Navigator.pop(ctx);
                _showEditDialog(context, entry, trainingService);
              },
            ),
            
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete_rounded, color: AppTheme.error),
              ),
              title: const Text('Eliminar registro'),
              subtitle: const Text('Esta acción no se puede deshacer'),
              onTap: () {
                Navigator.pop(ctx);
                _showDeleteConfirmation(context, entry, trainingService);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, TrainingEntry entry, TrainingService trainingService) {
    final weightController = TextEditingController(text: entry.weight);
    final repsController = TextEditingController(text: entry.reps ?? '');
    DateTime selectedDate = DateTime.parse(entry.date);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            decoration: const BoxDecoration(
              color: AppTheme.cream,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.grayLavender.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Editar registro',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Peso (kg)', style: Theme.of(context).textTheme.labelMedium),
                          const SizedBox(height: 8),
                          TextField(
                            controller: weightController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppTheme.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Reps', style: Theme.of(context).textTheme.labelMedium),
                          const SizedBox(height: 8),
                          TextField(
                            controller: repsController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppTheme.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                Text('Fecha', style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 1)),
                    );
                    if (picked != null) {
                      setModalState(() => selectedDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20, color: AppTheme.inkMuted),
                        const SizedBox(width: 12),
                        Text(
                          DateFormat('dd/MM/yyyy').format(selectedDate),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final updated = TrainingEntry(
                            id: entry.id,
                            exerciseId: entry.exerciseId,
                            weight: weightController.text.trim(),
                            reps: repsController.text.trim().isEmpty ? null : repsController.text.trim(),
                            date: DateFormat('yyyy-MM-dd').format(selectedDate),
                          );
                          trainingService.update(updated);
                          Navigator.pop(ctx);
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(width: 12),
                                  Text('Registro actualizado'),
                                ],
                              ),
                              backgroundColor: AppTheme.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.lavender,
                        ),
                        child: const Text('Guardar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, TrainingEntry entry, TrainingService trainingService) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Eliminar registro?'),
        content: Text(
          'Se eliminará el registro de ${entry.weight} kg del ${DateFormat('dd/MM/yyyy').format(DateTime.parse(entry.date))}.\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              trainingService.remove(entry.id);
              Navigator.pop(ctx);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Registro eliminado'),
                    ],
                  ),
                  backgroundColor: AppTheme.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

// Bottom Sheet de Configuración
class SettingsBottomSheet extends StatelessWidget {
  const SettingsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: const BoxDecoration(
        color: AppTheme.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.grayLavender.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          
          // Exportar
          _SettingsTile(
            icon: Icons.upload_rounded,
            title: 'Exportar datos',
            subtitle: 'Guarda una copia de seguridad',
            onTap: () {
              Navigator.pop(context);
              _exportData(context);
            },
          ),
          const SizedBox(height: 12),
          
          // Importar
          _SettingsTile(
            icon: Icons.download_rounded,
            title: 'Importar datos',
            subtitle: 'Restaura desde un archivo',
            onTap: () {
              Navigator.pop(context);
              _importData(context);
            },
          ),
          const SizedBox(height: 12),
          
          // Info
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'Acerca de',
            subtitle: 'Mara Gym v1.0',
            onTap: () {
              Navigator.pop(context);
              _showAbout(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    // Usar la lógica existente de export
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final exerciseService = context.read<ExerciseService>();
      final trainingService = context.read<TrainingService>();
      
      final data = {
        'exercises': exerciseService.exercises.map((e) => e.toJson()).toList(),
        'entries': trainingService.entries.map((e) => e.toJson()).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final fileName = 'mara-gym-respaldo-$date.json';

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Respaldo de Mara Gym',
      );

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Datos exportados'),
            ],
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  Future<void> _importData(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return;

      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final parsed = jsonDecode(content) as Map<String, dynamic>;

      if (!parsed.containsKey('exercises') || !parsed.containsKey('entries')) {
        throw Exception('Formato inválido');
      }

      final exercises = (parsed['exercises'] as List)
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList();
      final entries = (parsed['entries'] as List)
          .map((e) => TrainingEntry.fromJson(e as Map<String, dynamic>))
          .toList();

      // ignore: use_build_context_synchronously
      context.read<ExerciseService>().replaceAll(exercises);
      // ignore: use_build_context_synchronously
      context.read<TrainingService>().replaceAll(entries);

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Datos importados'),
            ],
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Text('Error al importar'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.lavender.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('🏋️', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            const Text('Mara Gym'),
          ],
        ),
        content: const Text(
          'Tu compañero de entrenamiento.\n\n'
          '• Registra pesos y repeticiones\n'
          '• Sigue tu progresión\n'
          '• Exporta e importa datos\n'
          '• Rutina Push/Pull/Legs',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.grayLavender.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: AppTheme.inkMuted),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.inkMuted),
          ],
        ),
      ),
    );
  }
}
