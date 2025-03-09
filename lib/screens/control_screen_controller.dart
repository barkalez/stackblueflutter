// lib/screens/control_screen_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../bluetooth/bluetooth_service.dart';

class ControlScreenController extends ChangeNotifier {
  final BluetoothService bluetoothService;
  final Logger _logger = Logger();
  StreamSubscription<String>? _positionSubscription;
  String _buffer = '';
  bool _isSendingCommand = false;
  double _currentPosition = 0.0;

  static const int stepsPerRevolution = 3200;
  static const double maxSteps = 40000.0;

  ControlScreenController(this.bluetoothService) {
    _startListeningToPosition();
  }

  bool get isSendingCommand => _isSendingCommand;
  double get currentPosition => _currentPosition;

  void _startListeningToPosition() {
    _logger.i('Iniciando escucha de posición');
    _positionSubscription?.cancel(); // Cancelamos cualquier suscripción previa
    _positionSubscription = bluetoothService.receiveData().listen(
      (data) {
        _logger.i('Datos crudos recibidos: "$data"');
        _buffer += data;

        if (_buffer.contains('\n')) {
          List<String> lines = _buffer.split('\n');
          _buffer = lines.last;
          for (var line in lines.sublist(0, lines.length - 1)) {
            line = line.trim();
            if (line.isEmpty) continue;

            _logger.i('Línea procesada: "$line"');
            if (line.startsWith("POS:")) {
              final positionStr = line.replaceFirst("POS:", "").trim();
              _logger.i('Posición extraída: "$positionStr"');
              final position = double.tryParse(positionStr) ?? _currentPosition;
              updatePosition(position);
            } else if (line == "pos0") {
              updatePosition(0);
              _logger.i('Homing recibido, posición reiniciada a 0');
            } else if (line == "END") {
              _logger.i('Fin de trayecto alcanzado');
            } else {
              _logger.w('Datos no reconocidos: "$line"');
            }
          }
        }
      },
      onError: (e) => _logger.e('Error al recibir posición: $e'),
      onDone: () => _logger.i('Stream de datos cerrado'),
    );
  }

  void updatePosition(double position) {
    _currentPosition = position.clamp(0, maxSteps);
    _logger.i('Posición actualizada: $_currentPosition');
    notifyListeners();
  }

  Future<void> sendHomingCommand() async {
    await _sendCommand("G28\n", 'Comando "G28" enviado a StackBlue', "Homing iniciado");
  }

  Future<void> sendOneRevolutionForward() async {
    double newPosition = (_currentPosition + stepsPerRevolution).clamp(0, maxSteps);
    final command = "G1 X${newPosition.round()} F1000\n";
    await _sendCommand(command, '1 revolución adelante: $command');
  }

  Future<void> sendOneRevolutionBackward() async {
    double newPosition = (_currentPosition - stepsPerRevolution).clamp(0, maxSteps);
    final command = "G1 X${newPosition.round()} F1000\n";
    await _sendCommand(command, '1 revolución atrás: $command');
  }

  Future<void> sendSliderPosition(double position) async {
    final command = "G1 X${position.round()} F1000\n";
    await _sendCommand(command, 'Enviado comando desde slider: $command');
  }

  Future<void> _sendCommand(String command, String logMessage, [String? successMessage]) async {
    _isSendingCommand = true;
    notifyListeners();
    try {
      await bluetoothService.sendCommand(command);
      _logger.i(logMessage);
      if (successMessage != null) {
        _logger.i(successMessage);
      }
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
    bluetoothService.disconnect();
    super.dispose();
  }
}