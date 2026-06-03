import 'package:flutter/material.dart';
import 'models/project.dart';

class ProjectDetailPage extends StatefulWidget {
  final Project project;

  const ProjectDetailPage({super.key, required this.project});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  // Controller for the "add mini-task" text field
  final TextEditingController _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose(); // clean up controller when page is removed
    super.dispose();
  }

  // ── Add a new mini-task to this project ─────────────────────────────────
  void _addTask() {
    final name = _taskController.text.trim();
    if (name.isEmpty) return; // ignore empty input

    setState(() {
      // Directly mutate the project's task list — because Project is passed
      // by reference, this also updates the card on the previous page
      widget.project.tasks.add(TaskItem(name: name));
      _taskController.clear();
    });
  }

  // ── Toggle a mini-task done/not-done ────────────────────────────────────
  void _toggleTask(TaskItem task) {
    setState(() {
      task.isDone = !task.isDone;
      // setState causes a rebuild → progress getter recalculates automatically
    });
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    final int progressPercent = (project.progress * 100).round();

    // Format deadline nicely, or show "No deadline set"
    final String deadlineText = project.deadline != null
        ? "${project.deadline!.day}/${project.deadline!.month}/${project.deadline!.year}"
        : "No deadline set";

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context), // go back to projects list
        ),
        title: Text(
          project.title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Summary card (progress + stats) ───────────────────────────
            Container(
              width: double.infinity,
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

                  // Deadline row
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        deadlineText,
                        style:
                        const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Progress label + %
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Progress",
                          style: TextStyle(fontSize: 13, color: Colors.grey)),
                      Text(
                        "$progressPercent%",
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Progress bar — rebuilds dynamically as tasks are ticked
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: project.progress,
                      backgroundColor: Colors.grey.shade200,
                      valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.blue),
                      minHeight: 7,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Tasks done / total + days left
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Tasks",
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 2),
                          Text(
                            "${project.tasksDone}/${project.totalTasks}",
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("Days Left",
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 2),
                          Text(
                            project.daysLeft != null
                                ? "${project.daysLeft}"
                                : "—",
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Tasks",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // ── Add task input row ─────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(
                      hintText: "Add a task...",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none, // clean borderless look
                      ),
                    ),
                    // Allow pressing enter on keyboard to add task
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                const SizedBox(width: 10),
                // "+" button
                GestureDetector(
                  onTap: _addTask,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Checklist ──────────────────────────────────────────────────
            Expanded(
              // Expanded + ListView so checklist scrolls if tasks overflow
              child: project.tasks.isEmpty
                  ? const Center(
                child: Text(
                  "No tasks yet — add one above!",
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: project.tasks.length,
                itemBuilder: (context, index) {
                  final task = project.tasks[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CheckboxListTile(
                      value: task.isDone,
                      // Toggle fires _toggleTask → setState → progress recalculates
                      onChanged: (_) => _toggleTask(task),
                      title: Text(
                        task.name,
                        style: TextStyle(
                          fontSize: 15,
                          // Strike through completed tasks
                          decoration: task.isDone
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.isDone
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                      activeColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}