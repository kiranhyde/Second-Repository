/// Task domain models and helper enums.
class Task {
  Task({
    required this.id,
    required this.title,
    required this.priority,
    required this.steps,
    required this.estimatedMinutes,
    this.notes = '',
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final TaskPriority priority;
  final List<TaskStep> steps;
  final int estimatedMinutes;
  final String notes;
  final bool isCompleted;

  Task copyWith({
    String? title,
    TaskPriority? priority,
    List<TaskStep>? steps,
    int? estimatedMinutes,
    String? notes,
    bool? isCompleted,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      steps: steps ?? this.steps,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      priority:
          TaskPriority.values.firstWhere((v) => v.name == json['priority']),
      steps: (json['steps'] as List<dynamic>)
          .map((step) => TaskStep.fromJson(step as Map<String, dynamic>))
          .toList(),
      estimatedMinutes: json['estimatedMinutes'] as int,
      notes: json['notes'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'priority': priority.name,
      'steps': steps.map((s) => s.toJson()).toList(),
      'estimatedMinutes': estimatedMinutes,
      'notes': notes,
      'isCompleted': isCompleted,
    };
  }
}

class TaskStep {
  TaskStep({
    required this.title,
    required this.estimatedMinutes,
    this.isCompleted = false,
  });

  final String title;
  final int estimatedMinutes;
  final bool isCompleted;

  TaskStep copyWith({
    String? title,
    int? estimatedMinutes,
    bool? isCompleted,
  }) {
    return TaskStep(
      title: title ?? this.title,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory TaskStep.fromJson(Map<String, dynamic> json) {
    return TaskStep(
      title: json['title'] as String,
      estimatedMinutes: json['estimatedMinutes'] as int,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'estimatedMinutes': estimatedMinutes,
      'isCompleted': isCompleted,
    };
  }
}

enum TaskPriority {
  urgentImportant,
  urgentNotImportant,
  notUrgentImportant,
  notUrgentNotImportant,
}
