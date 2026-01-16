import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class RoutineDayCard extends StatelessWidget {
  final RoutineDay day;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Function(String name, String? muscleGroup) onLogExercise;

  const RoutineDayCard({
    super.key,
    required this.day,
    required this.isExpanded,
    required this.onToggle,
    required this.onLogExercise,
  });

  Color get _dayColor {
    switch (day.key) {
      case RoutineDayType.push:
        return AppTheme.blue;
      case RoutineDayType.pull:
        return AppTheme.lavender;
      case RoutineDayType.legs:
        return AppTheme.peach;
    }
  }

  IconData get _dayIcon {
    switch (day.key) {
      case RoutineDayType.push:
        return Icons.arrow_upward_rounded;
      case RoutineDayType.pull:
        return Icons.arrow_downward_rounded;
      case RoutineDayType.legs:
        return Icons.directions_walk_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isExpanded ? _dayColor : AppTheme.grayLavender.withOpacity(0.3),
          width: isExpanded ? 2 : 1,
        ),
        boxShadow: isExpanded
            ? [
                BoxShadow(
                  color: _dayColor.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(isExpanded ? 0 : 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: isExpanded
                  ? BoxDecoration(
                      color: _dayColor.withOpacity(0.15),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                      ),
                    )
                  : null,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _dayColor.withOpacity(isExpanded ? 0.4 : 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(_dayIcon, color: AppTheme.inkStrong, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          day.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${day.training.length} ejercicios',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _dayColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildContent(context),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calentamiento
          _buildSection(
            context,
            icon: Icons.whatshot_rounded,
            iconColor: AppTheme.peach,
            title: 'Calentamiento',
            child: Column(
              children: day.warmup.map((item) => _buildBulletItem(context, item)).toList(),
            ),
          ),
          const SizedBox(height: 20),
          
          // Entrenamiento
          _buildSection(
            context,
            icon: Icons.fitness_center_rounded,
            iconColor: AppTheme.lavender,
            title: 'Entrenamiento',
            child: Column(
              children: day.training.asMap().entries.map((entry) {
                final index = entry.key;
                final exercise = entry.value;
                return _buildExerciseItem(context, index + 1, exercise);
              }).toList(),
            ),
          ),
          
          // Final
          if (day.finish != null && day.finish!.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildSection(
              context,
              icon: Icons.sports_gymnastics_rounded,
              iconColor: AppTheme.green,
              title: 'Final',
              child: Column(
                children: day.finish!.map((item) => _buildBulletItem(context, item)).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: AppTheme.inkStrong),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildBulletItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppTheme.inkMuted,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseItem(BuildContext context, int number, RoutineExercise exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.grayLavender.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _dayColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$number',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  exercise.detail,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onLogExercise(exercise.name, exercise.muscleGroup),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _dayColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 16, color: AppTheme.inkStrong),
                    const SizedBox(width: 4),
                    Text(
                      'Log',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.inkStrong,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
