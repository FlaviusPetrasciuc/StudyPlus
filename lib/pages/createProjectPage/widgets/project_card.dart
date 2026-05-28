import 'package:flutter/material.dart';
import '../models/project.dart';
import '../project_detail_page.dart';

class ProjectCard extends StatelessWidget {
  final Project project;

  // Called when a task is toggled inside the detail page —
  // bubbles the setState back up to CreateProjectPage so the card refreshes
  final VoidCallback onUpdate;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final int progressPercent = (project.progress * 100).round();

    // GestureDetector makes the whole card tappable
    return GestureDetector(
      onTap: () async {
        // Navigate to the detail page and wait for it to pop back
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProjectDetailPage(project: project),
          ),
        );
        // When user comes back, tell the parent to rebuild
        // so progress bar reflects any changes made
        onUpdate();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Title ──────────────────────────────────────────────
            Text(
              project.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            // ── Progress label + percentage ────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Progress",
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                Text(
                  "$progressPercent%",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ── Progress bar ───────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: project.progress, // dynamic — 0.0 to 1.0
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                minHeight: 7,
              ),
            ),

            const SizedBox(height: 14),

            // ── Tasks count + Days left ────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Tasks",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${project.tasksDone}/${project.totalTasks}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "Days Left",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      project.daysLeft != null ? "${project.daysLeft}" : "—",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}