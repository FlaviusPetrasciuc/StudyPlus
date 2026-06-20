import 'package:flutter/material.dart';
import 'invite_team_members_screen.dart';

// Data models
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

class ProjectData {
  final String name;
  final int teamCount;
  final double progress;
  final int completedTasks;
  final int totalTasks;
  final int timeSpent;
  final int inProgress;
  final String timelineStart;
  final String timelineEnd;
  final double timelinePercent;
  final List<TeamMember> members;

  const ProjectData({
    required this.name,
    required this.teamCount,
    required this.progress,
    required this.completedTasks,
    required this.totalTasks,
    required this.timeSpent,
    required this.inProgress,
    required this.timelineStart,
    required this.timelineEnd,
    required this.timelinePercent,
    required this.members,
  });
}

class ProjectOverviewScreen extends StatefulWidget {
  final ProjectData project;

  const ProjectOverviewScreen({super.key, required this.project});

  @override
  State<ProjectOverviewScreen> createState() => _ProjectOverviewScreenState();
}

class _ProjectOverviewScreenState extends State<ProjectOverviewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;

    return Scaffold(
      backgroundColor: const Color(0xFFEEEFF4),
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(child: _buildHeader(project)),
            SliverToBoxAdapter(child: _buildTabBar()),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(project),
              _buildPlaceholderTab('Tasks'),
              _buildPlaceholderTab('Analytics'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ProjectData project) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
      color: const Color(0xFFEEEFF4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.name,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${project.teamCount} team members',
            style: const TextStyle(
              fontSize: 12.0,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: const Color(0xFFEEEFF4),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF2979FF),
        unselectedLabelColor: Colors.black45,
        indicatorColor: const Color(0xFF2979FF),
        indicatorWeight: 2.5,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14.0,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14.0,
        ),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Tasks'),
          Tab(text: 'Analytics'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(ProjectData project) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Summary Cards
          _buildSummaryCards(project),
          const SizedBox(height: 20),

          // Timeline
          _buildTimeline(project),
          const SizedBox(height: 20),

          // Team Members
          _buildTeamMembers(project),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(ProjectData project) {
    return GridView.count(
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
          value: '${project.progress.toInt()}%',
        ),
        _buildStatCard(
          icon: Icons.check_circle_outline_rounded,
          iconColor: const Color(0xFF00C48C),
          iconBg: const Color(0xFFE0F7F1),
          label: 'Completed',
          value: '${project.completedTasks}/${project.totalTasks}',
        ),
        _buildStatCard(
          icon: Icons.access_time_rounded,
          iconColor: const Color(0xFFFF9F43),
          iconBg: const Color(0xFFFFF3E0),
          label: 'Time Spent',
          value: '${project.timeSpent}h',
        ),
        _buildStatCard(
          icon: Icons.group_outlined,
          iconColor: const Color(0xFF9B59B6),
          iconBg: const Color(0xFFF3E5F5),
          label: 'In Progress',
          value: '${project.inProgress}',
        ),
      ],
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

  Widget _buildTimeline(ProjectData project) {
    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                project.timelineStart,
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.black45,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                project.timelineEnd,
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.black45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: project.timelinePercent,
              backgroundColor: const Color(0xFFEEEFF4),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2979FF)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '${(project.timelinePercent * 100).toInt()}% complete',
              style: const TextStyle(
                fontSize: 12.0,
                color: Colors.black45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMembers(ProjectData project) {
    return Container(
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
          ...project.members.map((member) => _buildMemberRow(member)),
        ],
      ),
    );
  }

  Widget _buildMemberRow(TeamMember member) {
    return Padding(
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
    );
  }

  Widget _buildPlaceholderTab(String name) {
    return Center(
      child: Text(
        '$name coming soon',
        style: const TextStyle(
          fontSize: 16.0,
          color: Colors.black45,
        ),
      ),
    );
  }
}