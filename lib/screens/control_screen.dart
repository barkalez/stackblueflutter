import 'package:flutter/material.dart';
import 'package:bluetooth_classic/bluetooth_classic.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_button.dart';
import 'package:logger/logger.dart';

class ControlScreen extends StatefulWidget {
  final BluetoothClassic bluetoothPlugin; // Recibimos la instancia conectada
  final String deviceAddress; // Dirección del dispositivo conectado

  const ControlScreen({
    super.key,
    required this.bluetoothPlugin,
    required this.deviceAddress,
  });

  @override
  ControlScreenState createState() => ControlScreenState();
}

class ControlScreenState extends State<ControlScreen> {
  final Logger _logger = Logger();

  Future<void> _sendCommand() async {
    try {
      await widget.bluetoothPlugin.write("G28\n"); // Usamos la instancia recibida
      _logger.i('Comando "G28" enviado a StackBlue');
    } catch (e) {
      _logger.e('Error al enviar comando "G28": $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar comando: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    // No desconectamos aquí para mantener la conexión viva si regresamos
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Control Screen'),
      body: Center(
        child: CustomButton(
          text: 'Send G28 Command',
          color: Colors.green,
          onPressed: _sendCommand,
        ),
      ),
    );
  }
}