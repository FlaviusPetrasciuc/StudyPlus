import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/generated_task.dart';
import '../models/project_plan.dart';
import '../utils/supabase_debug.dart';
import '../widgets/menu_button.dart';
import '../widgets/navigation_drawer.dart';
import '../pages/createProjectPage/models/project.dart';
import '../pages/createProjectPage/models/project_store.dart';
import 'create_project_screen.dart';
import 'invite_team_members_screen.dart';

class ProjectCalendarScreen extends StatefulWidget {
  final ProjectPlan? projectPlan;

  const ProjectCalendarScreen({
    super.key,
    this.projectPlan,
  });

  @override
  State<ProjectCalendarScreen> createState() => _ProjectCalendarScreenState();
}

class _ProjectCalendarScreenState extends State<ProjectCalendarScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;

  int selectedWeek = 1;
  bool isLoading = true;
  String? errorMessage;
  ProjectPlan? loadedProjectPlan;
  bool _addedToStore = false; // prevents adding the same plan twice on rebuild

  final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

  @override
  void initState() {
    super.initState();

    if (widget.projectPlan != null) {
      loadedProjectPlan = widget.projectPlan;
      isLoading = false;
      _addPlanToStore(widget.projectPlan!);
    } else {
      loadLatestProjectFromSupabase();
    }
  }

  // Converts the plan to show up on Dashboard automatically
  void _addPlanToStore(ProjectPlan plan) {
    if (_addedToStore) return;
    _addedToStore = true;
    ProjectStore.instance.addProject(Project.fromProjectPlan(plan));
  }

  Future<void> loadLatestProjectFromSupabase() async {
    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        setState(() {
          isLoading = false;
          loadedProjectPlan = null;
        });
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
        setState(() {
          isLoading = false;
          loadedProjectPlan = null;
        });
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

      setState(() {
        loadedProjectPlan = plan;
        isLoading = false;
      });

      _addPlanToStore(plan); // also sync Supabase-loaded plans into ProjectStore
    } catch (e, stackTrace) {
      logSupabaseError('load latest project calendar', e, stackTrace);

      setState(() {
        errorMessage = 'Failed to load calendar: $e';
        isLoading = false;
      });
    }
  }

  List<GeneratedTask> get weekTasks {
    if (loadedProjectPlan == null) {
      return [];
    }

    return loadedProjectPlan!.tasks
        .where((task) => task.week == selectedWeek)
        .toList();
  }

  List<GeneratedTask> tasksForDay(int day) {
    return weekTasks.where((task) => task.day == day).toList();
  }

  int get totalHours {
    return weekTasks.fold(0, (sum, task) => sum + task.estimatedHours);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4F5FA),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F5FA),
        endDrawer: CustomNavigationDrawer(activePage: 'Calendar'),
        body: Center(
          child: Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (loadedProjectPlan == null) {
      return _buildEmptyCalendar(context);
    }

    final projectPlan = loadedProjectPlan!;
    final totalTasks = weekTasks.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      endDrawer: CustomNavigationDrawer(activePage: 'Calendar'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreateProjectScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text(
                      'Back to Create Project',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
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
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      projectPlan.title,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF202124),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Invite code: ${projectPlan.inviteCode}',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF6C7278),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InviteTeamMembersScreen(
                                projectPlan: projectPlan,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.group_add),
                        label: const Text('Invite Team Members'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A84FF),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Week $selectedWeek of 8',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: selectedWeek > 1
                              ? () {
                            setState(() {
                              selectedWeek--;
                            });
                          }
                              : null,
                          icon: const Icon(Icons.chevron_left),
                        ),
                        IconButton(
                          onPressed: selectedWeek < 8
                              ? () {
                            setState(() {
                              selectedWeek++;
                            });
                          }
                              : null,
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalTasks tasks • ${totalHours}h total',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Week Progress',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: totalTasks == 0 ? 0 : 0.1,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ...List.generate(days.length, (index) {
                final dayNumber = index + 1;
                final tasks = tasksForDay(dayNumber);
                final dayHours = tasks.fold<int>(
                  0,
                      (sum, task) => sum + task.estimatedHours,
                );

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 18),
                  padding: const EdgeInsets.all(18),
                  decoration: cardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        days[index],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${dayHours}h',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (tasks.isEmpty)
                        const Text(
                          'No tasks for this day',
                          style: TextStyle(color: Colors.grey),
                        )
                      else
                        ...tasks.map(
                              (task) => Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FF),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFB9DFFF),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: const TextStyle(
                                    color: Color(0xFF007AFF),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  task.description,
                                  style: const TextStyle(
                                    color: Color(0xFF5F6368),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${task.estimatedHours}h • ${task.category}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCalendar(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      endDrawer: CustomNavigationDrawer(activePage: 'Calendar'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Builder(
                  builder: (context) {
                    return MenuButton(
                      onPressed: () {
                        Scaffold.of(context).openEndDrawer();
                      },
                    );
                  },
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.calendar_month,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 20),
              const Text(
                'No project available yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF202124),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Generate a project first to see tasks in the calendar.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6C7278),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateProjectScreen(),
                    ),
                  );
                },
                child: const Text('Create Project'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}