// lib/screens/control_screen_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:stackblue/models/profile.dart';
import '../bluetooth/bluetooth_service.dart';

/// Enumeración para identificar el tipo de operación
enum CommandOperation {
  sendSliderPosition,
  sendContinuousMovement,
  stopMovement,
  homingCommand,
  genericCommand
}

class ControlScreenController extends ChangeNotifier {
  final BluetoothService bluetoothService;
  final Logger _logger = Logger();
  StreamSubscription<String>? _positionSubscription;
  bool _isSendingCommand = false;

  static const int stepsPerRevolution = 3200;
  late double maxSteps;

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
    // Obtener el perfil activo y establecer maxSteps
    Profile? activeProfile = bluetoothService.selectedProfile;
    
    // Si hay un perfil activo, usar su totalDistance, de lo contrario usar valor por defecto
    maxSteps = activeProfile?.totalDistance ?? 40000;
    
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

  /// Método centralizado para manejar errores en las operaciones
  void _handleError(Object error, CommandOperation operation) {
    String operationName;
    
    switch (operation) {
      case CommandOperation.sendSliderPosition:
        operationName = 'al enviar posición';
        break;
      case CommandOperation.sendContinuousMovement:
        operationName = 'al enviar comando de movimiento continuo';
        break;
      case CommandOperation.stopMovement:
        operationName = 'al detener movimiento';
        break;
      case CommandOperation.homingCommand:
        operationName = 'en comando de homing';
        break;
      case CommandOperation.genericCommand:
      operationName = 'al enviar comando';
        break;
    }
    
    final errorMessage = 'Error $operationName: $error';
    _logger.e(errorMessage);
    
    // Asegurar que el estado se restablezca en caso de error
    _isSendingCommand = false;
    notifyListeners();
    
    // Propagar el error para su manejo en la UI
    throw Exception(errorMessage);
  }

  Future<void> sendSliderPosition(double position) async {
    final command = "G1 X${position.round()} F$currentSpeed A$currentAcceleration\n";
    
    try {
      await _sendCommand(command, 'Enviado comando desde slider: $command');
    } catch (e) {
      _handleError(e, CommandOperation.sendSliderPosition);
    }
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
      _handleError(e, CommandOperation.sendContinuousMovement);
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
      _handleError(e, CommandOperation.stopMovement);
    } finally {
      _isSendingCommand = false;
      notifyListeners();
    }
  }

  Future<void> sendHomingCommand() async {
    const command = "G28\n";
    
    try {
      await _sendCommand(command, 'Enviado comando de homing: $command');
    } catch (e) {
      _handleError(e, CommandOperation.homingCommand);
    }
  }

  Future<void> _sendCommand(String command, String logMessage) async {
    if (_isSendingCommand) return;
    
    _isSendingCommand = true;
    notifyListeners();
    try {
      await bluetoothService.sendCommand(command);
      _logger.i(logMessage);
    } catch (e) {
      _handleError(e, CommandOperation.genericCommand);
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