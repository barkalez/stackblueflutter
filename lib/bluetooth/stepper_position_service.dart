import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'bluetooth_interface.dart';
import '../models/profile.dart';
import 'bluetooth_connection_service.dart';

/// Servicio que gestiona la posición del motor paso a paso y envía comandos
/// específicos relacionados con el movimiento a través de la interfaz Bluetooth.
class StepperPositionService extends ChangeNotifier {
  final BluetoothInterface _bluetoothInterface;
  final Logger _logger = Logger();
  StreamSubscription? _positionSubscription;
  
  // Posición actual del motor
  double _currentPosition = 0.0;
  
  // Posiciones para el apilado
  double _stackStartPosition = 0.0;
  double _stackEndPosition = 0.0;
  
  // Perfil seleccionado
  Profile? _selectedProfile;
  
  // Control del movimiento
  bool _isMoving = false;
  
  // Constructor
  StepperPositionService(this._bluetoothInterface) {
    // Suscribirse a las actualizaciones de posición si el servicio de conexión
    // lo soporta
    if (_bluetoothInterface is BluetoothConnectionService) {
      final connectionService = _bluetoothInterface;
      _positionSubscription = connectionService.positionUpdates.listen(_updatePosition);
    }
  }
  
  // Getters
  double get currentPosition => _currentPosition;
  double get stackStartPosition => _stackStartPosition;
  double get stackEndPosition => _stackEndPosition;
  Profile? get selectedProfile => _selectedProfile;
  bool get isMoving => _isMoving;
  
  // Setters
  void setStackStartPosition(double position) {
    _stackStartPosition = position;
    notifyListeners();
  }
  
  void setStackEndPosition(double position) {
    _stackEndPosition = position;
    notifyListeners();
  }
  
  void setSelectedProfile(Profile profile) {
    _selectedProfile = profile;
    notifyListeners();
  }
  
  void _updatePosition(double position) {
    _currentPosition = position;
    notifyListeners();
  }
  
  // Métodos para controlar el motor
  
  /// Actualiza manualmente la posición (sin mover el motor físicamente)
  void updatePosition(double position) {
    _currentPosition = position.clamp(0.0, 40000.0);
    notifyListeners();
  }
  
  /// Mueve el motor a una posición específica
  Future<void> moveToPosition(double position, {int speed = 3200, int acceleration = 2000}) async {
    try {
      _isMoving = true;
      notifyListeners();
      
      final command = 'G1X${position.toInt()}F${speed}A${acceleration}';
      _logger.i('Enviando comando para mover a posición $position: $command');
      await _bluetoothInterface.sendCommand(command);
      
      _isMoving = false;
      notifyListeners();
    } catch (e) {
      _isMoving = false;
      notifyListeners();
      _logger.e('Error al mover a posición $position: $e');
      rethrow;
    }
  }
  
  /// Mueve el motor un número de pasos desde la posición actual
  Future<void> moveSteps(int steps, {int speed = 3200, int acceleration = 2000}) async {
    try {
      if (steps == 0) return;
      
      _isMoving = true;
      notifyListeners();
      
      final newPosition = _currentPosition + steps;
      if (newPosition < 0 || newPosition > 40000) {
        throw Exception('Posición fuera de rango: $newPosition');
      }
      
      await moveToPosition(newPosition, speed: speed, acceleration: acceleration);
      
      _isMoving = false;
      notifyListeners();
    } catch (e) {
      _isMoving = false;
      notifyListeners();
      _logger.e('Error al mover $steps pasos: $e');
      rethrow;
    }
  }
  
  /// Inicia el movimiento continuo en la dirección especificada
  Future<void> startContinuousMovement(
    bool forward, {
    int speed = 3200,
    int acceleration = 2000
  }) async {
    try {
      _isMoving = true;
      notifyListeners();
      
      // Establecemos primero velocidad y aceleración
      await _bluetoothInterface.sendCommand('F$speed');
      await Future.delayed(const Duration(milliseconds: 100));
      await _bluetoothInterface.sendCommand('A$acceleration');
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Enviamos comando de movimiento continuo
      final command = forward ? 'CONT+' : 'CONT-';
      _logger.i('Iniciando movimiento continuo: $command');
      await _bluetoothInterface.sendCommand(command);
      
      // No cambiamos _isMoving a false porque el motor sigue en movimiento
      // hasta que se llame a stopMovement
    } catch (e) {
      _isMoving = false;
      notifyListeners();
      _logger.e('Error al iniciar movimiento continuo: $e');
      rethrow;
    }
  }
  
  /// Detiene cualquier movimiento en curso
  Future<void> stopMovement() async {
    try {
      _logger.i('Deteniendo movimiento');
      await _bluetoothInterface.sendCommand('STOP');
      
      _isMoving = false;
      notifyListeners();
    } catch (e) {
      _logger.e('Error al detener movimiento: $e');
      rethrow;
    }
  }
  
  /// Rutina de prueba del motor
  Future<void> testMotor({
    int speed = 1600,
    int acceleration = 1000,
    int steps = 800
  }) async {
    try {
      _isMoving = true;
      notifyListeners();
      
      // Guardar posición inicial
      final initialPosition = _currentPosition;
      
      // Movimiento 1: Avanzar
      await moveSteps(steps, speed: speed, acceleration: acceleration);
      await Future.delayed(const Duration(seconds: 1));
      
      // Movimiento 2: Retroceder
      await moveSteps(-steps, speed: speed, acceleration: acceleration);
      await Future.delayed(const Duration(seconds: 1));
      
      // Volver a la posición inicial
      await moveToPosition(initialPosition, speed: speed, acceleration: acceleration);
      
      _isMoving = false;
      notifyListeners();
    } catch (e) {
      _isMoving = false;
      notifyListeners();
      _logger.e('Error en prueba de motor: $e');
      rethrow;
    }
  }
  
  /// Ejecuta una rutina de apilado entre las posiciones establecidas
  Future<void> executeStacking({
    required int numPhotos,
    required int speedForward,
    required int speedBackward,
    required int acceleration,
    required int delayBetweenPhotos,
  }) async {
    if (_stackStartPosition >= _stackEndPosition) {
      throw Exception('La posición inicial debe ser menor que la final');
    }
    
    if (numPhotos < 2) {
      throw Exception('Se necesitan al menos 2 fotos para apilar');
    }
    
    try {
      _isMoving = true;
      notifyListeners();
      
      // Calcular distancia entre fotos
      final totalDistance = _stackEndPosition - _stackStartPosition;
      final stepsBetweenPhotos = totalDistance / (numPhotos - 1);
      
      // Ir a la posición inicial
      await moveToPosition(_stackStartPosition, speed: speedForward, acceleration: acceleration);
      await Future.delayed(Duration(milliseconds: delayBetweenPhotos));
      
      // Hacer las fotos moviéndose entre cada una
      for (int i = 1; i < numPhotos; i++) {
        final nextPosition = _stackStartPosition + (stepsBetweenPhotos * i);
        await moveToPosition(nextPosition, speed: speedForward, acceleration: acceleration);
        await Future.delayed(Duration(milliseconds: delayBetweenPhotos));
      }
      
      // Volver a la posición inicial
      await moveToPosition(_stackStartPosition, speed: speedBackward, acceleration: acceleration);
      
      _isMoving = false;
      notifyListeners();
    } catch (e) {
      _isMoving = false;
      notifyListeners();
      _logger.e('Error en rutina de apilado: $e');
      rethrow;
    }
  }
  
  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
    // No cerramos la conexión Bluetooth aquí porque puede ser compartida
    // con otros servicios
  }
} 