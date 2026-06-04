import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../widgets/menu_button.dart';
import '../widgets/navigation_drawer.dart';

class TeamAnalytics extends StatelessWidget {
  const TeamAnalytics({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      endDrawer: CustomNavigationDrawer(activePage: 'Team Analytics'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1C1E)),
                      ),
                      const Text(
                        'Team Analytics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1C1E),
                        ),
                      ),
                    ],
                  ),
                  const MenuButton(),
                ],
              ),

              const SizedBox(height: 24),

              // Top Cards
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Completion Rate',
                      '29%',
                      const Color(0xFF4CAF50),
                      Icons.check_circle_outline,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      'Total Hours',
                      '84',
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
                                painter: DonutChartPainter(),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text(
                                    '7',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A1C1E),
                                    ),
                                  ),
                                  Text(
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
                              _buildLegendItem('Completed', '2', const Color(0xFF4CAF50)),
                              const SizedBox(height: 16),
                              _buildLegendItem('In Progress', '2', const Color(0xFFFF9800)),
                              const SizedBox(height: 16),
                              _buildLegendItem('Pending', '3', const Color(0xFF909497)),
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
        ),
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
}

class DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = radius * 0.25;
    final paintRadius = radius - (strokeWidth / 2);

    final rect = Rect.fromCircle(center: center, radius: paintRadius);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    double startAngle = -math.pi / 2; // Start from top

    // Completed (Green)
    paint.color = const Color(0xFF4CAF50);
    double sweepAngle1 = (2 / 7) * 2 * math.pi;
    canvas.drawArc(rect, startAngle, sweepAngle1 - 0.1, false, paint);
    startAngle += sweepAngle1;

    // In Progress (Orange)
    paint.color = const Color(0xFFFF9800);
    double sweepAngle2 = (2 / 7) * 2 * math.pi;
    canvas.drawArc(rect, startAngle, sweepAngle2 - 0.1, false, paint);
    startAngle += sweepAngle2;

    // Pending (Grey)
    paint.color = const Color(0xFF909497);
    double sweepAngle3 = (3 / 7) * 2 * math.pi;
    canvas.drawArc(rect, startAngle, sweepAngle3 - 0.1, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
