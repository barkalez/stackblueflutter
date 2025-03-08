// lib/widgets/custom_button.dart
import 'package:flutter/material.dart';

/// Un botón personalizado con estilo elevado y opciones de personalización.
///
/// Utiliza el tema global para colores por defecto y permite ajustes específicos.
class CustomButton extends StatelessWidget {
  /// Texto mostrado en el botón.
  final String text;

  /// Color de fondo del botón (opcional, usa el tema si no se especifica).
  final Color? color;

  /// Acción a ejecutar al presionar el botón.
  final VoidCallback onPressed;

  /// Indica si el botón está habilitado (por defecto true).
  final bool enabled;

  /// Estilo opcional para el texto del botón.
  final TextStyle? textStyle;

  /// Padding opcional para el botón.
  final EdgeInsets? padding;

  /// Constructor constante para optimizar rendimiento.
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.enabled = true,
    this.textStyle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonTheme = theme.elevatedButtonTheme.style;

    return ElevatedButton(
      onPressed: enabled ? onPressed : null, // Null si está deshabilitado
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? theme.primaryColor, // Usa tema si no hay color
        foregroundColor: Colors.white,
        shadowColor: theme.shadowColor,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ).merge(buttonTheme), // Combina con el tema global si existe
      child: Text(
        text,
        style: textStyle ??
            const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
      ),
    );
  }
}