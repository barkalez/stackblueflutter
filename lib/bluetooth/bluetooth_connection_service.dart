import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart' as serial;
import 'package:logger/logger.dart';
import 'bluetooth_device.dart';
import 'bluetooth_interface.dart';

/// Servicio de conexión Bluetooth que implementa la interfaz BluetoothInterface.
/// Este servicio utiliza flutter_bluetooth_serial para comunicarse con dispositivos Bluetooth.
class BluetoothConnectionService implements BluetoothInterface {
  serial.BluetoothConnection? _connection;
  final Logger _logger = Logger();
  StreamController<String>? _dataController;
  String? _lastConnectedAddress;
  
  final _positionUpdateController = StreamController<double>.broadcast();
  Stream<double> get positionUpdates => _positionUpdateController.stream;
  
  @override
  bool get isConnected => _connection != null && _connection!.isConnected;
  
  @override
  String? get lastConnectedAddress => _lastConnectedAddress;

  BluetoothConnectionService() {
    _setupController();
  }
  
  void _setupController() {
    _dataController = StreamController<String>.broadcast();
  }
  
  void _setupDataStream() {
    if (_connection != null && _connection!.isConnected) {
      _logger.i('Configurando stream de datos Bluetooth');
      
      _connection!.input!.listen(
        (data) {
          final received = String.fromCharCodes(data);
          _logger.i('Datos recibidos: $received');
          _dataController?.add(received);
          _processPositionData(received);
        },
        onDone: () {
          _logger.i('Stream de entrada cerrado (onDone) - Conexión Bluetooth terminada');
          _connection = null;
          notifyListeners();
        },
        onError: (e) {
          _logger.e('Error en la conexión Bluetooth: $e');
          _connection = null;
          notifyListeners();
        },
      );
    } else {
      _logger.w('No hay conexión activa para configurar stream');
    }
  }
  
  void _processPositionData(String data) {
    if (data.contains("POS:")) {
      final lines = data.split('\n');
      for (var line in lines) {
        line = line.trim();
        if (line.startsWith("POS:")) {
          final positionStr = line.replaceFirst("POS:", "").trim();
          final position = double.tryParse(positionStr);
          if (position != null) {
            final clampedPosition = position.clamp(0.0, 40000.0);
            _logger.i('Posición actualizada desde Bluetooth: $clampedPosition');
            _positionUpdateController.add(clampedPosition);
          }
        }
      }
    }
  }
  
  void notifyListeners() {
    // Este método se usa para notificar a los listeners de cambios en el estado
    // En una versión futura, se podría implementar un patrón de Observable
  }
  
  @override
  Stream<BluetoothDevice> scanDevices() async* {
    try {
      final discoveryStream = serial.FlutterBluetoothSerial.instance.startDiscovery();
      await for (var result in discoveryStream) {
        _logger.i('Dispositivo encontrado: ${result.device.name} - ${result.device.address}');
        yield BluetoothDevice(
          name: result.device.name,
          address: result.device.address,
        );
      }
    } catch (e) {
      _logger.e('Error al escanear dispositivos: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> connect(String address) async {
    try {
      _connection = await serial.BluetoothConnection.toAddress(address);
      _lastConnectedAddress = address;
      _logger.i('Conectado a $address');
      _setupDataStream();
      notifyListeners();
    } catch (e) {
      _logger.e('Error al conectar a $address: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> reconnect() async {
    if (isConnected) {
      _logger.i('Ya está conectado, no se necesita reconexión');
      return;
    }
    if (_lastConnectedAddress == null) {
      _logger.w('No hay dirección previa para reconectar');
      throw Exception('No hay dispositivo previo para reconectar');
    }
    await connect(_lastConnectedAddress!);
  }
  
  @override
  Future<void> sendCommand(String command) async {
    if (_connection == null || !_connection!.isConnected) {
      throw Exception('No conectado');
    }
    try {
      _connection!.output.add(Uint8List.fromList(command.codeUnits));
      await _connection!.output.allSent;
      _logger.i('Comando enviado: $command');
    } catch (e) {
      _logger.e('Error al enviar comando: $e');
      rethrow;
    }
  }
  
  @override
  Stream<String> receiveData() {
    if (_connection == null || !_connection!.isConnected || _dataController == null) {
      throw Exception('No conectado');
    }
    return _dataController!.stream;
  }
  
  @override
  Future<void> disconnect() async {
    try {
      if (_connection != null && _connection!.isConnected) {
        await _connection!.close();
        _logger.i('Desconectado manualmente');
        _connection = null;
        notifyListeners();
      }
    } catch (e) {
      _logger.e('Error al desconectar: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> dispose() async {
    await disconnect();
    _dataController?.close();
    _positionUpdateController.close();
  }
} 