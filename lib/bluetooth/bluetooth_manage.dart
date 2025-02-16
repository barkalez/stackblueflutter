import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart';
import 'package:logger/logger.dart';
import 'bluetooth_device.dart';

class BluetoothManager {
  static final BluetoothClassic _bluetooth = BluetoothClassic();
  static final Logger _logger = Logger();

  static Future<List<BluetoothDevice>> scanForDevices() async {
    List<BluetoothDevice> devices = [];
    try {
      _logger.i('Initializing permissions...');
      await _bluetooth.initPermissions();
      _logger.i('Permissions initialized.');

      _bluetooth.onDeviceDiscovered().listen((Device device) {
        _logger.i('Device discovered: ${device.name} (${device.address})');
        devices.add(BluetoothDevice(
          name: device.name ?? 'Unknown Device',
          address: device.address,
        ));
      });

      _logger.i('Starting scan...');
      await _bluetooth.startScan();
      _logger.i('Scan started.');

      // Esperar un tiempo para escanear dispositivos
      await Future.delayed(const Duration(seconds: 10));

      _logger.i('Stopping scan...');
      await _bluetooth.stopScan();
      _logger.i('Scan stopped.');
    } catch (e) {
      _logger.e('Error scanning for devices: $e');
    }
    return devices;
  }

  static Future<bool> connectToDevice(String address) async {
    try {
      _logger.i('Connecting to device: $address');
      // Proporciona los argumentos correctos al método connect.
      // UUID estándar para Bluetooth serial
      const String uuid = "00001101-0000-1000-8000-00805f9b34fb";

      // Llamar con argumentos correctos (address y uuid)
      await _bluetooth.connect(address, uuid); 
      _logger.i('Connected to device: $address');
      return true;
    } catch (e) {
      _logger.e('Error connecting to device: $e');
      return false;
    }
  }
}