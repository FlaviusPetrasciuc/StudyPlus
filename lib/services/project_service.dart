import '../models/project_plan.dart';

class ProjectService {
  static final ProjectService _instance = ProjectService._internal();
  factory ProjectService() => _instance;
  ProjectService._internal();

  final List<ProjectPlan> _projects = [];

  void addProject(ProjectPlan project) {
    // Avoid duplicates if same ID
    if (!_projects.any((p) => p.id == project.id)) {
      _projects.add(project);
    }
  }

  List<ProjectPlan> get projects => _projects;

  int get totalProjectsCount => _projects.length;
}