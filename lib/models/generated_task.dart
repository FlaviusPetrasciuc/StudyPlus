class GeneratedTask {
  final int week;
  final int day;
  final String title;
  final String description;
  final String category;
  final int estimatedHours;

  GeneratedTask({
    required this.week,
    required this.day,
    required this.title,
    required this.description,
    required this.category,
    required this.estimatedHours,
  });

  factory GeneratedTask.fromJson(Map<String, dynamic> json) {
    return GeneratedTask(
      week: json['week'] ?? 1,
      day: json['day'] ?? 1,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'planning',
      estimatedHours: json['estimated_hours'] ?? 1,
    );
  }
}