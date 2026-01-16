import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String? _selectedExerciseId;
  String? _editingEntryId;
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  DateTime? _editingDate;

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _startEdit(TrainingEntry entry) {
    setState(() {
      _editingEntryId = entry.id;
      _weightController.text = entry.weight;
      _repsController.text = entry.reps ?? '';
      _editingDate = DateTime.parse(entry.date);
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingEntryId = null;
      _weightController.clear();
      _repsController.clear();
      _editingDate = null;
    });
  }

  void _saveEdit(TrainingEntry entry) {
    final trainingService = context.read<TrainingService>();
    trainingService.update(entry);
    _cancelEdit();
  }

  void _deleteEntry(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Eliminar entrada?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TrainingService>().remove(id);
              Navigator.pop(context);
              if (_editingEntryId == id) {
                _cancelEdit();
              }
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

  Future<void> _exportData() async {
    final exerciseService = context.read<ExerciseService>();
    final trainingService = context.read<TrainingService>();

    final data = {
      'exercises': exerciseService.exercises.map((e) => e.toJson()).toList(),
      'entries': trainingService.entries.map((e) => e.toJson()).toList(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final fileName = 'mara-gym-respaldo-$date.json';

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Respaldo de Mara Gym',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Datos exportados correctamente'),
              ],
            ),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _importData() async {
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

      if (mounted) {
        context.read<ExerciseService>().replaceAll(exercises);
        context.read<TrainingService>().replaceAll(entries);

        setState(() {
          _selectedExerciseId = null;
        });
        _cancelEdit();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Datos importados correctamente'),
              ],
            ),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No se pudo importar. Verifica que sea un JSON válido.'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ExerciseService, TrainingService>(
      builder: (context, exerciseService, trainingService, child) {
        final exercises = List<Exercise>.from(exerciseService.exercises)
          ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        
        final historyEntries = _selectedExerciseId != null
            ? trainingService.entriesForExercise(_selectedExerciseId!)
            : <TrainingEntry>[];

        return CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tu Historial 📊',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Revisa tu progresión por ejercicio',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Botones de backup
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: AppTheme.accentCardDecoration,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.cloud_sync, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Respaldo de datos',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Exporta o importa tu progreso',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _exportData,
                        icon: const Icon(Icons.upload_rounded, size: 18),
                        label: const Text('Exportar'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _importData,
                        icon: const Icon(Icons.download_rounded, size: 18),
                        label: const Text('Importar'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Grid de ejercicios
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selecciona un ejercicio',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 12),
                    if (exercises.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.fitness_center_outlined,
                                size: 48,
                                color: AppTheme.inkMuted.withOpacity(0.5),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Aún no hay ejercicios',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.inkMuted,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Registra tu primer ejercicio en la pestaña "Registrar"',
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: exercises.map((exercise) {
                          return ExerciseChip(
                            exercise: exercise,
                            isSelected: _selectedExerciseId == exercise.id,
                            onTap: () {
                              setState(() {
                                _selectedExerciseId = exercise.id;
                              });
                              _cancelEdit();
                            },
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),

            // Tabla de historial
            if (_selectedExerciseId != null) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Container(
                    decoration: AppTheme.cardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header de la tabla
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.lavender.withOpacity(0.15),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.lavender.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.timeline, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exercises.firstWhere((e) => e.id == _selectedExerciseId).name,
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    Text(
                                      '${historyEntries.length} registros',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              if (historyEntries.length >= 2) _buildTrendBadge(context, historyEntries),
                            ],
                          ),
                        ),
                        
                        // Entradas
                        if (historyEntries.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.event_note_outlined,
                                    size: 48,
                                    color: AppTheme.inkMuted.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Sin registros aún',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.inkMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: historyEntries.map((entry) {
                                return HistoryEntryCard(
                                  entry: entry,
                                  isEditing: _editingEntryId == entry.id,
                                  onEdit: () => _startEdit(entry),
                                  onDelete: () => _deleteEntry(entry.id),
                                  onCancelEdit: _cancelEdit,
                                  onSaveEdit: _saveEdit,
                                  weightController: _editingEntryId == entry.id ? _weightController : null,
                                  repsController: _editingEntryId == entry.id ? _repsController : null,
                                  editingDate: _editingEntryId == entry.id ? _editingDate : null,
                                  onDateChanged: (date) {
                                    setState(() {
                                      _editingDate = date;
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ] else
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.grayLavender.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.touch_app_outlined,
                          size: 48,
                          color: AppTheme.inkMuted.withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Elige un ejercicio para ver su historial',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.inkMuted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
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

  Widget _buildTrendBadge(BuildContext context, List<TrainingEntry> entries) {
    if (entries.length < 2) {
      return const SizedBox.shrink();
    }

    final latest = entries.first;
    final previous = entries[1];
    
    final latestNum = double.tryParse(latest.weight);
    final prevNum = double.tryParse(previous.weight);
    
    if (latestNum == null || prevNum == null) {
      return const SizedBox.shrink();
    }

    final diff = latestNum - prevNum;
    final isUp = diff > 0;
    final isEqual = diff.abs() < 0.1;

    Color color;
    IconData icon;
    String text;

    if (isEqual) {
      color = AppTheme.blue;
      icon = Icons.trending_flat;
      text = 'Estable';
    } else if (isUp) {
      color = AppTheme.green;
      icon = Icons.trending_up;
      text = '+${diff.toStringAsFixed(1)} kg';
    } else {
      color = AppTheme.peach;
      icon = Icons.trending_down;
      text = '${diff.toStringAsFixed(1)} kg';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.inkStrong),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
