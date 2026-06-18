import 'package:flutter/material.dart';

// ── User-defined group ──────────────────────────────────────
class TaskGroup {
  String name;
  Color color;

  TaskGroup({required this.name, required this.color});
}

// ── Checklist item ───────────────────────────────────────────
class ChecklistItem {
  String label;
  bool done;

  ChecklistItem({required this.label, this.done = false});
}

// ── Time log entry ───────────────────────────────────────────
// Each time the user logs hours, one of these is created
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

// ── Main task model ──────────────────────────────────────────
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

// ── Seed data ────────────────────────────────────────────────
final List<ProductTask> fakeProductTasks = [
  ProductTask(
    title: 'Market Research & Analysis',
    description: 'Conduct comprehensive market research',
    dueDate: 'Apr 5',
    status: 'Done',
    progress: 1.0,
    estimatedTime: '',
    checklist: [
      ChecklistItem(label: 'Define target audience', done: true),
      ChecklistItem(label: 'Competitor analysis',    done: true),
      ChecklistItem(label: 'Summarise findings',     done: true),
    ],
  ),
  ProductTask(
    title: 'User Interface Design',
    description: 'Create wireframes and prototypes',
    dueDate: 'Apr 12',
    status: 'Done',
    progress: 1.0,
    estimatedTime: '',
    checklist: [
      ChecklistItem(label: 'Sketch low-fi wireframes', done: true),
      ChecklistItem(label: 'Build hi-fi prototype',    done: true),
    ],
  ),
  ProductTask(
    title: 'Backend Development',
    description: 'Set up API endpoints and database',
    dueDate: 'May 1',
    status: 'In Progress',
    progress: 0.5,
    estimatedTime: '8h',
    estimatedHours: 8,
    spentHours: 4,
    checklist: [
      ChecklistItem(label: 'Design database schema', done: true),
      ChecklistItem(label: 'Create REST endpoints',  done: true),
      ChecklistItem(label: 'Write unit tests',       done: false),
      ChecklistItem(label: 'Deploy to staging',      done: false),
    ],
  ),
  ProductTask(
    title: 'Content Strategy',
    description: 'Develop content plan and guidelines',
    dueDate: 'Apr 28',
    status: 'In Progress',
    progress: 0.33,
    estimatedTime: '',
    checklist: [
      ChecklistItem(label: 'Content audit',          done: true),
      ChecklistItem(label: 'Editorial calendar',     done: false),
      ChecklistItem(label: 'Brand voice guidelines', done: false),
    ],
  ),
  ProductTask(
    title: 'Testing & QA',
    description: 'Comprehensive testing across platforms',
    dueDate: 'May 10',
    status: 'To Do',
    progress: 0.0,
    estimatedTime: '',
    checklist: [
      ChecklistItem(label: 'Write test cases'),
      ChecklistItem(label: 'Run regression tests'),
      ChecklistItem(label: 'Bug triage'),
    ],
  ),
  ProductTask(
    title: 'Documentation',
    description: 'Create user guides and technical docs',
    dueDate: 'May 15',
    status: 'To Do',
    progress: 0.0,
    estimatedTime: '',
    checklist: [
      ChecklistItem(label: 'API reference docs'),
      ChecklistItem(label: 'User onboarding guide'),
    ],
  ),
  ProductTask(
    title: 'Launch Preparation',
    description: 'Final checks and deployment setup',
    dueDate: 'May 20',
    status: 'To Do',
    progress: 0.0,
    estimatedTime: '',
    checklist: [
      ChecklistItem(label: 'Smoke test on production'),
      ChecklistItem(label: 'Set up monitoring alerts'),
      ChecklistItem(label: 'Notify stakeholders'),
    ],
  ),
];