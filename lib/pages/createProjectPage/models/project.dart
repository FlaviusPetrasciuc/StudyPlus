class Project {
  final String title;
  final int tasksDone;
  final int totalTasks;
  final int daysLeft;

  Project({
    required this.title,
    required this.tasksDone,
    required this.totalTasks,
    required this.daysLeft,
});

  double get progress{
    if(totalTasks == 0) return 0;
    return tasksDone/totalTasks;
  }
}