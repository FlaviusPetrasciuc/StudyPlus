import 'package:flutter/material.dart';
import 'widgets/project_card.dart';
import 'models/project.dart';
import 'models/project_store.dart';
import '../../widgets/navigation_drawer.dart';
import '../../widgets/menu_button.dart';

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

  // ── "Create New Project" popup ───────────────────────────────────────────
  void _showCreateDialog() {
    final TextEditingController nameController = TextEditingController();
    DateTime? selectedDate; // holds the picked date

    showDialog(
      context: context,
      builder: (context) {
        // StatefulBuilder lets the dialog rebuild when the date changes
        // without rebuilding the whole page
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "New Project",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min, // dialog only as tall as needed
                children: [

                  // Project name field
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: "Project name",
                      filled: true,
                      fillColor: const Color(0xFFF2F4F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Date picker row
                  GestureDetector(
                    onTap: () async {
                      // Opens the system calendar popup
                      final picked = await showDatePicker(
                        context: context,
                        initialDate:
                        DateTime.now().add(const Duration(days: 14)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now()
                            .add(const Duration(days: 365 * 2)),
                      );
                      if (picked != null) {
                        // Update dialog UI to show chosen date
                        setDialogState(() => selectedDate = picked);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 10),
                          Text(
                            selectedDate != null
                                ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                                : "Pick a deadline",
                            style: TextStyle(
                              color: selectedDate != null
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context), // cancel
                  child: const Text("Cancel",
                      style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return; // don't create nameless projects

                    // ProjectStore.fromAIGenerated() is the AI integration point
                    ProjectStore.instance.addProject(Project(
                      title: name,
                      deadline: selectedDate,
                      tasks: [],
                      groups: [],
                    ));

                    Navigator.pop(context); // close dialog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Create",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

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
                      height: MediaQuery.of(context).size.height - 320,
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
                  onPressed: _showCreateDialog,
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