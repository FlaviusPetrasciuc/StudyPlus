import 'package:flutter/material.dart';

// ── User-defined group ──────────────────────────────────────
// A group the user creates themselves: a name + a picked colour.
// Stored as a nullable field on ProductTask — null means no group yet.
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

// ── Main task model ──────────────────────────────────────────
class ProductTask {
  final String title;
  final String description;
  String dueDate;     // e.g. "Apr 5" — updated by the detail page on save
  String dueTime;     // e.g. "9:00 AM" — set by the detail page on save
  String status;      // 'To Do' | 'In Progress' | 'Done'
  String? priority;   // 'High' | 'Medium' | 'Low' — nullable until first save
  double progress;    // 0.0 – 1.0
  List<ChecklistItem> checklist;

  // Nullable — user assigns a group from inside the detail page
  TaskGroup? group;

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
  });

  // Recomputes progress from checklist ticks
  void recalculateProgress() {
    if (checklist.isEmpty) { progress = 0.0; return; }
    final done = checklist.where((i) => i.done).length;
    progress = done / checklist.length;
  }
}

// ── Seed data ────────────────────────────────────────────────
final List<ProductTask> fakeProductTasks = [
  ProductTask(
    title: 'Market Research & Analysis',
    description: 'Conduct comprehensive market research',
    dueDate: 'Apr 5',
    status: 'Done',
    progress: 1.0,
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
    checklist: [
      ChecklistItem(label: 'Smoke test on production'),
      ChecklistItem(label: 'Set up monitoring alerts'),
      ChecklistItem(label: 'Notify stakeholders'),
    ],
  ),
];