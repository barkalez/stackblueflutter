import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart' as serial;
import 'package:logger/logger.dart';
import 'bluetooth_device.dart';

/// Servicio especializado para el escaneo de dispositivos Bluetooth.
/// Este servicio se encarga exclusivamente de descubrir dispositivos Bluetooth
/// disponibles y gestionar los permisos necesarios.
class BluetoothScannerService extends ChangeNotifier {
  final Logger _logger = Logger();
  bool _isScanning = false;
  final List<BluetoothDevice> _discoveredDevices = [];
  StreamController<BluetoothDevice>? _scanStreamController;
  
  // Getters
  bool get isScanning => _isScanning;
  List<BluetoothDevice> get discoveredDevices => List.unmodifiable(_discoveredDevices);
  
  /// Construye el servicio de escaneo
  BluetoothScannerService() {
    _checkBluetoothStatus();
  }
  
  /// Verifica el estado actual del Bluetooth
  Future<void> _checkBluetoothStatus() async {
    try {
      bool isEnabled = await serial.FlutterBluetoothSerial.instance.isEnabled ?? false;
      _logger.i('Estado del Bluetooth: ${isEnabled ? 'Activado' : 'Desactivado'}');
      
      if (!isEnabled) {
        _logger.w('El Bluetooth está desactivado. Solicitando activación...');
        await serial.FlutterBluetoothSerial.instance.requestEnable();
      }
    } catch (e) {
      _logger.e('Error al verificar estado del Bluetooth: $e');
    }
  }
  
  /// Inicia el escaneo de dispositivos Bluetooth
  /// Retorna un Stream que emite los dispositivos encontrados a medida que se descubren
  Stream<BluetoothDevice> startScan() {
    if (_isScanning) {
      _logger.w('Ya hay un escaneo en curso.');
      stopScan();
    }
    
    _scanStreamController?.close();
    _scanStreamController = StreamController<BluetoothDevice>.broadcast();
    _discoveredDevices.clear();
    _isScanning = true;
    notifyListeners();
    
    _logger.i('Iniciando escaneo de dispositivos Bluetooth...');
    
    // Comenzar el descubrimiento y manejar los dispositivos encontrados
    serial.FlutterBluetoothSerial.instance.startDiscovery().listen(
      (result) {
        final device = BluetoothDevice(
          name: result.device.name ?? 'Desconocido',
          address: result.device.address,
        );
        
        _logger.i('Dispositivo encontrado: ${device.name} - ${device.address}');
        
        // Solo agregamos dispositivos que no estén ya en la lista
        if (!_discoveredDevices.any((d) => d.address == device.address)) {
          _discoveredDevices.add(device);
          _scanStreamController?.add(device);
          notifyListeners();
        }
      },
      onDone: () {
        _logger.i('Escaneo de dispositivos completado.');
        _isScanning = false;
        notifyListeners();
      },
      onError: (error) {
        _logger.e('Error durante el escaneo: $error');
        _isScanning = false;
        notifyListeners();
      },
    );
    
    return _scanStreamController!.stream;
  }
  
  /// Detiene el escaneo en curso si lo hay
  void stopScan() {
    if (!_isScanning) return;
    
    _logger.i('Deteniendo escaneo de dispositivos...');
    _isScanning = false;
    notifyListeners();
    
    // El escaneo se detiene automáticamente después de un tiempo
    // pero podemos cerrarlo nosotros también
    _scanStreamController?.close();
  }
  
  /// Limpia los dispositivos descubiertos
  void clearDiscoveredDevices() {
    _discoveredDevices.clear();
    notifyListeners();
  }
  
  /// Cierra los recursos cuando ya no se necesitan
  @override
  void dispose() {
    stopScan();
    _scanStreamController?.close();
    super.dispose();
  }
} 