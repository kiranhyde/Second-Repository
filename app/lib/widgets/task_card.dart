import 'package:flutter/material.dart';

import '../models/task.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onToggleStep,
  });

  final Task task;
  final void Function(int index) onToggleStep;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(label: Text(_priorityLabel(task.priority))),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Est. ${task.estimatedMinutes} min',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Divider(height: 16),
            ...task.steps.asMap().entries.map(
              (entry) {
                final idx = entry.key;
                final step = entry.value;
                return CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  value: step.isCompleted,
                  onChanged: (_) => onToggleStep(idx),
                  title: Text(step.title),
                  subtitle: Text('${step.estimatedMinutes} min'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _priorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgentImportant:
        return 'Urgent & Important';
      case TaskPriority.urgentNotImportant:
        return 'Urgent';
      case TaskPriority.notUrgentImportant:
        return 'Important';
      case TaskPriority.notUrgentNotImportant:
        return 'Later';
    }
  }
}
