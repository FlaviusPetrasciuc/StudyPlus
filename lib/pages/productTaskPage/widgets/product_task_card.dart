import 'package:flutter/material.dart';
import '../models/product_task_module.dart';
import '../product_task_detail_page.dart';

class ProductTaskCard extends StatelessWidget {
  final ProductTask task;
  final VoidCallback onUpdate;

  const ProductTaskCard({super.key, required this.task, required this.onUpdate});

  // Badge background colour based on status string
  Color _statusBg(String s) {
    switch (s) {
      case 'Done':        return const Color(0xFFD1FAE5);
      case 'In Progress': return const Color(0xFFFEF3C7);
      default:            return const Color(0xFFF3F4F6); // To Do
    }
  }

  Color _statusFg(String s) {
    switch (s) {
      case 'Done':        return const Color(0xFF065F46);
      case 'In Progress': return const Color(0xFF92400E);
      default:            return const Color(0xFF6B7280);
    }
  }

  // Maps status string to the label shown in the badge (matches screenshot)
  String _statusLabel(String s) {
    switch (s) {
      case 'Done':        return 'completed';
      case 'In Progress': return 'in-progress';
      default:            return 'pending';
    }
  }

  // Returns true if the due date has passed AND the task isn't done yet.
  // Completed tasks are never flagged as overdue.
  bool _isOverdue(ProductTask t) {
    if (t.status == 'Done') return false;
    try {
      const months = {
        'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4,
        'May': 5, 'Jun': 6, 'Jul': 7, 'Aug': 8,
        'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
      };
      final parts = t.dueDate.split(' ');
      final month = months[parts[0]];
      final day   = int.tryParse(parts[1]);
      if (month == null || day == null) return false;

      final due   = DateTime(DateTime.now().year, month, day);
      final today = DateTime.now();

      // Compare dates only — tasks due today are not overdue
      return DateTime(today.year, today.month, today.day)
          .isAfter(DateTime(due.year, due.month, due.day));
    } catch (_) {
      return false; // if parsing fails, don't flag
    }
  }

  @override
  Widget build(BuildContext context) {
    final overdue = _isOverdue(task);
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductTaskDetailPage(task: task)),
        );
        onUpdate(); // refresh list when returning from detail page
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),

        // Plain card body — no progress bar, matching the screenshot
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Title + status badge ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusBg(task.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel(task.status),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _statusFg(task.status),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // ── Description ──
            Text(
              task.description,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),

            const SizedBox(height: 14),

            // ── Group chip + due date ──
            // Group is now user-defined (name + colour), pulled from task.group
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Only show group chip if a group has been assigned
                if (task.group != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: task.group!.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6, height: 6,
                          margin: const EdgeInsets.only(right: 5),
                          decoration: BoxDecoration(
                            color: task.group!.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          task.group!.name,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: task.group!.color,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                // Empty box keeps the due date right-aligned when no group set
                  const SizedBox(),

                // Due date turns red with a warning icon when overdue
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (overdue)
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(Icons.warning_amber_rounded,
                            size: 13, color: Color(0xFFEF4444)),
                      ),
                    Text(
                      task.dueDate,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: overdue ? FontWeight.w600 : FontWeight.w400,
                        color: overdue
                            ? const Color(0xFFEF4444) // red if overdue
                            : Colors.grey.shade500,   // grey if fine
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