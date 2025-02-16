// Importa el paquete de Flutter para construir la interfaz de usuario.
import 'package:flutter/material.dart';
// Importa la pantalla de dispositivos desde el archivo correspondiente.
import 'screens/devices_screen.dart';

// Función principal que se ejecuta al iniciar la aplicación.
void main() {
  // Ejecuta la aplicación Flutter.
  runApp(const MainApp());
}

// Define la clase MainApp que extiende StatelessWidget.
class MainApp extends StatelessWidget {
  // Constructor de la clase MainApp.
  const MainApp({super.key});

  // Método build que construye la interfaz de usuario.
  @override
  Widget build(BuildContext context) {
    // Retorna un widget MaterialApp que es la raíz de la aplicación.
    return MaterialApp(
      // Establece la pantalla inicial de la aplicación como DevicesScreen.
      home: const DevicesScreen(),
    );
  }
}
