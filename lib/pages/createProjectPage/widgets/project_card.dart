import 'package:flutter/material.dart';
import '../models/project.dart';

class ProjectCard extends StatelessWidget{
  final Project project;

  const ProjectCard({
    super.key,
    required this.project
});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const[
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
          Text(
            project.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          //Dynamic progress bar based on tasksDone / totalTasks
          LinearProgressIndicator(
            value: project.progress,
            backgroundColor: Colors.grey.shade300,
            color: Colors.blue,
            minHeight: 8,
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Tasks ${project.tasksDone}/${project.totalTasks}"),
              Text("${project.daysLeft} days left"),
            ],
          ),
        ],
      ),
    );
  }
}