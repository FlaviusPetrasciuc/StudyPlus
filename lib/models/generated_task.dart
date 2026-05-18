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
      week: json['week'],
      day: json['day'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      estimatedHours: json['estimated_hours'],
    );
  }
}