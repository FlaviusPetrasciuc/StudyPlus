import 'package:flutter/material.dart';
import '../auth/auth_service.dart';
import '../screens/login_screen.dart';
import '../screens/invite_team_members_screen.dart';
import '../screens/create_project_screen.dart';
import '../screens/project_calendar_screen.dart';
import '../screens/project_details.dart';
import '../screens/project_overview_screen.dart';
import '../widgets/analytics_dashboard.dart';
import '../pages/productTaskPage/product_task_page.dart';
import '../pages/createProjectPage/models/project.dart';

class CustomNavigationDrawer extends StatelessWidget {
  final String? activePage;
  final AuthService _authService = AuthService();
  CustomNavigationDrawer({super.key, this.activePage});

  void _navigateTo(BuildContext context, String pageName, Widget screen) {
    Navigator.pop(context);
    if (activePage != pageName) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => screen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      backgroundColor: Colors.white,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Menu',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1C1E),
                        ),
                      ),
                      Text(
                        'Jump to any screen',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6C7278),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF007AFF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            _buildSectionTitle('MAIN'),
            _buildMenuItem(context, 'Dashboard'),
            _buildMenuItem(
              context,
              'New Project',
              onTap: () {
                _navigateTo(
                  context,
                  'New Project',
                  const CreateProjectScreen(),
                );
              },
            ),
            _buildMenuItem(
              context,
              'Calendar',
              onTap: () {
                _navigateTo(
                  context,
                  'Calendar',
                  const ProjectCalendarScreen(),
                );
              },
            ),
            _buildMenuItem(context, 'Meetings'),
            const SizedBox(height: 30),
            _buildSectionTitle('TEAM'),
            _buildMenuItem(context, 'Team Dashboard'),
            _buildMenuItem(context, 'Team Analytics'),
            _buildMenuItem(context, 'Activity Feed'),
            _buildMenuItem(context, 'Task Assignment'),
            _buildMenuItem(
              context,
              'Team Invite',
              onTap: () {
                _navigateTo(
                  context,
                  'Team Invite',
                  const InviteTeamMembersScreen(),
                );
              },
            ),
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    await _authService.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                            (route) => false,
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 16.0,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 12),
                        Text(
                          'Log Out',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6C7278),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context,
      String title, {
        VoidCallback? onTap,
      }) {
    final bool isActive = activePage == title;
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF007AFF) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (isActive) {
              Navigator.pop(context);
              return;
            }
            Widget nextPage;
            if (title == 'Dashboard') {
              nextPage = ProductTaskPage(
                project: Project.sample(),
                initialTab: 1, // Tasks tab
              );
            } else if (title == 'Team Analytics') {
              // Analytics screen takes raw stat counts, not a Project —
              // _analyticsFromProject() converts Project.sample() into them
              nextPage = _analyticsScreenFor(Project.sample());
            } else if (title == 'Task Assignment') {
              nextPage = ProductTaskPage(
                project: Project.sample(),
                initialTab: 1, // Tasks tab
              );
            } else if (title == 'Team Dashboard' || title == 'Project Details') {
              // Overview screen takes a ProjectData — _overviewDataFor()
              // converts Project.sample() into the shape it expects
              nextPage = ProjectOverviewScreen(
                project: _overviewDataFor(Project.sample()),
              );
            } else if (title == 'New Project') {
              nextPage = const CreateProjectScreen();
            } else {
              Navigator.pop(context);
              return;
            }
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => nextPage),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : const Color(0xFF1A1C1E),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Project → ProjectOverviewScreen adapter ─────────────────────────────
ProjectData _overviewDataFor(Project project) {
  final totalHours = project.tasks.fold<double>(
      0, (sum, t) => sum + t.spentHours);

  return ProjectData(
    name: project.title,
    teamCount: 6, // placeholder until real team data is wired in
    progress: project.progress * 100,
    completedTasks: project.tasksDone,
    totalTasks: project.totalTasks,
    timeSpent: totalHours.round(),
    inProgress:
    project.tasks.where((t) => t.status == 'In Progress').length,
    timelineStart: 'Start',
    timelineEnd: project.deadline != null
        ? '${project.deadline!.day}/${project.deadline!.month}'
        : 'No deadline',
    timelinePercent: project.progress,
    members: const [], // placeholder until real team data is wired in
  );
}

// ── Project → AnalyticsDashboard adapter ────────────────────────────────
Widget _analyticsScreenFor(Project project) {
  final total      = project.totalTasks;
  final completed  = project.tasksDone;
  final inProgress = project.tasks.where((t) => t.status == 'In Progress').length;
  final pending    = total - completed - inProgress;
  final totalHours = project.tasks.fold<double>(0, (sum, t) => sum + t.spentHours);

  return Scaffold(
    backgroundColor: const Color(0xFFEEEFF4),
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black87),
      title: const Text('Analytics',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
    ),
    body: AnalyticsDashboard(
      totalTasks: total,
      completedTasks: completed,
      inProgressTasks: inProgress,
      pendingTasks: pending < 0 ? 0 : pending,
      completionRate: total == 0 ? 0 : (completed / total) * 100,
      totalHours: totalHours.round(),
    ),
  );
}