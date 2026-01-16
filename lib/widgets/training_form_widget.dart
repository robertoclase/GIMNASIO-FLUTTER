import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class TrainingFormWidget extends StatefulWidget {
  final List<Exercise> exercises;
  final String? selectedExerciseId;
  final Function(String exerciseId, String weight, String? reps, String date) onSave;

  const TrainingFormWidget({
    super.key,
    required this.exercises,
    this.selectedExerciseId,
    required this.onSave,
  });

  @override
  State<TrainingFormWidget> createState() => _TrainingFormWidgetState();
}

class _TrainingFormWidgetState extends State<TrainingFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late String? _selectedExerciseId;
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedExerciseId = widget.selectedExerciseId;
    _selectedDate = DateTime.now();
  }

  @override
  void didUpdateWidget(TrainingFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedExerciseId != oldWidget.selectedExerciseId) {
      setState(() {
        _selectedExerciseId = widget.selectedExerciseId;
      });
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedExerciseId != null) {
      widget.onSave(
        _selectedExerciseId!,
        _weightController.text.trim(),
        _repsController.text.trim().isEmpty ? null : _repsController.text.trim(),
        _selectedDate.toIso8601String().substring(0, 10),
      );
      _weightController.clear();
      _repsController.clear();
      setState(() {
        _selectedDate = DateTime.now();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('¡Entrada guardada!'),
            ],
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.lavender,
              onPrimary: AppTheme.inkStrong,
              surface: AppTheme.white,
              onSurface: AppTheme.inkStrong,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.lavender.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.fitness_center, color: AppTheme.inkStrong, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'REGISTRO DIARIO',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.inkMuted,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Añade peso y reps',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Ejercicio selector
            Text(
              'Ejercicio *',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.grayLavender.withOpacity(0.3)),
              ),
              child: DropdownButtonFormField<String>(
                initialValue: _selectedExerciseId,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                ),
                hint: const Text('Selecciona un ejercicio'),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                borderRadius: BorderRadius.circular(16),
                items: widget.exercises.map((exercise) {
                  return DropdownMenuItem(
                    value: exercise.id,
                    child: Text(
                      exercise.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedExerciseId = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selecciona un ejercicio';
                  }
                  return null;
                },
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
                      Text(
                        'Peso (kg) *',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: '0.0',
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.monitor_weight_outlined, size: 18, color: AppTheme.inkStrong),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa el peso';
                          }
                          return null;
                        },
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
                        'Repeticiones',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _repsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '0',
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.green.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.repeat, size: 18, color: AppTheme.inkStrong),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Fecha
            Text(
              'Fecha',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.grayLavender.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.peach.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.calendar_today, size: 18, color: AppTheme.inkStrong),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const Spacer(),
                    const Icon(Icons.edit_calendar_outlined, size: 20, color: AppTheme.inkMuted),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Botón guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save_rounded),
                label: const Text('Guardar entrada'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lavender,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
