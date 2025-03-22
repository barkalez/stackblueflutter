import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile.dart';
import 'bluetooth_connection_service.dart';
import 'bluetooth_device.dart';
import 'bluetooth_scanner_service.dart';
import 'stepper_position_service.dart';

/// Gestor centralizado que coordina todos los servicios relacionados con Bluetooth.
/// Actúa como fachada para simplificar el acceso a las funcionalidades de Bluetooth
/// desde las diferentes pantallas de la aplicación.
class BluetoothManager extends ChangeNotifier {
  // Servicios
  final BluetoothConnectionService _connectionService;
  final BluetoothScannerService _scannerService;
  final StepperPositionService _positionService;
  final Logger _logger = Logger();
  
  // Estado
  Profile? _selectedProfile;
  String? _lastConnectedAddress;
  Timer? _statusMonitorTimer;
  
  // Constructor
  BluetoothManager() : 
    _connectionService = BluetoothConnectionService(),
    _scannerService = BluetoothScannerService(),
    _positionService = StepperPositionService(BluetoothConnectionService()) {
    _init();
  }
  
  // Inicialización asíncrona
  Future<void> _init() async {
    // Cargar el último dispositivo conectado
    _lastConnectedAddress = _connectionService.lastConnectedAddress;
    
    // Cargar el perfil guardado
    await _loadSelectedProfile();
    
    // Monitorear el estado de la conexión
    _startStatusMonitor();
  }
  
  // Monitoreo periódico del estado
  void _startStatusMonitor() {
    _statusMonitorTimer?.cancel();
    _statusMonitorTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (isConnected) {
        _logger.d('Conexión Bluetooth activa. Dispositivo: $_lastConnectedAddress');
      }
    });
  }
  
  // Getters
  bool get isConnected => _connectionService.isConnected;
  bool get isScanning => _scannerService.isScanning;
  List<BluetoothDevice> get discoveredDevices => _scannerService.discoveredDevices;
  Profile? get selectedProfile => _selectedProfile;
  double get currentPosition => _positionService.currentPosition;
  double get stackStartPosition => _positionService.stackStartPosition;
  double get stackEndPosition => _positionService.stackEndPosition;
  bool get isMoving => _positionService.isMoving;
  
  // Métodos para gestionar el escaneo
  Stream<BluetoothDevice> startDeviceScan() {
    return _scannerService.startScan();
  }
  
  void stopDeviceScan() {
    _scannerService.stopScan();
  }
  
  // Métodos para gestionar la conexión
  Future<void> connectToDevice(String address) async {
    try {
      await _connectionService.connect(address);
      _lastConnectedAddress = address;
      notifyListeners();
    } catch (e) {
      _logger.e('Error al conectar con el dispositivo $address: $e');
      rethrow;
    }
  }
  
  Future<void> reconnect() async {
    if (_lastConnectedAddress == null) {
      throw Exception('No hay dispositivo previo para reconectar');
    }
    
    try {
      await _connectionService.connect(_lastConnectedAddress!);
      notifyListeners();
    } catch (e) {
      _logger.e('Error al reconectar con el dispositivo $_lastConnectedAddress: $e');
      rethrow;
    }
  }
  
  Future<void> disconnect() async {
    try {
      await _connectionService.disconnect();
      notifyListeners();
    } catch (e) {
      _logger.e('Error al desconectar: $e');
      rethrow;
    }
  }
  
  // Métodos para gestionar la posición
  void updatePosition(double position) {
    _positionService.updatePosition(position);
  }
  
  void setStackStartPosition(double position) {
    _positionService.setStackStartPosition(position);
    notifyListeners();
  }
  
  void setStackEndPosition(double position) {
    _positionService.setStackEndPosition(position);
    notifyListeners();
  }
  
  Future<void> moveToPosition(double position, {int speed = 3200, int acceleration = 2000}) async {
    await _positionService.moveToPosition(position, speed: speed, acceleration: acceleration);
  }
  
  Future<void> moveSteps(int steps, {int speed = 3200, int acceleration = 2000}) async {
    await _positionService.moveSteps(steps, speed: speed, acceleration: acceleration);
  }
  
  Future<void> sendContinuousMovement(bool forward, {int speed = 3200, int acceleration = 2000}) async {
    await _positionService.startContinuousMovement(forward, speed: speed, acceleration: acceleration);
  }
  
  Future<void> stopMovement() async {
    await _positionService.stopMovement();
  }
  
  Future<void> testMotor({int speed = 1600, int acceleration = 1000, int steps = 800}) async {
    await _positionService.testMotor(speed: speed, acceleration: acceleration, steps: steps);
  }
  
  Future<void> executeStacking({
    required int numPhotos,
    required int speedForward,
    required int speedBackward,
    required int acceleration,
    required int delayBetweenPhotos,
  }) async {
    await _positionService.executeStacking(
      numPhotos: numPhotos,
      speedForward: speedForward,
      speedBackward: speedBackward,
      acceleration: acceleration,
      delayBetweenPhotos: delayBetweenPhotos,
    );
  }
  
  // Métodos para gestionar comandos directos
  Future<void> sendCommand(String command) async {
    try {
      await _connectionService.sendCommand(command);
    } catch (e) {
      _logger.e('Error al enviar comando: $e');
      rethrow;
    }
  }
  
  // Métodos para gestionar perfiles
  Future<void> _loadSelectedProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString('selectedProfile');
      
      if (profileJson != null) {
        _selectedProfile = Profile.fromJson(
          Map<String, dynamic>.from(
            jsonDecode(profileJson)
          )
        );
        if (_positionService.selectedProfile?.name != _selectedProfile?.name) {
          _positionService.setSelectedProfile(_selectedProfile!);
        }
        _logger.i('Perfil cargado: ${_selectedProfile!.name}');
      }
    } catch (e) {
      _logger.e('Error al cargar el perfil: $e');
    }
  }
  
  Future<void> setSelectedProfile(Profile profile) async {
    try {
      _selectedProfile = profile;
      _positionService.setSelectedProfile(profile);
      
      // Guardar el perfil seleccionado
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedProfile', jsonEncode(profile.toJson()));
      
      _logger.i('Perfil seleccionado: ${profile.name}');
      notifyListeners();
    } catch (e) {
      _logger.e('Error al establecer el perfil: $e');
      rethrow;
    }
  }
  
  @override
  void dispose() {
    _statusMonitorTimer?.cancel();
    _connectionService.dispose();
    _scannerService.dispose();
    _positionService.dispose();
    super.dispose();
  }
} 