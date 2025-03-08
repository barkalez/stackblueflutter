// lib/config/app_theme.dart
import 'package:flutter/material.dart';

/// Configuración del tema global para StackBlue.
class AppTheme {
  AppTheme._(); // Constructor privado para evitar instancias

  // Tema claro de la aplicación
  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 4,
      shadowColor: Colors.black54,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black87),
    ),
  );
}