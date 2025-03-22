import 'dart:async';
import 'package:flutter/material.dart';
import '../../bluetooth/bluetooth_device.dart';
import '../../models/profile.dart';

/// Define el contrato para cualquier implementación de servicio Bluetooth.
/// 
/// Proporciona un conjunto de métodos para la gestión de la conexión Bluetooth,
/// escaneo de dispositivos y control de motor.
abstract class BluetoothInterface extends ChangeNotifier {
  // Propiedades de estado
  bool get isConnected;
  bool get isScanning;
  double get currentPosition;
  String? get lastConnectedAddress;
  Profile? get selectedProfile;
  List<BluetoothDevice> get discoveredDevices;
  
  // Posiciones de apilado
  double get stackStartPosition;
  double get stackEndPosition;
  void setStackStartPosition(double position);
  void setStackEndPosition(double position);
  
  // Gestión de perfiles
  void setSelectedProfile(Profile profile);
  
  // Escaneo y conexión
  Stream<BluetoothDevice> scanDevices();
  Future<void> startScan();
  Future<void> stopScan();
  Future<void> connect(String address);
  Future<void> reconnect();
  Future<void> disconnect();
  
  // Gestión de movimiento
  Future<void> moveToPosition(double position, {int speed = 3200, int acceleration = 2000});
  Future<void> moveSteps(int steps, {int speed = 3200, int acceleration = 2000});
  Future<void> sendContinuousMovement(bool forward, {int speed = 3200, int acceleration = 2000});
  Future<void> stopMovement();
  Future<void> homePosition();
  Future<void> testMotor({int speed = 1600, int acceleration = 1000, int steps = 800});
  Future<void> executeStacking({
    required int numPhotos,
    required int speedForward,
    required int speedBackward,
    required int acceleration,
    required int delayBetweenPhotos,
  });
  Future<void> sendCommand(String command);
  Stream<String> receiveData();
  Stream<double> positionUpdates();
  
  // Gestión de recursos
  @override
  Future<void> dispose();
  
  // Verificación de conexión
  Future<bool> verifyConnectionStatus();
} 