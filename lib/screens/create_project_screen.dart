import 'package:flutter/material.dart';
import 'package:study_plus/services/ai_plan_service.dart';
import 'package:study_plus/services/project_service.dart';
import 'package:study_plus/pages/createProjectPage/create_project_page.dart';
import 'package:study_plus/pages/createProjectPage/models/project_store.dart';
import 'package:study_plus/pages/createProjectPage/models/project.dart';
import 'package:study_plus/widgets/ai_loading_screen.dart';
import 'package:study_plus/widgets/menu_button.dart';
import 'package:study_plus/widgets/navigation_drawer.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final TextEditingController projectNameController = TextEditingController();
  final TextEditingController projectDetailsController = TextEditingController();

  final AiPlanService aiPlanService = AiPlanService();

  String? errorMessage;

  @override
  void dispose() {
    projectNameController.dispose();
    projectDetailsController.dispose();
    super.dispose();
  }

  bool validateInput() {
    final name = projectNameController.text.trim();
    final details = projectDetailsController.text.trim();

    if (name.isEmpty) {
      setState(() {
        errorMessage = 'Please enter a project name';
      });
      return false;
    }

    if (details.isEmpty) {
      setState(() {
        errorMessage = 'Please enter project details';
      });
      return false;
    }

    if (details.length < 30) {
      setState(() {
        errorMessage = 'Please write more details about your project';
      });
      return false;
    }

    setState(() {
      errorMessage = null;
    });

    return true;
  }

  Future<void> generateAiPlan() async {
    final existingProjects = ProjectStore.instance.projects;

    if (existingProjects.isNotEmpty) {
      setState(() {
        errorMessage =
        'You already have one AI-generated project. Delete the previous project before creating a new one.';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Delete the previous project before generating a new one.',
          ),
        ),
      );

      return;
    }

    if (!validateInput()) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AILoadingScreen(),
      ),
    );

    try {
      final projectPlan = await aiPlanService.generatePlan(
        title: projectNameController.text.trim(),
        details: projectDetailsController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pop(context);

      final project = Project.fromProjectPlan(projectPlan);

      ProjectStore.instance.addProject(project);
      ProjectService().addProject(projectPlan);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const CreateProjectPage(),
        ),
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      Navigator.pop(context);

      setState(() {
        errorMessage = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      endDrawer: CustomNavigationDrawer(activePage: 'New Project'),
      body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row with title and menu button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Create New Project',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF202124),
                      ),
                    ),
                    Builder(
                      builder: (context) {
                        return MenuButton(
                          onPressed: () {
                            Scaffold.of(context).openEndDrawer();
                          },
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Provide your project details and \n let AI create a structured 8-week \n plan',
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.4,
                    color: Color(0xFF8E8E93),
                  ),
                ),
              const SizedBox(height: 36),
              _InputCard(
                title: 'Project Name',
                child: TextField(
                  controller: projectNameController,
                  decoration: _inputDecoration(
                    hintText: 'e.g., Mobile App Redesign',
                  ),
                ),
              ),
              const SizedBox(height: 28),
              _InputCard(
                title: 'Project Details',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: projectDetailsController,
                      maxLines: 10,
                      decoration: _inputDecoration(
                        hintText:
                        'Paste or input all available project information',
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'The more details you provide, the better AI can structure\nyour project plan',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (errorMessage != null)
                Text(
                  errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 68,
                child: ElevatedButton.icon(
                  onPressed: generateAiPlan,
                  icon: const Icon(Icons.auto_awesome, size: 26),
                  label: const Text(
                    'Generate AI Plan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A84FF),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF8E8E93),
        fontSize: 17,
      ),
      filled: true,
      fillColor: const Color(0xFFF1F2F8),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFDADCE5),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFDADCE5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFF0A84FF),
          width: 1.5,
        ),
      ),
    );
  }
}

class _InputCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _InputCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF202124),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}