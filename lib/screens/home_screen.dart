import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'adjust_screen.dart'; // Importar la pantalla de ajustes
import 'cperfil_screen.dart'; // Importar la pantalla de crear perfil
import '../lists/list_perfiles.dart'; // Importar la pantalla de lista de perfiles

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<String> _perfiles = [];

  @override
  void initState() {
    super.initState();
    _loadPerfiles();
  }

  Future<void> _loadPerfiles() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _perfiles = prefs.getStringList('perfiles') ?? [];
    });
  }

  void _exitApp() {
    exit(0); // Cierra la aplicación
  }

  void _openSettings() {
    // Navegar a la pantalla de ajustes
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdjustScreen()),
    );
  }

  void _createProfile() {
    // Navegar a la pantalla de crear perfil
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CPerfilScreen()),
    );
  }

  void _loadProfiles() {
    // Navegar a la pantalla de lista de perfiles
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ListPerfilesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Quitar la flecha de retroceso
        title: const Text(
          'StackBlue',
          style: TextStyle(
            fontSize: 24, // Tamaño del texto
            fontWeight: FontWeight.bold, // Peso del texto
            color: Colors.white, // Color del texto
          ),
        ),
        backgroundColor: Colors.blueAccent, // Color de fondo del AppBar
        elevation: 4.0, // Sombra del AppBar
        centerTitle: true, // Centrar el título
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_perfiles.isEmpty)
              SizedBox(
                width: 200, // Ancho fijo para ambos botones
                child: ElevatedButton(
                  onPressed: _createProfile,
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
                  child: const Text('Crear Perfil'),
                ),
              )
            else
              SizedBox(
                width: 200, // Ancho fijo para ambos botones
                child: ElevatedButton(
                  onPressed: _loadProfiles,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent, // Color de fondo del botón Cargar perfil
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
                  child: const Text('Cargar Perfil'),
                ),
              ),
            const SizedBox(height: 16), // Espacio entre los botones
            SizedBox(
              width: 200, // Ancho fijo para ambos botones
              child: ElevatedButton(
                onPressed: _openSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent, // Color de fondo del botón de ajustes
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
                child: const Text('Ajustes'),
              ),
            ),
            const SizedBox(height: 32), // Espacio adicional para el botón de salir
            SizedBox(
              width: 200, // Ancho fijo para ambos botones
              child: ElevatedButton(
                onPressed: _exitApp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent, // Color de fondo del botón de salir
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
                child: const Text('Salir'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}