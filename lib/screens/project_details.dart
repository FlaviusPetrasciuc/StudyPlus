import 'package:flutter/material.dart';
import '../widgets/menu_button.dart';
import '../widgets/navigation_drawer.dart';
import '../services/task_service.dart';
import '../widgets/analytics_dashboard.dart';
import 'invite_team_members_screen.dart';

class TeamMember {
  final String name;
  final String role;
  final Color statusColor;
  final String avatarText;

  const TeamMember({
    required this.name,
    required this.role,
    required this.statusColor,
    required this.avatarText,
  });
}

class ProjectDetails extends StatelessWidget {
  final int initialTabIndex;

  const ProjectDetails({super.key, this.initialTabIndex = 2});

  static const List<TeamMember> _members = [
    TeamMember(name: 'Sarah Chen', role: 'Admin', statusColor: Color(0xFF2979FF), avatarText: 'SC'),
    TeamMember(name: 'Michael Rodriguez', role: 'Contributor', statusColor: Color(0xFF00C48C), avatarText: 'MR'),
    TeamMember(name: 'Emily Johnson', role: 'Contributor', statusColor: Color(0xFFFF9F43), avatarText: 'EJ'),
    TeamMember(name: 'David Kim', role: 'Contributor', statusColor: Color(0xFF9B59B6), avatarText: 'DK'),
    TeamMember(name: 'Priya Patel', role: 'Contributor', statusColor: Colors.red, avatarText: 'PP'),
    TeamMember(name: 'James Wilson', role: 'Viewer', statusColor: Color(0xFF00C48C), avatarText: 'JW'),
  ];

  @override
  Widget build(BuildContext context) {
    final taskService = TaskService();
    final int totalTasks = taskService.totalCount;
    final int completedTasks = taskService.completedCount;
    final int inProgressTasks = taskService.inProgressCount;
    final int pendingTasks = taskService.pendingCount;
    final double completionRate = taskService.completionRate;
    final int totalHours = taskService.totalEstimatedHours;
    final double progress = totalTasks == 0 ? 0 : (completedTasks / totalTasks * 100);

    return DefaultTabController(
      length: 3,
      initialIndex: initialTabIndex,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F5FA),
        endDrawer: CustomNavigationDrawer(activePage: 'Project Details'),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Product Launch Q2 2026',
                style: TextStyle(
                  color: Color(0xFF1A1C1E),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '6 team members',
                style: TextStyle(
                  color: Color(0xFF6C7278),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 8.0, bottom: 8.0),
              child: const MenuButton(),
            ),
          ],
          bottom: const TabBar(
            labelColor: Color(0xFF1A1C1E),
            unselectedLabelColor: Color(0xFF6C7278),
            indicatorColor: Color(0xFF1A1C1E),
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Tasks'),
              Tab(text: 'Analytics'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Overview Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Summary Cards
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      _buildStatCard(
                        icon: Icons.track_changes_rounded,
                        iconColor: const Color(0xFF2979FF),
                        iconBg: const Color(0xFFE3EDFF),
                        label: 'Progress',
                        value: '${progress.toInt()}%',
                      ),
                      _buildStatCard(
                        icon: Icons.check_circle_outline_rounded,
                        iconColor: const Color(0xFF00C48C),
                        iconBg: const Color(0xFFE0F7F1),
                        label: 'Completed',
                        value: '$completedTasks/$totalTasks',
                      ),
                      _buildStatCard(
                        icon: Icons.access_time_rounded,
                        iconColor: const Color(0xFFFF9F43),
                        iconBg: const Color(0xFFFFF3E0),
                        label: 'Time Spent',
                        value: '${totalHours}h',
                      ),
                      _buildStatCard(
                        icon: Icons.group_outlined,
                        iconColor: const Color(0xFF9B59B6),
                        iconBg: const Color(0xFFF3E5F5),
                        label: 'In Progress',
                        value: '$inProgressTasks',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Timeline
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Timeline',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Mar 1', style: TextStyle(fontSize: 12.0, color: Colors.black45, fontWeight: FontWeight.w500)),
                            Text('May 20', style: TextStyle(fontSize: 12.0, color: Colors.black45, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: const LinearProgressIndicator(
                            value: 0.42,
                            backgroundColor: Color(0xFFEEEFF4),
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2979FF)),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Center(
                          child: Text(
                            '42% complete',
                            style: TextStyle(fontSize: 12.0, color: Colors.black45),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Team Members
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Team Members',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const InviteTeamMembersScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Invite',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2979FF),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ..._members.map((member) => Padding(
                          padding: const EdgeInsets.only(bottom: 14.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: const Color(0xFFEEEFF4),
                                child: Text(
                                  member.avatarText,
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      member.name,
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      member.role,
                                      style: const TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.black45,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: member.statusColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tasks Tab
            const Center(child: Text('Tasks Content')),

            // Analytics Tab
            AnalyticsDashboard(
              totalTasks: totalTasks,
              completedTasks: completedTasks,
              inProgressTasks: inProgressTasks,
              pendingTasks: pendingTasks,
              completionRate: completionRate,
              totalHours: totalHours,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.black45,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}