import 'package:flutter/material.dart';

// User-defined group
class TaskGroup {
  String name;
  Color color;

  TaskGroup({required this.name, required this.color});
}

// Checklist item
class ChecklistItem {
  String label;
  bool done;

  ChecklistItem({required this.label, this.done = false});
}

// Time log entry, created each time the user logs hours
class TimeLog {
  double hours;   // mutable so the user can edit a log entry
  String notes;   // mutable so the user can edit a log entry
  DateTime date;

  TimeLog({
    required this.hours,
    required this.notes,
    required this.date,
  });
}

// Main task model
class ProductTask {
  final String title;
  final String description;
  String dueDate;
  String dueTime;
  String status;
  String? priority;
  double progress;
  List<ChecklistItem> checklist;
  TaskGroup? group;
  String estimatedTime;   // editable — e.g. "2h"
  double estimatedHours;  // numeric version used for progress bar calculation
  double spentHours;      // total hours logged so far
  List<TimeLog> timeLogs; // full log history

  ProductTask({
    required this.title,
    required this.description,
    required this.dueDate,
    this.dueTime = '',
    required this.status,
    this.priority,
    required this.progress,
    required this.checklist,
    this.group,
    this.estimatedTime = '',
    this.estimatedHours = 0,
    this.spentHours = 0,
    List<TimeLog>? timeLogs,
  }) : timeLogs = timeLogs ?? [];

  void recalculateProgress() {
    if (checklist.isEmpty) { progress = 0.0; return; }
    final done = checklist.where((i) => i.done).length;
    progress = done / checklist.length;
  }

  // Adds a new log entry and updates spentHours total
  void logTime(TimeLog log) {
    timeLogs.add(log);
    spentHours += log.hours;
  }

  // How much estimated time is remaining (never goes below 0)
  double get remainingHours =>
      (estimatedHours - spentHours).clamp(0, estimatedHours);

  // Progress ratio for the time progress bar (0.0 – 1.0)
  double get timeProgress =>
      estimatedHours <= 0 ? 0 : (spentHours / estimatedHours).clamp(0.0, 1.0);
}