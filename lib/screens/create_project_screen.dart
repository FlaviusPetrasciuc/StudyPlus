import 'package:flutter/material.dart';
import '../models/generated_task.dart';
import '../services/ai_plan_service.dart';
import '../widgets/menu_button.dart';
import '../widgets/navigation_drawer.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final TextEditingController projectNameController = TextEditingController();
  final TextEditingController projectDetailsController = TextEditingController();

  final AiPlanService aiPlanService = AiPlanService();

  bool isLoading = false;
  String? errorMessage;
  List<GeneratedTask> generatedTasks = [];

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
    if (!validateInput()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
      generatedTasks = [];
    });

    try {
      final tasks = await aiPlanService.generatePlan(
        title: projectNameController.text.trim(),
        details: projectDetailsController.text.trim(),
      );

      setState(() {
        generatedTasks = tasks;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to generate plan. Make sure your backend is running.';
      });
    } finally {
      setState(() {
        isLoading = false;
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const MenuButton(),
                ],
              ),

              const SizedBox(height: 28),

              const Text(
                'Create New Project',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF202124),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Provide your project details and let AI create a\nstructured 8-week plan',
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
                        hintText: 'Paste or input all available project information',
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
                  onPressed: isLoading ? null : generateAiPlan,
                  icon: isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : const Icon(Icons.auto_awesome, size: 26),
                  label: Text(
                    isLoading ? 'Generating Plan...' : 'Generate AI Plan',
                    style: const TextStyle(
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

              const SizedBox(height: 30),

              if (generatedTasks.isNotEmpty)
                const Text(
                  'Generated 8-Week Plan',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF202124),
                  ),
                ),

              const SizedBox(height: 16),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: generatedTasks.length,
                itemBuilder: (context, index) {
                  final task = generatedTasks[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(
                        'Week ${task.week}, Day ${task.day}: ${task.title}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(task.description),
                      trailing: Text('${task.estimatedHours}h'),
                    ),
                  );
                },
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