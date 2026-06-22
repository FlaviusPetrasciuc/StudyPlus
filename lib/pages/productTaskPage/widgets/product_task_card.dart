import 'package:flutter/material.dart';
import '../models/product_task_module.dart';
import '../product_task_detail_page.dart';

class ProductTaskCard extends StatelessWidget {
  final ProductTask task;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  const ProductTaskCard({
    super.key,
    required this.task,
    required this.onUpdate,
    required this.onDelete,
  });

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

  // Formats a numeric hour value into a friendly string
  // e.g. 2.0 → "2h", 0.5 → "30m", 1.5 → "1h 30m", 0.004 → "15s"
  String _formatHours(double hours) {
    if (hours <= 0) return '0m';
    final totalSeconds = (hours * 3600).round();
    final h   = totalSeconds ~/ 3600;
    final m   = (totalSeconds % 3600) ~/ 60;
    final s   = totalSeconds % 60;

    final parts = <String>[];
    if (h > 0) parts.add('${h}h');
    if (m > 0) parts.add('${m}m');
    // Only show seconds if there are no hours or minutes
    if (s > 0 && h == 0 && m == 0) parts.add('${s}s');
    return parts.join(' ');
  }

  // Shows a confirmation dialog that drops down from the top
  void _confirmDelete(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Delete task',
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (dialogContext, animation, _, child) {
        final offset = Tween<Offset>(
          begin: const Offset(0, -1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

        return Align(
          alignment: Alignment.topCenter,
          child: SlideTransition(
            position: offset,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Material(
                  color: Colors.white, // explicit white, no Material 3 tint
                  borderRadius: BorderRadius.circular(16),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Delete task?',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.black87)),
                        const SizedBox(height: 8),
                        Text('Are you sure you want to delete "${task.title}"?',
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
                            ),
                            const SizedBox(width: 4),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(dialogContext);
                                onDelete();
                              },
                              child: const Text('Delete',
                                  style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
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
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => _confirmDelete(context),
                  child: Icon(Icons.delete_outline_rounded, size: 18, color: Colors.grey.shade400),
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

            // ── Group chip + time chip + due date ──
            Row(
              children: [

                // Group chip — shown whenever a group is set
                if (task.group != null) ...[
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
                  ),
                  const SizedBox(width: 8), // gap before the next chip
                ],

                // Time chip — shown whenever estimated time is set.
                // Independent of the group chip now, so both can appear together.
                if (task.estimatedHours > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF), // blue-50 background
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 12, color: Color(0xFF2563EB)),
                        const SizedBox(width: 4),
                        Text(
                          // Show remaining if hours logged, else show estimated
                          task.spentHours > 0
                              ? _formatHours(task.remainingHours)
                              : _formatHours(task.estimatedHours),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2563EB), // blue-600
                          ),
                        ),
                      ],
                    ),
                  ),

                // Pushes the due date to the far right regardless of
                // how many chips are showing on the left
                const Spacer(),

                // Due date (red + icon if overdue)
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
                            ? const Color(0xFFEF4444)
                            : Colors.grey.shade500,
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