import 'package:flutter/material.dart';

class QuickActionItem extends StatelessWidget{
  final IconData icon; //fields
  final String label;

  //constructor
  const QuickActionItem({
    super.key,
    required this.icon,
    required this.label
});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16)
          ),
          child: Icon(icon, size: 28,color: Colors.blue),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 14))
      ],
    );
  }
}