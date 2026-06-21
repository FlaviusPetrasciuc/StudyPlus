import 'package:flutter/material.dart';
import 'widgets/project_card.dart';
import 'models/project_store.dart';
import '../../widgets/navigation_drawer.dart';
import '../../widgets/menu_button.dart';
import '../../screens/create_project_screen.dart';

class CreateProjectPage extends StatefulWidget {
  const CreateProjectPage({super.key});

  @override
  State<CreateProjectPage> createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<CreateProjectPage> {

  @override
  void initState() {
    super.initState();
    // rebuilds this page whenever ProjectStore changes, from anywhere in the app
    ProjectStore.instance.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    ProjectStore.instance.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      endDrawer: CustomNavigationDrawer(activePage: 'Dashboard'),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                      const MenuButton(),
                    ],
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    "Active Projects",
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 16),

                  if (ProjectStore.instance.projects.isEmpty)
                    SizedBox(
                      // roughly: screen height minus header, app bar, and button area
                      height: (MediaQuery.of(context).size.height - 320).clamp(0, double.infinity),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.task_alt_rounded, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              "No projects yet — create one to get started",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Column(
                      children: ProjectStore.instance.projects
                          .map((project) => ProjectCard(
                        project: project,
                        onUpdate: () => setState(() {}),
                      ))
                          .toList(),
                    ),
                ],
              ),
            ),

            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateProjectScreen()),
                    );
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