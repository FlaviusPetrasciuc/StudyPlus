import 'package:flutter/material.dart';
import '../models/project.dart';

class ProjectCard extends StatelessWidget {
  final Project project;

  const ProjectCard({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    // Convert the 0.0–1.0 progress value into a display percentage (e.g. 0.65 → "65%")
    final int progressPercent = (project.progress * 100).round();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,           // Card stays white against the grey page background
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

          // ── Project title ──────────────────────────────────────────
          Text(
            project.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          // ── "Progress" label + percentage on the same row ──────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Progress",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              // Dynamic: recalculated every time the widget rebuilds
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

          // ── Progress bar ───────────────────────────────────────────
          // `project.progress` is already a 0.0–1.0 double from the model getter
          ClipRRect(
            borderRadius: BorderRadius.circular(8), // rounded pill bar
            child: LinearProgressIndicator(
              value: project.progress,              // DYNAMIC — driven by tasksDone/totalTasks
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              minHeight: 7,
            ),
          ),

          const SizedBox(height: 14),

          // ── Tasks count + Days left ────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left column: label on top, value below
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tasks",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 2),
                  // DYNAMIC — shows e.g. "23/35"
                  Text(
                    "${project.tasksDone}/${project.totalTasks}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // Right column: label on top, value below (right-aligned)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "Days Left",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 2),
                  // DYNAMIC — shows e.g. "18"
                  Text(
                    "${project.daysLeft}",
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
    );
  }
}