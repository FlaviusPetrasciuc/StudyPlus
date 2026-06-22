import 'generated_task.dart';

class ProjectPlan {
  final String id;
  final String title;
  final String details;
  final String inviteCode;
  final List<GeneratedTask> tasks;

  ProjectPlan({
    required this.id,
    required this.title,
    required this.details,
    required this.inviteCode,
    required this.tasks,
  });

  factory ProjectPlan.fromJson(Map<String, dynamic> json) {
    return ProjectPlan(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      details: json['details'] ?? '',
      inviteCode: json['inviteCode'] ?? '',
      tasks: (json['tasks'] as List<dynamic>? ?? [])
          .map((task) => GeneratedTask.fromJson(task as Map<String, dynamic>))
          .toList(),
    );
  }
}