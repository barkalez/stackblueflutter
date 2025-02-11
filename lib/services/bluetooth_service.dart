import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:stackblueflutter/screens/control_screen.dart';

class BluetoothService {
  final Logger _logger = Logger();

  // Actualización de dispositivos en tiempo real
  Stream<List<BluetoothDevice>> scanDevices() async* {
    List<BluetoothDevice> discoveredDevices = [];
    await for (var r in FlutterBluetoothSerial.instance.startDiscovery()) {
      if (!discoveredDevices.contains(r.device)) {
        discoveredDevices.add(r.device);
        yield discoveredDevices; // Emite la lista cada vez que un dispositivo es descubierto
      }
    }
  }

  Future<void> connectToDevice(BluetoothDevice device, BuildContext context) async {
    try {
      _logger.i("Intentando conectar con ${device.name ?? 'Dispositivo desconocido'}...");
      BluetoothConnection connection = await BluetoothConnection.toAddress(device.address);

      // Verificamos si el widget sigue montado antes de navegar
      if (connection.isConnected && context.mounted) {
        // Navegar a la pantalla de control solo si el widget sigue montado
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ControlScreen(connection: connection),
          ),
        );
      }
    } catch (e) {
      _logger.e("Error al conectar: $e");
    }
  }

  Future<void> requestPermissions() async {
    PermissionStatus bluetoothPermission = await Permission.bluetoothConnect.request();
    PermissionStatus locationPermission = await Permission.location.request();
    PermissionStatus bluetoothScanPermission = await Permission.bluetoothScan.request();

    if (!bluetoothPermission.isGranted || !locationPermission.isGranted || !bluetoothScanPermission.isGranted) {
      _logger.w("Permisos necesarios no concedidos");
    }
  }
}
