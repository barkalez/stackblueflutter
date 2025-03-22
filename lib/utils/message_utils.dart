import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'dart:async';

/// Utilidad para mostrar mensajes al usuario de manera consistente.
/// Centraliza la visualización de mensajes informativos, de éxito y de error.
class MessageUtils {
  static final Logger _logger = Logger();
  
  /// Muestra un mensaje de éxito
  static void showSuccessMessage(BuildContext context, String message) {
    _logger.i('SUCCESS: $message');
    _showCustomToast(context, message, Colors.green.shade700);
  }
  
  /// Muestra un mensaje de error
  static void showErrorMessage(BuildContext context, String message) {
    _logger.e('ERROR: $message');
    _showCustomToast(context, message, Colors.red.shade700);
  }
  
  /// Muestra un mensaje informativo
  static void showInfoMessage(BuildContext context, String message) {
    _logger.i('INFO: $message');
    _showCustomToast(context, message, Colors.blue.shade700);
  }
  
  /// Muestra un mensaje tipo toast personalizado que no afecta el layout
  static void _showCustomToast(BuildContext context, String message, Color backgroundColor) {
    // Crear widget flotante para mostrar el mensaje
    final overlay = CustomToastOverlay(
      message: message,
      backgroundColor: backgroundColor,
    );
    
    // Mostrar en modo overlay
    overlay.show(context);
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
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

/// Widget para mostrar un toast personalizado como overlay
class CustomToastOverlay {
  final String message;
  final Color backgroundColor;
  OverlayEntry? _entry;
  Timer? _timer;
  
  CustomToastOverlay({
    required this.message,
    required this.backgroundColor,
  });
  
  void show(BuildContext context) {
    // Cerrar cualquier toast previo
    _hideToast();
    
    _entry = OverlayEntry(
      builder: (BuildContext context) {
        return IgnorePointer(
          child: _ToastWidget(
            message: message,
            backgroundColor: backgroundColor,
          ),
        );
      },
    );
    
    Overlay.of(context).insert(_entry!);
    
    // Cerrar automáticamente después de 2 segundos
    _timer = Timer(const Duration(seconds: 2), () {
      _hideToast();
    });
  }
  
  void _hideToast() {
    _timer?.cancel();
    _timer = null;
    
    if (_entry != null) {
      _entry!.remove();
      _entry = null;
    }
  }
}

/// Widget visual para el toast
class _ToastWidget extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  
  const _ToastWidget({
    required this.message,
    required this.backgroundColor,
  });
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Expanded(child: SizedBox()),
            // Posicionar al fondo con margen
            Padding(
              padding: const EdgeInsets.only(bottom: 80.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.2),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 