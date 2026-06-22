import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const MenuButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 45,
      height: 45,
      decoration: const BoxDecoration(
        color: Color(0xFF007AFF),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: onPressed ?? () {
          Scaffold.of(context).openEndDrawer();
        },
      ),
    );
  }
}
