import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class HistoryEntryCard extends StatelessWidget {
  final TrainingEntry entry;
  final bool isEditing;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onCancelEdit;
  final Function(TrainingEntry) onSaveEdit;
  final TextEditingController? weightController;
  final TextEditingController? repsController;
  final DateTime? editingDate;
  final Function(DateTime)? onDateChanged;

  const HistoryEntryCard({
    super.key,
    required this.entry,
    required this.isEditing,
    required this.onEdit,
    required this.onDelete,
    required this.onCancelEdit,
    required this.onSaveEdit,
    this.weightController,
    this.repsController,
    this.editingDate,
    this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(entry.date);
    final formattedDate = DateFormat('dd/MM/yyyy').format(date);

    if (isEditing) {
      return _buildEditingCard(context);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.grayLavender.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Fecha
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.peach.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  DateFormat('dd').format(date),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  DateFormat('MMM', 'es').format(date).toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.inkMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          
          // Datos
          Expanded(
            child: Row(
              children: [
                _buildDataBadge(
                  context,
                  icon: Icons.monitor_weight_outlined,
                  value: '${entry.weight} kg',
                  color: AppTheme.blue,
                ),
                const SizedBox(width: 12),
                if (entry.reps != null)
                  _buildDataBadge(
                    context,
                    icon: Icons.repeat,
                    value: '${entry.reps} reps',
                    color: AppTheme.green,
                  ),
              ],
            ),
          ),
          
          // Acciones
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.blue.withOpacity(0.2),
                  padding: const EdgeInsets.all(8),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_rounded, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.error.withOpacity(0.15),
                  foregroundColor: AppTheme.error,
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditingCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lavender.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.lavender, width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: weightController,
                  decoration: const InputDecoration(
                    labelText: 'Peso (kg)',
                    isDense: true,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: repsController,
                  decoration: const InputDecoration(
                    labelText: 'Reps',
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: editingDate ?? DateTime.parse(entry.date),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 1)),
                    );
                    if (picked != null && onDateChanged != null) {
                      onDateChanged!(picked);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.grayLavender.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('dd/MM/yyyy').format(editingDate ?? DateTime.parse(entry.date)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: onCancelEdit,
                child: const Text('Cancelar'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  final updated = entry.copyWith(
                    weight: weightController?.text ?? entry.weight,
                    reps: repsController?.text.isEmpty == true ? null : repsController?.text,
                    date: (editingDate ?? DateTime.parse(entry.date)).toIso8601String().substring(0, 10),
                  );
                  onSaveEdit(updated);
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataBadge(
    BuildContext context, {
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.inkStrong),
          const SizedBox(width: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
