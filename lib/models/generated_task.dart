enum TaskStatus {
  completed,
  inProgress,
  pending
}

class GeneratedTask {
  final int week;
  final int day;
  final String title;
  final String description;
  final String category;
  final int estimatedHours;
  TaskStatus status;

  GeneratedTask({
    required this.week,
    required this.day,
    required this.title,
    required this.description,
    required this.category,
    required this.estimatedHours,
    this.status = TaskStatus.pending,
  });

  factory GeneratedTask.fromJson(Map<String, dynamic> json) {
    return GeneratedTask(
      week: json['week'],
      day: json['day'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      estimatedHours: json['estimated_hours'],
      status: _parseStatus(json['status']),
    );
  }

  static TaskStatus _parseStatus(String? status) {
    switch (status) {
      case 'completed':
        return TaskStatus.completed;
      case 'in_progress':
        return TaskStatus.inProgress;
      default:
        return TaskStatus.pending;
    }
  }

  String get statusString {
    switch (status) {
      case TaskStatus.completed:
        return 'completed';
      case TaskStatus.inProgress:
        return 'in_progress';
      case TaskStatus.pending:
        return 'pending';
    }
  }
}