import 'package:flutter/material.dart';
import '../models/project.dart';
import '../../productTaskPage/product_task_page.dart';

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
        // Navigate to the full task list page, scoped to this project.
        // This reuses the exact same Tasks-tab UI (cards, status badges,
        // overdue dates, groups) that the Product Launch page uses.
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductTaskPage(project: project),
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
            // Same calculation as before — now driven by ProductTask
            // statuses via project.progress under the hood
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

            // ── Group chips — only shown if the project has groups ──
            // Gives a quick visual preview of which teams/areas this
            // project touches, straight from the AI-generated groups
            if (project.groups.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: project.groups.map((g) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: g.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6, height: 6,
                          decoration: BoxDecoration(
                              color: g.color, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 4),
                        Text(g.name,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: g.color)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}