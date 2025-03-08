// lib/screens/control_screen.dart
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_button.dart';
import '../bluetooth/bluetooth_service.dart';

/// Pantalla de control para enviar comandos al dispositivo StackBlue.
///
/// Permite enviar comandos G28 y un movimiento personalizado al ESP32 conectado.
class ControlScreen extends StatefulWidget {
  final BluetoothService bluetoothService;
  final String deviceAddress;

  const ControlScreen({
    super.key,
    required this.bluetoothService,
    required this.deviceAddress,
  });

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  static final Logger _logger = Logger();
  bool _isSendingCommand = false;

  static const int _stepsPerRevolution = 3200;
  static const Map<String, int> _speeds = {
    'initial': 3200,
    'second': 2400,
    'third': 1600,
    'fourth': 800,
  };

  Future<void> _sendG28Command() async {
    setState(() => _isSendingCommand = true);
    try {
      await widget.bluetoothService.sendCommand("G28\n");
      _logger.i('Comando "G28" enviado a StackBlue');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Homing iniciado")),
        );
      }
    } catch (e) {
      _handleError('Error al enviar comando "G28": $e');
    } finally {
      if (mounted) {
        setState(() => _isSendingCommand = false);
      }
    }
  }

  Future<void> _sendCustomMovementCommand() async {
    setState(() => _isSendingCommand = true);
    try {
      await widget.bluetoothService.sendCommand(
        "G1 X${3 * _stepsPerRevolution} F${_speeds['initial']}\n",
      );
      _logger.i('3 vueltas adelante a ${_speeds['initial']} pasos/s');
      await widget.bluetoothService.sendCommand(
        "G1 X${1 * _stepsPerRevolution} F${_speeds['second']}\n",
      );
      _logger.i('2 vueltas atrás a ${_speeds['second']} pasos/s');
      await widget.bluetoothService.sendCommand(
        "G1 X${2 * _stepsPerRevolution} F${_speeds['third']}\n",
      );
      _logger.i('1 vuelta adelante a ${_speeds['third']} pasos/s');
      await widget.bluetoothService.sendCommand(
        "G1 X${1.5 * _stepsPerRevolution} F${_speeds['fourth']}\n",
      );
      _logger.i('0.5 vueltas atrás a ${_speeds['fourth']} pasos/s');
    } catch (e) {
      _handleError('Error al enviar comandos de movimiento personalizado: $e');
    } finally {
      if (mounted) {
        setState(() => _isSendingCommand = false);
      }
    }
  }

  void _handleError(String message) {
    _logger.e(message);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  void dispose() {
    widget.bluetoothService.disconnect(); // Desconectar al salir
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Control Screen'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButton(
                text: 'Send G28 Command',
                color: Colors.green,
                onPressed: _isSendingCommand ? () {} : _sendG28Command,
                enabled: !_isSendingCommand,
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Custom Movement',
                color: Colors.blue,
                onPressed: _isSendingCommand ? () {} : _sendCustomMovementCommand,
                enabled: !_isSendingCommand,
              ),
              if (_isSendingCommand) ...[
                const SizedBox(height: 20),
                const CircularProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}