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
  String? _lastConnectedAddress; // Almacenamos la última dirección conectada

  bool get isConnected => _connection != null && _connection!.isConnected;
  String? get lastConnectedAddress => _lastConnectedAddress;

  BluetoothService() {
    _monitorConnection();
  }

  void _monitorConnection() {
    if (_connection != null) {
      _dataController?.close();
      _dataController = StreamController<String>.broadcast();

      _connection!.input!.listen(
        (data) {
          final received = String.fromCharCodes(data);
          _logger.i('Datos recibidos: $received');
          _dataController?.add(received);
        },
        onDone: () {
          _logger.i('Conexión Bluetooth cerrada');
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
    }
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
      _lastConnectedAddress = address; // Guardamos la dirección
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
    await connect(_lastConnectedAddress!); // Intentamos reconectar
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
        _logger.i('Desconectado');
        _connection = null;
        _dataController?.close();
        notifyListeners();
      }
    } catch (e) {
      _logger.e('Error al desconectar: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _dataController?.close();
    disconnect();
    super.dispose();
  }
}