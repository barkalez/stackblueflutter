import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cperfil_screen.dart'; // Importar CPerfilScreen

class BPerfilScreen extends StatefulWidget {
  const BPerfilScreen({super.key});

  @override
  BPerfilScreenState createState() => BPerfilScreenState();
}

class BPerfilScreenState extends State<BPerfilScreen> {
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

  Future<void> _deleteProfile(String nombre) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> perfiles = prefs.getStringList('perfiles') ?? [];
    perfiles.remove(nombre);
    await prefs.setStringList('perfiles', perfiles);
    await prefs.remove('perfil_$nombre');
    if (mounted) {
      setState(() {
        _perfiles = perfiles;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil borrado'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _confirmDeleteProfile(String nombre) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar borrado'),
          content: Text('¿Estás seguro de que deseas borrar el perfil "$nombre"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteProfile(nombre);
              },
              child: const Text('Borrar'),
            ),
          ],
        );
      },
    );
  }

  final List<Color> _colors = [
    Colors.blueAccent,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.purple,
    Colors.teal,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Borrar Perfil'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _perfiles.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'No existen perfiles creados',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CPerfilScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Crear perfil'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _perfiles.length,
              itemBuilder: (context, index) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: SizedBox(
                      width: 200, // Ancho fijo para los botones
                      child: ElevatedButton(
                        onPressed: () => _confirmDeleteProfile(_perfiles[index]),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _colors[index % _colors.length], // Color del botón
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
                        child: Text(_perfiles[index]),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}