// lib/main.dart
import 'package:flutter/material.dart';
import 'package:stackblue/config/app_theme.dart';
import 'package:stackblue/navigation/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StackBlueApp());
}

/// Aplicación principal de StackBlue para control de macrofotografía.
///
/// Punto de entrada que configura el tema y las rutas de navegación.
class StackBlueApp extends StatelessWidget {
  const StackBlueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StackBlue',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
    );
  }
}