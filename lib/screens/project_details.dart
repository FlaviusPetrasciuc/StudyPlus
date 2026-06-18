import 'package:flutter/material.dart';
import '../widgets/menu_button.dart';
import '../widgets/navigation_drawer.dart';
import '../services/task_service.dart';
import '../widgets/analytics_dashboard.dart';

class ProjectDetails extends StatelessWidget {
  final int initialTabIndex;
  
  const ProjectDetails({super.key, this.initialTabIndex = 2});

  @override
  Widget build(BuildContext context) {
    final taskService = TaskService();
    final int totalTasks = taskService.totalCount;
    final int completedTasks = taskService.completedCount;
    final int inProgressTasks = taskService.inProgressCount;
    final int pendingTasks = taskService.pendingCount;
    final double completionRate = taskService.completionRate;
    final int totalHours = taskService.totalEstimatedHours;

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
            const Center(child: Text('Overview Content')),
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
}
