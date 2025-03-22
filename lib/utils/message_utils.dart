import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

/// Utilidad para mostrar mensajes al usuario de manera consistente.
/// Centraliza la visualización de mensajes informativos, de éxito y de error.
class MessageUtils {
  static final Logger _logger = Logger();
  
  /// Muestra un mensaje de éxito
  static void showSuccessMessage(BuildContext context, String message) {
    _logger.i('SUCCESS: $message');
    
    // Capturar el messenger para evitar errores de contexto
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  /// Muestra un mensaje de error
  static void showErrorMessage(BuildContext context, String message) {
    _logger.e('ERROR: $message');
    
    // Capturar el messenger para evitar errores de contexto
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  /// Muestra un mensaje informativo
  static void showInfoMessage(BuildContext context, String message) {
    _logger.i('INFO: $message');
    
    // Capturar el messenger para evitar errores de contexto
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  /// Muestra un diálogo de confirmación
  static Future<bool> showConfirmDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
  
  /// Muestra un diálogo de progreso
  static void showProgressDialog(
    BuildContext context,
    String message, {
    bool dismissible = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: dismissible,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
  
  /// Cierra el diálogo actual
  static void closeDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
  
  /// Registra un mensaje informativo
  static void logInfo(String message) {
    _logger.i(message);
  }
  
  /// Registra un mensaje de error
  static void logError(String message) {
    _logger.e(message);
  }
  
  /// Registra un mensaje de depuración
  static void logDebug(String message) {
    _logger.d(message);
  }
} 