// lib/screens/devices_screen.dart
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart' as serial; // Añadimos esto
import '../bluetooth/bluetooth_device.dart';
import '../bluetooth/bluetooth_service.dart';
import '../navigation/routes.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_button.dart';

class DevicesScreen extends StatefulWidget {
  final BluetoothService bluetoothService;

  const DevicesScreen({super.key, required this.bluetoothService});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  final Logger _logger = Logger();
  List<BluetoothDevice> devices = [];
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndScan();
  }

  Future<void> _requestPermissionsAndScan() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    if (statuses[Permission.bluetoothScan]!.isGranted &&
        statuses[Permission.bluetoothConnect]!.isGranted &&
        (statuses[Permission.location]!.isGranted || await Permission.location.isPermanentlyDenied)) {
      _startScan();
    } else {
      _logger.e('Permisos Bluetooth denegados');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Se requieren permisos Bluetooth para escanear dispositivos')),
        );
      }
    }
  }

  Future<void> _startScan() async {
    setState(() => isScanning = true);
    try {
      await for (var device in widget.bluetoothService.scanDevices()) {
        if (device.name == "StackBlue") {
          if (mounted) {
            setState(() {
              devices.add(device);
              _logger.i('Dispositivo StackBlue encontrado: ${device.name} - ${device.address}');
            });
          }
        } else {
          _logger.i('Dispositivo ignorado: ${device.name} - ${device.address}');
        }
      }
    } catch (e) {
      _logger.e('Error al escanear: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al escanear: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isScanning = false);
      }
    }
  }

  Future<void> _connectToDevice(String address) async {
    try {
      // Verificamos si el dispositivo está emparejado
      List<serial.BluetoothDevice> bondedDevices = await serial.FlutterBluetoothSerial.instance.getBondedDevices();
      bool isBonded = bondedDevices.any((device) => device.address == address);
      
      if (!isBonded) {
        _logger.w('El dispositivo $address no está emparejado');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, empareja "StackBlue" en la configuración Bluetooth')),
          );
        }
        return;
      }

      await widget.bluetoothService.connect(address);
      if (mounted) {
        Navigator.pushNamed(
          context,
          Routes.control,
          arguments: {
            'bluetoothService': widget.bluetoothService,
            'deviceAddress': address,
          },
        );
      }
    } catch (e) {
      _logger.e('Error al conectar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al conectar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Devices Screen'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (isScanning) ...[
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 20),
              const Text('Escaneando dispositivos...'),
            ],
            Expanded(
              child: ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  return ListTile(
                    title: Text(device.name ?? 'Dispositivo desconocido'),
                    subtitle: Text(device.address),
                    trailing: CustomButton(
                      text: 'Conectar',
                      color: Colors.blue,
                      onPressed: () => _connectToDevice(device.address),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}