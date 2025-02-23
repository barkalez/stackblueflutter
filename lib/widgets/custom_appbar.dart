import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false, // Quita la flecha de back
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.blue,
      elevation: 4,
      shadowColor: const Color.fromRGBO(0, 0, 0, 0.5),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}