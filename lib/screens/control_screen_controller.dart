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

  // Valores de velocidad disponibles
  static const List<int> availableSpeeds = [100, 200, 400, 800, 1600, 3200];
  
  // Valores de aceleración disponibles
  static const List<int> availableAccelerations = [200, 500, 1000, 2000, 5000, 10000];
  
  // Índice de velocidad actual (por defecto 3200 - último índice)
  int _currentSpeedIndex = 5;
  
  // Índice de aceleración actual (por defecto 2000 - índice 3)
  int _currentAccelerationIndex = 3;
  
  // Getter para obtener la velocidad actual
  int get currentSpeed => availableSpeeds[_currentSpeedIndex];
  
  // Getter para obtener la aceleración actual
  int get currentAcceleration => availableAccelerations[_currentAccelerationIndex];
  
  // Getter para obtener el índice de velocidad actual
  int get currentSpeedIndex => _currentSpeedIndex;
  
  // Getter para obtener el índice de aceleración actual
  int get currentAccelerationIndex => _currentAccelerationIndex;
  
  // Método para actualizar la velocidad por índice
  void updateSpeedIndex(int index) {
    if (index >= 0 && index < availableSpeeds.length) {
      _currentSpeedIndex = index;
      _logger.i('Velocidad actualizada a: $currentSpeed pasos/segundo');
      notifyListeners();
    }
  }
  
  // Método para actualizar la aceleración por índice
  void updateAccelerationIndex(int index) {
    if (index >= 0 && index < availableAccelerations.length) {
      _currentAccelerationIndex = index;
      _logger.i('Aceleración actualizada a: $currentAcceleration pasos/segundo²');
      notifyListeners();
    }
  }

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
    final command = "G1 X${position.round()} F$currentSpeed A$currentAcceleration\n";
    await _sendCommand(command, 'Enviado comando desde slider: $command');
  }

  // Modificado: No debe bloquear la UI mientras el motor se mueve continuamente
  Future<void> sendContinuousMovement(bool forward) async {
    if (_isSendingCommand) return;
    
    _isSendingCommand = true;
    notifyListeners();
    
    try {
      // Incluir la velocidad y aceleración en el comando
      final command = forward 
          ? "CONT+F${currentSpeed}A$currentAcceleration\n" 
          : "CONT-F${currentSpeed}A$currentAcceleration\n";
      
      await bluetoothService.sendCommand(command);
      _logger.i('Enviado comando de movimiento continuo: $command');
    } catch (e) {
      _logger.e('Error al enviar comando de movimiento continuo: $e');
      _isSendingCommand = false;
      notifyListeners();
      rethrow;
    }
    // Mantener _isSendingCommand en true durante el movimiento continuo
  }

  // Modificado: Libera el estado de envío de comandos
  Future<void> stopContinuousMovement() async {
    try {
      final command = "STOP A$currentAcceleration\n";
      await bluetoothService.sendCommand(command);
      _logger.i('Enviado comando para detener movimiento: $command');
    } catch (e) {
      _logger.e('Error al enviar comando para detener: $e');
      rethrow;
    } finally {
      _isSendingCommand = false;
      notifyListeners();
    }
  }

  Future<void> sendHomingCommand() async {
    const command = "G28\n";
    await _sendCommand(command, 'Enviado comando de homing: $command');
  }

  Future<void> _sendCommand(String command, String logMessage) async {
    if (_isSendingCommand) return;
    
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