// lib/bluetooth/bluetooth_service.dart
import 'dart:typed_data';
import 'package:flutter/material.dart'; // Añadido para ChangeNotifier
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart' as serial;
import 'package:logger/logger.dart';
import 'bluetooth_device.dart';

class BluetoothService extends ChangeNotifier { // Extendemos ChangeNotifier
  serial.BluetoothConnection? _connection;
  final Logger _logger = Logger();

  bool get isConnected => _connection != null && _connection!.isConnected; // Getter para el estado

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
      _logger.i('Conectado a $address');
      notifyListeners(); // Notificamos cuando se conecta
    } catch (e) {
      _logger.e('Error al conectar a $address: $e');
      rethrow;
    }
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
    if (_connection == null || !_connection!.isConnected) {
      throw Exception('No conectado');
    }
    return _connection!.input!.map((data) {
      final received = String.fromCharCodes(data);
      _logger.i('Datos recibidos: $received');
      return received;
    }).asBroadcastStream();
  }

  Future<void> disconnect() async {
    try {
      if (_connection != null && _connection!.isConnected) {
        await _connection!.close();
        _logger.i('Desconectado');
        notifyListeners(); // Notificamos cuando se desconecta
      }
    } catch (e) {
      _logger.e('Error al desconectar: $e');
      rethrow;
    }
  }
}