import 'package:flutter/material.dart';
import 'widgets/project_card.dart';
import 'widgets/quick_action_item.dart';

import 'models/project.dart';

class CreateProjectPage extends StatelessWidget {
  const CreateProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final projects = [
      Project(
        title: "Mobile App Redesign",
        tasksDone: 23,
        totalTasks: 35,
        daysLeft: 18,
      ),
      Project(
        title: "Website Migration",
        tasksDone: 15,
        totalTasks: 36,
        daysLeft: 31,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                    "Projects",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Manage and track your ongoing work",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),

                const SizedBox(height: 25),

                //4 quick actions (Calendar, Documents, Meetings, Analytics)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    QuickActionItem(icon: Icons.calendar_month, label: "Calendar"),
                    QuickActionItem(icon: Icons.folder, label: "Documents"),
                    QuickActionItem(icon: Icons.people, label: "Meetings"),
                    QuickActionItem(icon: Icons.bar_chart, label: "Analytics")
                  ],
                ),

                const SizedBox(height: 30),

                const Text(
                  "Active Projects",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                Column(
                  children: projects.map((project) =>
                      ProjectCard(project: project)).toList(),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () {/* later: navigate to create-project form */},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                    child: const Text(
                      "+ Create New Project",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

              ],
            ),
          ),
      ),
    );
  }
}
