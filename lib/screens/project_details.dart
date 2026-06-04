import 'package:flutter/material.dart';
import '../widgets/menu_button.dart';
import '../widgets/navigation_drawer.dart';
import 'team_analytics.dart';

class ProjectDetails extends StatelessWidget {
  const ProjectDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 2, // Start on the Analytics tab as per the design
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
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 100),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TeamAnalytics()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007AFF),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'View Full Analytics',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
