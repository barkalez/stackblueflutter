// lib/screens/devices_screen.dart
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
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
    _startScan();
  }

  Future<void> _startScan() async {
    setState(() => isScanning = true);
    try {
      await for (var device in widget.bluetoothService.scanDevices()) {
        if (device.name == "StackBlue") { // Filtramos por "StackBlue"
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