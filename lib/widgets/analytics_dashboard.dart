import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnalyticsDashboard extends StatelessWidget {
  final int totalTasks;
  final int completedTasks;
  final int inProgressTasks;
  final int pendingTasks;
  final double completionRate;
  final int totalHours;

  const AnalyticsDashboard({
    super.key,
    required this.totalTasks,
    required this.completedTasks,
    required this.inProgressTasks,
    required this.pendingTasks,
    required this.completionRate,
    required this.totalHours,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Completion Rate',
                  '${completionRate.toInt()}%',
                  const Color(0xFF4CAF50),
                  Icons.check_circle_outline,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Total Hours',
                  '$totalHours',
                  const Color(0xFFFF9800),
                  Icons.access_time,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Task Distribution Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Task Distribution',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1C1E),
                  ),
                ),
                const SizedBox(height: 32),
                
                if (totalTasks == 0)
                  _buildEmptyState()
                else
                  Row(
                    children: [
                      // Donut Chart
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: const Size(140, 140),
                              painter: DonutChartPainter(
                                completed: completedTasks,
                                inProgress: inProgressTasks,
                                pending: pendingTasks,
                                total: totalTasks,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$totalTasks',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1C1E),
                                  ),
                                ),
                                const Text(
                                  'Tasks',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6C7278),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 40),
                      // Legend
                      Expanded(
                        child: Column(
                          children: [
                            _buildLegendItem('Completed', '$completedTasks', const Color(0xFF4CAF50)),
                            const SizedBox(height: 16),
                            _buildLegendItem('In Progress', '$inProgressTasks', const Color(0xFFFF9800)),
                            const SizedBox(height: 16),
                            _buildLegendItem('Pending', '$pendingTasks', const Color(0xFF909497)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color iconColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6C7278),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1C1E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, String count, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6C7278),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          count,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1C1E),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: const [
            Icon(Icons.assignment_outlined, size: 64, color: Color(0xFFD1D5DB)),
            SizedBox(height: 16),
            Text(
              'No tasks generated yet',
              style: TextStyle(
                color: Color(0xFF6C7278),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Create a project to see analytics',
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final int completed;
  final int inProgress;
  final int pending;
  final int total;

  DonutChartPainter({
    required this.completed,
    required this.inProgress,
    required this.pending,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = radius * 0.25;
    final paintRadius = radius - (strokeWidth / 2);
    final rect = Rect.fromCircle(center: center, radius: paintRadius);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    double startAngle = -math.pi / 2;

    if (completed > 0) {
      paint.color = const Color(0xFF4CAF50);
      double sweep = (completed / total) * 2 * math.pi;
      canvas.drawArc(rect, startAngle, sweep - 0.05, false, paint);
      startAngle += sweep;
    }

    if (inProgress > 0) {
      paint.color = const Color(0xFFFF9800);
      double sweep = (inProgress / total) * 2 * math.pi;
      canvas.drawArc(rect, startAngle, sweep - 0.05, false, paint);
      startAngle += sweep;
    }

    if (pending > 0) {
      paint.color = const Color(0xFF909497);
      double sweep = (pending / total) * 2 * math.pi;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) => true;
}
