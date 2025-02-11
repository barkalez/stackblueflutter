import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:logger/logger.dart'; // Importamos el logger

class ControlScreen extends StatefulWidget {
  final BluetoothConnection connection;

  const ControlScreen({super.key, required this.connection});

  @override
  ControlScreenState createState() => ControlScreenState(); // Modificamos aquí
}

class ControlScreenState extends State<ControlScreen> { // Cambiamos el nombre de la clase aquí
  final TextEditingController _controller = TextEditingController();
  final Logger _logger = Logger(); // Creamos una instancia de Logger

  // Enviar el texto a través de la conexión Bluetooth
  void _sendTextToESP32() async {
    String text = _controller.text.trim();
    if (text.isNotEmpty) {
      try {
        widget.connection.output.add(Uint8List.fromList(text.codeUnits)); // Enviar el texto
        await widget.connection.output.allSent; // Esperar a que se haya enviado el texto
        _logger.i('Texto enviado: $text'); // Usamos el logger para registrar el texto enviado
        _controller.clear(); // Limpiar el campo de texto
      } catch (e) {
        _logger.e('Error al enviar texto: $e'); // Logueamos el error
      }
    } else {
      _logger.w('El texto está vacío, no se puede enviar.'); // Aviso si el texto está vacío
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Control del Motor")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Texto que indica lo que puede hacer el usuario
            Text(
              "Escribe un comando para enviar al ESP32:",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            // TextField para ingresar el comando
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: "Comando",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            // Botón para enviar el texto
            ElevatedButton(
              onPressed: _sendTextToESP32,
              child: Text("Enviar"),
            ),
          ],
        ),
      ),
    );
  }
}
