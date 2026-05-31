import 'dart:async';
import 'package:flutter/material.dart';

class AILoadingScreen extends StatefulWidget {
  const AILoadingScreen({super.key});

  @override
  State<AILoadingScreen> createState() => _AILoadingScreenState();
}

class _AILoadingScreenState extends State<AILoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;

  int currentStep = 0;

  final List<String> steps = [
    "Analyzing project requirements",
    "Breaking down into milestones",
    "Calculating time commitments",
    "Generating 8-week timeline",
    "Creating task breakdown",
  ];

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
      lowerBound: 0.92,
      upperBound: 1.04,
    )..repeat(reverse: true);

    _startFakeProgress();
  }

  void _startFakeProgress() {
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (currentStep < steps.length - 1) {
        setState(() {
          currentStep++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Widget buildStep(int index, String title) {
    final bool completed = index < currentStep;
    final bool active = index == currentStep;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: completed || active ? 1 : 0.35,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: completed || active
                    ? const Color(0xFF1677FF)
                    : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: completed
                    ? const Icon(
                  Icons.check,
                  color: Colors.white,
                )
                    : Text(
                  "${index + 1}",
                  style: TextStyle(
                    color: active
                        ? Colors.white
                        : Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                    active ? FontWeight.w700 : FontWeight.w500,
                    color: active
                        ? Colors.black
                        : Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 28,
          ),

          child: Column(
            children: [

              const SizedBox(height: 20),

              ScaleTransition(
                scale: _pulseController,
                child: RotationTransition(
                  turns: _rotationController,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1677FF)
                          .withOpacity(0.12),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 56,
                      color: Color(0xFF1677FF),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 36),

              const Text(
                "Creating Your Plan",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF202124),
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                "AI is analyzing your project and generating a structured timeline",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 42),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: List.generate(
                    steps.length,
                        (index) => buildStep(index, steps[index]),
                  ),
                ),
              ),

              const SizedBox(height: 36),

              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: (currentStep + 1) / steps.length,
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade300,
                  color: const Color(0xFF1677FF),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                "${((currentStep + 1) / steps.length * 100).toInt()}%",
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}