import 'dart:async';
import 'bluetooth_device.dart';

/// Interfaz que define los métodos necesarios para un servicio Bluetooth.
/// Esta interfaz permite la implementación de diferentes proveedores Bluetooth
/// y facilita las pruebas unitarias.
abstract class BluetoothInterface {
  /// Indica si hay una conexión activa
  bool get isConnected;
  
  /// Dirección del último dispositivo conectado
  String? get lastConnectedAddress;
  
  /// Escanea dispositivos Bluetooth disponibles
  Stream<BluetoothDevice> scanDevices();
  
  /// Conecta a un dispositivo específico por su dirección
  Future<void> connect(String address);
  
  /// Intenta reconectar al último dispositivo conectado
  Future<void> reconnect();
  
  /// Envía un comando al dispositivo conectado
  Future<void> sendCommand(String command);
  
  /// Recibe datos del dispositivo conectado
  Stream<String> receiveData();
  
  /// Desconecta del dispositivo actual
  Future<void> disconnect();
  
  /// Limpia los recursos utilizados
  Future<void> dispose();
} 