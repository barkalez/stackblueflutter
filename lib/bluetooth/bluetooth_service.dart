// lib/bluetooth/bluetooth_service.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart' as serial;
import 'package:logger/logger.dart';
import 'bluetooth_device.dart';

class BluetoothService extends ChangeNotifier {
  serial.BluetoothConnection? _connection;
  final Logger _logger = Logger();
  StreamController<String>? _dataController;
  String? _lastConnectedAddress;
  double _currentPosition = 0.0;

  bool get isConnected => _connection != null && _connection!.isConnected;
  String? get lastConnectedAddress => _lastConnectedAddress;
  double get currentPosition => _currentPosition;

  BluetoothService() {
    _monitorConnection();
  }

  void _monitorConnection() {
    if (_connection != null && _connection!.isConnected) {
      _logger.i('Monitoreando conexión Bluetooth');
      _dataController?.close();
      _dataController = StreamController<String>.broadcast();

      _connection!.input!.listen(
        (data) {
          final received = String.fromCharCodes(data);
          _logger.i('Datos recibidos: $received');
          _dataController?.add(received);
          _updatePositionFromData(received);
        },
        onDone: () {
          _logger.i('Stream de entrada cerrado (onDone) - Conexión Bluetooth terminada');
          _connection = null;
          _dataController?.close();
          notifyListeners();
        },
        onError: (e) {
          _logger.e('Error en la conexión Bluetooth: $e');
          _connection = null;
          _dataController?.close();
          notifyListeners();
        },
      );
    } else {
      _logger.w('No hay conexión activa para monitorear');
    }
  }

  void _updatePositionFromData(String data) {
    if (data.contains("POS:")) {
      final lines = data.split('\n');
      for (var line in lines) {
        line = line.trim();
        if (line.startsWith("POS:")) {
          final positionStr = line.replaceFirst("POS:", "").trim();
          final position = double.tryParse(positionStr);
          if (position != null) {
            _currentPosition = position.clamp(0, 40000.0);
            _logger.i('Posición actualizada desde Bluetooth: $_currentPosition');
            notifyListeners();
          }
        }
      }
    }
  }

  void updatePosition(double position) { // Nuevo método público
    _currentPosition = position.clamp(0, 40000.0);
    _logger.i('Posición actualizada manualmente: $_currentPosition');
    notifyListeners();
  }

  Stream<BluetoothDevice> scanDevices() async* {
    try {
      List<serial.BluetoothDiscoveryResult> results =
          await serial.FlutterBluetoothSerial.instance.startDiscovery().toList();
      for (var result in results) {
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

  Future<void> connect(String address) async {
    try {
      _connection = await serial.BluetoothConnection.toAddress(address);
      _lastConnectedAddress = address;
      _logger.i('Conectado a $address');
      _monitorConnection();
      notifyListeners();
    } catch (e) {
      _logger.e('Error al conectar a $address: $e');
      rethrow;
    }
  }

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

  Stream<String> receiveData() {
    if (_connection == null || !_connection!.isConnected || _dataController == null) {
      throw Exception('No conectado');
    }
    return _dataController!.stream;
  }

  Future<void> disconnect() async {
    try {
      if (_connection != null && _connection!.isConnected) {
        await _connection!.close();
        _logger.i('Desconectado manualmente');
        _connection = null;
        _dataController?.close();
        notifyListeners();
      }
    } catch (e) {
      _logger.e('Error al desconectar: $e');
      rethrow;
    }
  }
}