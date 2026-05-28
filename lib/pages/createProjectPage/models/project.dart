// ── TaskItem ───────────────────────────────────────────────────────────────
// Represents a single mini-task (checklist item) inside a project.
class TaskItem {
  final String name;
  bool isDone; // mutable so the checkbox can toggle it

  TaskItem({
    required this.name,
    this.isDone = false, // default: not done when first created
  });
}

// ── Project ────────────────────────────────────────────────────────────────
class Project {
  final String title;
  final DateTime? deadline; // nullable — new projects start with no deadline
  final List<TaskItem> tasks; // list of mini-tasks

  Project({
    required this.title,
    this.deadline,
    List<TaskItem>? tasks,
  }) : tasks = tasks ?? []; // default to empty list if nothing passed in

  // ── Computed getters (all dynamic — recalculated from tasks list) ─────────

  // How many tasks are ticked
  int get tasksDone => tasks.where((t) => t.isDone).length;

  // Total tasks in the project
  int get totalTasks => tasks.length;

  // 0.0 to 1.0 — used by the progress bar
  double get progress {
    if (totalTasks == 0) return 0;
    return tasksDone / totalTasks;
  }

  // Days remaining until deadline. Returns null if no deadline set.
  int? get daysLeft {
    if (deadline == null) return null;
    final diff = deadline!.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff; // clamp to 0 if deadline has passed
  }
}