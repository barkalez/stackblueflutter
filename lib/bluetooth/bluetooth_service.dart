// lib/bluetooth/bluetooth_service.dart
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart' as serial;
import 'package:logger/logger.dart';
import 'bluetooth_device.dart';

class BluetoothService {
  serial.BluetoothConnection? _connection;
  final Logger _logger = Logger();

  /// Inicia el escaneo de dispositivos Bluetooth.
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

  /// Conecta a un dispositivo Bluetooth usando su dirección.
  Future<void> connect(String address) async {
    try {
      _connection = await serial.BluetoothConnection.toAddress(address);
      _logger.i('Conectado a $address');
    } catch (e) {
      _logger.e('Error al conectar a $address: $e');
      rethrow;
    }
  }

  /// Envía un comando al dispositivo conectado.
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

  /// Recibe datos del dispositivo conectado como un Stream.
  Stream<String> receiveData() {
    if (_connection == null || !_connection!.isConnected) {
      throw Exception('No conectado');
    }
    return _connection!.input!.map((data) {
      final received = String.fromCharCodes(data);
      _logger.i('Datos recibidos: $received'); // Depuración
      return received;
    }).asBroadcastStream();
  }

  /// Desconecta el dispositivo actual.
  Future<void> disconnect() async {
    try {
      if (_connection != null && _connection!.isConnected) {
        await _connection!.close();
        _logger.i('Desconectado');
      }
    } catch (e) {
      _logger.e('Error al desconectar: $e');
      rethrow;
    }
  }
}