import 'package:flutter/material.dart';
import 'package:bluetooth_classic/bluetooth_classic.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_button.dart';
import 'package:logger/logger.dart';

class ControlScreen extends StatefulWidget {
  final BluetoothClassic bluetoothPlugin;
  final String deviceAddress;

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

  // Comando G28
  Future<void> _sendG28Command() async {
    try {
      await widget.bluetoothPlugin.write("G28\n");
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

  // Nuevo comando para el movimiento personalizado
  Future<void> _sendCustomMovementCommand() async {
    try {
      // 3200 pulsos = 1 vuelta (microstepping x16)

      // Velocidades decrecientes (en pasos por segundo)
      const int initialSpeed = 3200; // 1 rev/s
      const int speed2 = 2400;       // 0.75 rev/s
      const int speed3 = 1600;       // 0.5 rev/s
      const int speed4 = 800;        // 0.25 rev/s

      // Secuencia de comandos G1
      // 3 vueltas en un sentido (9600 pasos)
      await widget.bluetoothPlugin.write("G1 X9600 F$initialSpeed\n");
      _logger.i('Enviado: 3 vueltas adelante a $initialSpeed pasos/s');
      await Future.delayed(Duration(milliseconds: 3000)); // Espera aproximada

      // 2 vueltas en sentido contrario (9600 - 6400 = 3200 pasos)
      await widget.bluetoothPlugin.write("G1 X3200 F$speed2\n");
      _logger.i('Enviado: 2 vueltas atrás a $speed2 pasos/s');
      await Future.delayed(Duration(milliseconds: 2700));

      // 1 vuelta cambiando sentido (3200 + 3200 = 6400 pasos)
      await widget.bluetoothPlugin.write("G1 X6400 F$speed3\n");
      _logger.i('Enviado: 1 vuelta adelante a $speed3 pasos/s');
      await Future.delayed(Duration(milliseconds: 2000));

      // Media vuelta cambiando sentido (6400 - 1600 = 4800 pasos)
      await widget.bluetoothPlugin.write("G1 X4800 F$speed4\n");
      _logger.i('Enviado: 0.5 vueltas atrás a $speed4 pasos/s');
      await Future.delayed(Duration(milliseconds: 1000));

    } catch (e) {
      _logger.e('Error al enviar comandos de movimiento personalizado: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar comandos: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Control Screen'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(
              text: 'Send G28 Command',
              color: Colors.green,
              onPressed: _sendG28Command,
            ),
            const SizedBox(height: 20), // Espacio entre botones
            CustomButton(
              text: 'Custom Movement',
              color: Colors.blue,
              onPressed: _sendCustomMovementCommand,
            ),
          ],
        ),
      ),
    );
  }
}