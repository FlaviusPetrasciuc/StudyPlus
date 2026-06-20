import 'package:flutter/material.dart';
import '../../productTaskPage/models/product_task_module.dart';

// ── Project ────────────────────────────────────────────────────────────────
// A project now holds real ProductTask objects instead of the old
// lightweight TaskItem. This means every project's tasks have full
// status, priority, group, due date, and time tracking support —
// the exact same system used on the Product Launch task page.
class Project {
  final String title;
  final DateTime? deadline; // nullable — new projects start with no deadline
  final List<ProductTask> tasks; // real ProductTask objects, not TaskItem

  // Groups available within this project (e.g. "Design", "Backend").
  // The AI can populate this list when it generates a project — each
  // task's `group` field should point to one of the TaskGroups here.
  final List<TaskGroup> groups;

  Project({
    required this.title,
    this.deadline,
    List<ProductTask>? tasks,
    List<TaskGroup>? groups,
  })  : tasks = tasks ?? [],
        groups = groups ?? [];

  // ── Computed getters (all dynamic — recalculated from the tasks list) ────

  // How many tasks have status 'Done'
  int get tasksDone => tasks.where((t) => t.status == 'Done').length;

  // Total tasks in the project
  int get totalTasks => tasks.length;

  // 0.0 to 1.0 — used by the progress bar on the project card
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

  // ── AI integration slot ───────────────────────────────────────────────
  // Once the AI task-generation feature is built, call this factory with
  // the AI's parsed output to build a Project in one step. Wire the AI's
  // response into `groupNames` (e.g. ["Design", "Backend", "QA"]) and
  // `taskData` (a list of maps with title/description/dueDate/groupName/etc).
  // This keeps the AI integration to a single function call rather than
  // touching every file that creates a Project.
  factory Project.fromAIGenerated({
    required String title,
    DateTime? deadline,
    required List<String> groupNames,
    required List<Map<String, dynamic>> taskData,
  }) {
    // Build one TaskGroup per group name, cycling through a colour palette
    const palette = [
      Color(0xFF6366F1), Color(0xFF0EA5E9), Color(0xFFF59E0B),
      Color(0xFF10B981), Color(0xFFEC4899), Color(0xFF8B5CF6),
    ];
    final groups = <String, TaskGroup>{};
    for (var i = 0; i < groupNames.length; i++) {
      groups[groupNames[i]] =
          TaskGroup(name: groupNames[i], color: palette[i % palette.length]);
    }

    // Build a ProductTask per entry in taskData, attaching the matching group
    final tasks = taskData.map((data) {
      final groupName = data['group'] as String?;
      return ProductTask(
        title: data['title'] ?? 'Untitled Task',
        description: data['description'] ?? '',
        dueDate: data['dueDate'] ?? '',
        status: data['status'] ?? 'To Do',
        priority: data['priority'] ?? 'Medium',
        progress: 0.0,
        estimatedTime: data['estimatedTime'] ?? '',
        estimatedHours: (data['estimatedHours'] as num?)?.toDouble() ?? 0,
        group: groupName != null ? groups[groupName] : null,
        checklist: [],
      );
    }).toList();

    return Project(
      title: title,
      deadline: deadline,
      tasks: tasks,
      groups: groups.values.toList(),
    );
  }

  // ── Sample project for quick navigation ───────────────────────────────
  // Used by entry points (like the navigation drawer) that need to open
  // ProductTaskPage without a specific real project selected — e.g. a
  // "Team Analytics" or "Dashboard" menu link. Returns one consistent
  // demo project rather than each caller inventing its own placeholder.
  static Project sample() {
    final group = TaskGroup(name: 'General', color: const Color(0xFF6366F1));
    return Project(
      title: 'Sample Project',
      deadline: DateTime.now().add(const Duration(days: 14)),
      groups: [group],
      tasks: [
        ProductTask(
          title: 'Example Task',
          description: 'This is a placeholder task for navigation preview',
          dueDate: 'Jun 30',
          status: 'To Do',
          priority: 'Medium',
          progress: 0.0,
          group: group,
          checklist: [],
        ),
      ],
    );
  }
}