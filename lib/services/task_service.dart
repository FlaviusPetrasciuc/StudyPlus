import '../models/generated_task.dart';

class TaskService {
  static final TaskService _instance = TaskService._internal();
  factory TaskService() => _instance;
  TaskService._internal();

  List<GeneratedTask> _currentTasks = [];

  void setTasks(List<GeneratedTask> tasks) {
    _currentTasks = tasks;
  }

  List<GeneratedTask> get tasks => _currentTasks;

  int get completedCount => _currentTasks.where((t) => t.status == TaskStatus.completed).length;
  int get inProgressCount => _currentTasks.where((t) => t.status == TaskStatus.inProgress).length;
  int get pendingCount => _currentTasks.where((t) => t.status == TaskStatus.pending).length;
  int get totalCount => _currentTasks.length;

  double get completionRate {
    if (totalCount == 0) return 0;
    return (completedCount / totalCount) * 100;
  }

  int get totalEstimatedHours {
    return _currentTasks.fold(0, (sum, task) => sum + task.estimatedHours);
  }
}