import 'package:flutter/material.dart';
import 'cperfil_screen.dart'; // Importar la pantalla de crear perfil
import 'eperfil_screen.dart'; // Importar la pantalla de editar perfil
import 'bperfil_screen.dart'; // Importar la pantalla de borrar perfil

class AdjustScreen extends StatelessWidget {
  const AdjustScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 200, // Ancho fijo para los botones
              child: ElevatedButton(
                onPressed: () {
                  // Navegar a la pantalla de crear perfil
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CPerfilScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Color de fondo del botón Crear perfil
                  foregroundColor: Colors.white, // Color del texto del botón
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), // Padding del botón
                  textStyle: const TextStyle(
                    fontSize: 18, // Tamaño del texto
                    fontWeight: FontWeight.bold, // Peso del texto
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Bordes redondeados
                  ),
                ),
                child: const Text('Crear perfil'),
              ),
            ),
            const SizedBox(height: 16), // Espacio entre los botones
            SizedBox(
              width: 200, // Ancho fijo para los botones
              child: ElevatedButton(
                onPressed: () {
                  // Navegar a la pantalla de editar perfil
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EPerfilScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Color de fondo del botón Editar perfil
                  foregroundColor: Colors.white, // Color del texto del botón
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), // Padding del botón
                  textStyle: const TextStyle(
                    fontSize: 18, // Tamaño del texto
                    fontWeight: FontWeight.bold, // Peso del texto
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Bordes redondeados
                  ),
                ),
                child: const Text('Editar perfil'),
              ),
            ),
            const SizedBox(height: 16), // Espacio entre los botones
            SizedBox(
              width: 200, // Ancho fijo para los botones
              child: ElevatedButton(
                onPressed: () {
                  // Navegar a la pantalla de borrar perfil
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BPerfilScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Color de fondo del botón Borrar perfil
                  foregroundColor: Colors.white, // Color del texto del botón
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), // Padding del botón
                  textStyle: const TextStyle(
                    fontSize: 18, // Tamaño del texto
                    fontWeight: FontWeight.bold, // Peso del texto
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Bordes redondeados
                  ),
                ),
                child: const Text('Borrar perfil'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}