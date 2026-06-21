import 'package:flutter/foundation.dart';
import 'project.dart';

// Single shared source of truth for all projects, survives navigation everywhere
class ProjectStore extends ChangeNotifier {
  ProjectStore._internal();
  static final ProjectStore instance = ProjectStore._internal();

  final List<Project> _projects = [];

  List<Project> get projects => List.unmodifiable(_projects);

  void addProject(Project project) {
    _projects.add(project);
    notifyListeners();
  }

  void removeProject(Project project) {
    _projects.remove(project);
    notifyListeners();
  }

  void refresh() => notifyListeners(); // call after mutating a project's tasks in place
}