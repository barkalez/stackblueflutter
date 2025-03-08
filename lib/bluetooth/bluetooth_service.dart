// lib/bluetooth/bluetooth_service.dart
import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart' as classic;
import 'package:logger/logger.dart';
import 'bluetooth_device.dart';

/// Servicio para gestionar la comunicación Bluetooth en StackBlue.
///
/// Maneja el escaneo, conexión y envío de comandos al dispositivo ESP32.
class BluetoothService {
  final BluetoothClassic _bluetoothClassic = BluetoothClassic();
  final Logger _logger = Logger();
  static const String _sppUuid = "00001101-0000-1000-8000-00805f9b34fb";

  /// Inicia el escaneo de dispositivos Bluetooth.
  Stream<BluetoothDevice> scanDevices() async* {
    try {
      await _bluetoothClassic.initPermissions();
      await _bluetoothClassic.startScan();
      yield* _bluetoothClassic.onDeviceDiscovered().map((classic.Device device) {
        _logger.i('Dispositivo encontrado: ${device.name} - ${device.address}');
        return BluetoothDevice(
          name: device.name,
          address: device.address,
        );
      });
    } catch (e) {
      _logger.e('Error al escanear dispositivos: $e');
      rethrow;
    } finally {
      await _bluetoothClassic.stopScan();
    }
  }

  /// Conecta a un dispositivo Bluetooth usando su dirección.
  Future<void> connect(String address) async {
    try {
      await _bluetoothClassic.connect(address, _sppUuid);
      _logger.i('Conectado a $address');
    } catch (e) {
      _logger.e('Error al conectar a $address: $e');
      rethrow;
    }
  }

  /// Envía un comando al dispositivo conectado.
  Future<void> sendCommand(String command) async {
    try {
      await _bluetoothClassic.write(command);
      _logger.i('Comando enviado: $command');
    } catch (e) {
      _logger.e('Error al enviar comando: $e');
      rethrow;
    }
  }

  /// Desconecta el dispositivo actual.
  Future<void> disconnect() async {
    try {
      await _bluetoothClassic.disconnect();
      _logger.i('Desconectado');
    } catch (e) {
      _logger.e('Error al desconectar: $e');
      rethrow;
    }
  }

  /// Recibe datos del dispositivo conectado (simulación básica).
  Future<String?> receiveData() async {
    try {
      // Nota: BluetoothClassic no tiene un método directo para leer datos.
      // Esto es un placeholder; necesitamos migrar a flutter_bluetooth_serial para un stream real.
      _logger.w('receiveData no implementado completamente con BluetoothClassic');
      return null; // Temporal hasta migrar
    } catch (e) {
      _logger.e('Error al recibir datos: $e');
      return null;
    }
  }
}