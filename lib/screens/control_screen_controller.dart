// lib/screens/control_screen_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../bluetooth/bluetooth_service.dart';

class ControlScreenController extends ChangeNotifier {
  final BluetoothService bluetoothService;
  final Logger _logger = Logger();
  StreamSubscription<String>? _positionSubscription;
  bool _isSendingCommand = false;

  static const int stepsPerRevolution = 3200;
  static const double maxSteps = 40000.0;

  ControlScreenController(this.bluetoothService) {
    _startListeningToPosition();
  }

  bool get isSendingCommand => _isSendingCommand;
  double get currentPosition => bluetoothService.currentPosition;

  void _startListeningToPosition() {
    _logger.i('Iniciando escucha de posición');
    _positionSubscription?.cancel();
    _positionSubscription = bluetoothService.receiveData().listen(
      (data) {
        _logger.i('Datos crudos recibidos: "$data"');
        // No necesitamos procesar aquí, BluetoothService lo hace
      },
      onError: (e) => _logger.e('Error al recibir posición: $e'),
      onDone: () => _logger.i('Stream de datos cerrado'),
    );
  }

  void updatePosition(double position) {
    bluetoothService.updatePosition(position); // Línea 38 corregida
    // No necesitamos notifyListeners aquí, BluetoothService ya lo hace
  }

  Future<void> sendSliderPosition(double position) async {
    final command = "G1 X${position.round()} F1000\n";
    await _sendCommand(command, 'Enviado comando desde slider: $command');
  }

  Future<void> sendHomingCommand() async {
    const command = "G28\n";
    await _sendCommand(command, 'Enviado comando de homing: $command');
  }

  Future<void> _sendCommand(String command, String logMessage) async {
    _isSendingCommand = true;
    notifyListeners();
    try {
      await bluetoothService.sendCommand(command);
      _logger.i(logMessage);
    } catch (e) {
      _logger.e('Error al enviar comando: $e');
      rethrow;
    } finally {
      _isSendingCommand = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }
}