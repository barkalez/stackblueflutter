// lib/widgets/custom_appbar.dart
import 'package:flutter/material.dart';

/// Una barra de aplicaciones personalizada con título centrado y estilo consistente.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarTheme = theme.appBarTheme;

    return AppBar(
      automaticallyImplyLeading: false,
      leading: leading,
      title: Text(
        title,
        style: appBarTheme.titleTextStyle ??
            const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
      ),
      centerTitle: true,
      backgroundColor: appBarTheme.backgroundColor ?? Colors.blue,
      elevation: appBarTheme.elevation ?? 4,
      shadowColor: appBarTheme.shadowColor ?? Colors.black54, // Corregido
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}