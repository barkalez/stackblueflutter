import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bluetooth/bluetooth_manage.dart'; // Importar BluetoothManager
import '../screens/control_screen.dart'; // Importar ControlScreen

class ListPerfilesScreen extends StatefulWidget {
  const ListPerfilesScreen({super.key});

  @override
  ListPerfilesScreenState createState() => ListPerfilesScreenState();
}

class ListPerfilesScreenState extends State<ListPerfilesScreen> {
  List<String> _perfiles = [];

  @override
  void initState() {
    super.initState();
    _loadPerfiles();
    _startListeningToData();
  }

  Future<void> _loadPerfiles() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _perfiles = prefs.getStringList('perfiles') ?? [];
    });
  }

  void _startListeningToData() {
    BluetoothManager.onDataReceived().listen((data) {
      if (mounted) {
        if (data.contains("StackBlue Sincronizado")) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('StackBlue sincronizado'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ControlScreen()),
          );
        }
      }
    });
  }

  Future<void> _sendProfileData(String nombre) async {
    final prefs = await SharedPreferences.getInstance();
    final String? perfilData = prefs.getString('perfil_$nombre');
    if (perfilData != null) {
      // Concatenar el nombre del perfil y los datos del perfil en una sola cadena sin saltos de línea
      final String dataToSend = '$nombre$perfilData';
      // Enviar la cadena de texto al dispositivo StackBlue
      bool success = await BluetoothManager.sendDataToDevice(dataToSend);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Datos del perfil "$nombre" enviados')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al enviar datos del perfil "$nombre"')),
          );
        }
      }
    }
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
        title: const Text('Lista de Perfiles'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _perfiles.isEmpty
          ? const Center(
              child: Text(
                'No hay perfiles creados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
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
                        onPressed: () => _sendProfileData(_perfiles[index]),
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