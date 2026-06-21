import 'package:flutter/foundation.dart';
import 'project.dart';

// Single shared source of truth for all projects, survives navigation everywhere
class ProjectStore extends ChangeNotifier {
  ProjectStore._internal();
  static final ProjectStore instance = ProjectStore._internal();

  final List<Project> _projects = [];

  List<Project> get projects => List.unmodifiable(_projects);

  // True if a project with this planId already exists, prevents duplicates
  // across navigation since ProjectStore itself persists app-wide
  bool hasPlan(String? planId) {
    if (planId == null) return false;
    return _projects.any((p) => p.planId == planId);
  }

  void addProject(Project project) {
    if (project.planId != null && hasPlan(project.planId)) return; // already added
    _projects.add(project);
    notifyListeners();
  }

  void removeProject(Project project) {
    _projects.remove(project);
    notifyListeners();
  }

  void refresh() => notifyListeners(); // call after mutating a project's tasks in place
}