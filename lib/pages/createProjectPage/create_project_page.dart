import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:study_plus/models/generated_task.dart';
import 'package:study_plus/models/project_plan.dart';
import 'package:study_plus/pages/createProjectPage/widgets/project_card.dart';
import 'package:study_plus/pages/createProjectPage/models/project_store.dart';
import 'package:study_plus/pages/createProjectPage/models/project.dart';
import 'package:study_plus/widgets/navigation_drawer.dart';
import 'package:study_plus/widgets/menu_button.dart';
import 'package:study_plus/screens/create_project_screen.dart';

class CreateProjectPage extends StatefulWidget {
  const CreateProjectPage({super.key});

  @override
  State<CreateProjectPage> createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<CreateProjectPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    ProjectStore.instance.addListener(_onStoreChanged);
    _loadLatestProjectFromSupabase();
  }

  @override
  void dispose() {
    ProjectStore.instance.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadLatestProjectFromSupabase() async {
    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        setState(() => isLoading = false);
        return;
      }

      final projectResponse = await _supabase
          .from('projects')
          .select()
          .eq('created_by', user.id)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (projectResponse == null) {
        setState(() => isLoading = false);
        return;
      }

      final projectId = projectResponse['id'].toString();
      final teamId = projectResponse['team_id'];

      String inviteCode = '';

      if (teamId != null) {
        final teamResponse = await _supabase
            .from('teams')
            .select()
            .eq('id', teamId)
            .maybeSingle();

        inviteCode = teamResponse?['join_code'] ?? '';
      }

      final tasksResponse = await _supabase
          .from('tasks')
          .select()
          .eq('project_id', projectId)
          .order('week', ascending: true)
          .order('day', ascending: true);

      final tasks = (tasksResponse as List<dynamic>).map((task) {
        return GeneratedTask(
          week: task['week'] ?? 1,
          day: task['day'] ?? 1,
          title: task['title'] ?? '',
          description: task['description'] ?? '',
          category: task['category'] ?? '',
          estimatedHours: task['estimated_hours'] ?? 0,
        );
      }).toList();

      final plan = ProjectPlan(
        id: projectId,
        title: projectResponse['title'] ?? '',
        details: projectResponse['details'] ?? '',
        inviteCode: inviteCode,
        tasks: tasks,
      );

      final project = Project.fromProjectPlan(plan);
      ProjectStore.instance.addProject(project);

      if (mounted) {
        setState(() => isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final projects = ProjectStore.instance.projects;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      endDrawer: CustomNavigationDrawer(activePage: 'Dashboard'),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Projects",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Manage and track your ongoing work",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Builder(
                        builder: (context) {
                          return MenuButton(
                            onPressed: () {
                              Scaffold.of(context).openEndDrawer();
                            },
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    "Active Projects",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (projects.isEmpty)
                    SizedBox(
                      height: (MediaQuery.of(context).size.height - 320)
                          .clamp(0, double.infinity),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.task_alt_rounded,
                              size: 64,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No projects yet — create one to get started",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Column(
                      children: projects
                          .map(
                            (project) => ProjectCard(
                          project: project,
                          onUpdate: () => setState(() {}),
                        ),
                      )
                          .toList(),
                    ),
                ],
              ),
            ),

            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateProjectScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    "+ Create New Project",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}