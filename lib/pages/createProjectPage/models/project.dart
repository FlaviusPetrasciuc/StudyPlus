import 'package:flutter/material.dart';
import '../../productTaskPage/models/product_task_module.dart';

// Project holds real ProductTask objects with full status/priority/group/time tracking support
class Project {
  final String title;
  final DateTime? deadline; // nullable — new projects start with no deadline
  final List<ProductTask> tasks; // real ProductTask objects, not TaskItem
  final int memberCount; // placeholder until real team membership is tracked
  final String? planId; // matches ProjectPlan.id, used to prevent duplicate adds

  // Groups available within this project, populated by the AI or the user
  final List<TaskGroup> groups;

  Project({
    required this.title,
    this.deadline,
    this.memberCount = 1,
    this.planId,
    List<ProductTask>? tasks,
    List<TaskGroup>? groups,
  })  : tasks = tasks ?? [],
        groups = groups ?? [];

  // Computed getters, all recalculated dynamically from the tasks list

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

  // AI integration slot — builds a Project from generic title/group/task data
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

  // Converts an AI-generated ProjectPlan (week/day/category tasks) into a Project
  factory Project.fromProjectPlan(dynamic projectPlan) {
    const palette = [
      Color(0xFF6366F1), Color(0xFF0EA5E9), Color(0xFFF59E0B),
      Color(0xFF10B981), Color(0xFFEC4899), Color(0xFF8B5CF6),
    ];

    // Build one TaskGroup per unique category, cycling through the palette
    final categories = <String>{};
    for (final task in projectPlan.tasks) {
      categories.add(task.category as String);
    }
    final groups = <String, TaskGroup>{};
    var i = 0;
    for (final category in categories) {
      groups[category] = TaskGroup(name: category, color: palette[i % palette.length]);
      i++;
    }

    // Used as the base date — week 1 day 1 maps to this date
    final startDate = DateTime.now();

    final tasks = projectPlan.tasks.map<ProductTask>((task) {
      // Each week is 7 days, each day index (1-5) offsets within that week
      final dueDate = startDate.add(Duration(days: (task.week - 1) * 7 + (task.day - 1)));
      const monthNames = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final dueDateStr = '${monthNames[dueDate.month]} ${dueDate.day}';

      return ProductTask(
        title: task.title as String,
        description: task.description as String,
        dueDate: dueDateStr,
        status: _statusFromGeneratedStatus(task.statusString as String),
        priority: 'Medium',
        progress: 0.0,
        estimatedTime: '${task.estimatedHours}h',
        estimatedHours: (task.estimatedHours as int).toDouble(),
        group: groups[task.category as String],
        checklist: [],
      );
    }).toList();

    return Project(
      title: projectPlan.title as String,
      deadline: startDate.add(const Duration(days: 56)), // 8 weeks
      planId: projectPlan.id as String?,
      tasks: tasks,
      groups: groups.values.toList(),
    );
  }

  // Maps GeneratedTask's status string to ProductTask's status string
  static String _statusFromGeneratedStatus(String status) {
    switch (status) {
      case 'completed':   return 'Done';
      case 'in_progress': return 'In Progress';
      default:            return 'To Do';
    }
  }
}