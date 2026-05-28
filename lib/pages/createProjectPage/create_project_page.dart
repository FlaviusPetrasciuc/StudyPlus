import 'package:flutter/material.dart';
import 'widgets/project_card.dart';
import 'models/project.dart';

class CreateProjectPage extends StatelessWidget {
  const CreateProjectPage({super.key});

  @override
  Widget build(BuildContext context) {

    // ── Sample data ───────────────────────────────────────────────────
    // All values here flow into ProjectCard and drive the progress bar,
    // percentage, task count, and days left dynamically via the model getter.
    final List<Project> projects = [
      Project(
        title: "Mobile App Redesign",
        tasksDone: 23,
        totalTasks: 35,   // progress = 23/35 = 0.657 → shows 66%
        daysLeft: 18,
      ),
      Project(
        title: "Website Migration",
        tasksDone: 15,
        totalTasks: 36,   // progress = 15/36 = 0.416 → shows 42%
        daysLeft: 31,
      ),
      Project(
        title: "Brand Identity",
        tasksDone: 8,
        totalTasks: 20,   // progress = 8/20 = 0.40 → shows 40%
        daysLeft: 45,
      ),
    ];

    return Scaffold(
      // ── Light grey page background (matches new design) ─────────────
      backgroundColor: const Color(0xFFF2F4F7),

      body: SafeArea(
        child: Stack(
          children: [

            // ── Scrollable content ──────────────────────────────────
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              // Bottom padding of 100 prevents last card hiding behind
              // the fixed "Create New Project" button
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Header row: title + menu button ──────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Left: title + subtitle
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Projects",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Manage and track your ongoing work",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),

                      // Right: circular blue menu button (placeholder — no action yet)
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,   // makes it a perfect circle
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.menu,             // ≡ hamburger icon
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            // TODO: hook up drawer or bottom sheet later
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── Section heading ───────────────────────────────
                  const Text(
                    "Active Projects",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Project cards ─────────────────────────────────
                  // .map() loops over the list and creates one ProjectCard per project.
                  // Each card receives its own Project object; all data is dynamic.
                  Column(
                    children: projects
                        .map((project) => ProjectCard(project: project))
                        .toList(),
                  ),
                ],
              ),
            ),

            // ── Fixed "Create New Project" button at the bottom ─────
            // Positioned sits inside the Stack, pinned to the bottom edge.
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: navigate to create-project form
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    "+ Create New Project",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}