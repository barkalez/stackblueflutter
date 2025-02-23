import 'package:flutter/material.dart';
import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart'; // Para Device del paquete
import 'package:logger/logger.dart';
import '../widgets/custom_appbar.dart'; // Import desde widgets/
import '../bluetooth/bluetooth_device.dart'; // Import desde bluetooth/
import 'control_screen.dart'; // Import de la pantalla de control

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  DevicesScreenState createState() => DevicesScreenState();
}

class DevicesScreenState extends State<DevicesScreen> {
  final BluetoothClassic _bluetoothClassicPlugin = BluetoothClassic();
  final List<BluetoothDevice> _discoveredDevices = [];
  bool _isScanning = false;
  final Logger _logger = Logger();
  String _appBarTitle = 'Buscando a StackBlue';

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    await _bluetoothClassicPlugin.initPermissions();

    _bluetoothClassicPlugin.onDeviceDiscovered().listen((Device event) {
      _logger.i('Dispositivo encontrado: ${event.name} - ${event.address}');

      if (event.name != null && event.name!.contains("StackBlue")) {
        setState(() {
          final bluetoothDevice = BluetoothDevice(
            name: event.name,
            address: event.address,
          );
          if (!_discoveredDevices.contains(bluetoothDevice)) {
            _discoveredDevices.add(bluetoothDevice);
          }
        });
      }
    });

    setState(() {
      _isScanning = true;
    });

    await _bluetoothClassicPlugin.startScan();

    Future.delayed(const Duration(seconds: 10), () {
      _stopScan();
    });
  }

  Future<void> _stopScan() async {
    await _bluetoothClassicPlugin.stopScan();
    setState(() {
      _isScanning = false;
    });
  }

Future<void> _connectToDevice(BluetoothDevice device) async {
  try {
    await _bluetoothClassicPlugin.connect(
      device.address,
      "00001101-0000-1000-8000-00805f9b34fb",
    );
    _logger.i('Conectado a ${device.name}');
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ControlScreen(
            bluetoothPlugin: _bluetoothClassicPlugin, // Pasamos la instancia conectada
            deviceAddress: device.address, // Pasamos la dirección del dispositivo
          ),
        ),
      );
    }
  } catch (e) {
    _logger.e('Error al conectar con ${device.name}: $e');
  }
}

  @override
  void dispose() {
    _stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: _appBarTitle),
      body: Column(
        children: [
          const SizedBox(height: 50), // Espacio de 50 píxeles
          Expanded(
            child: Center(
              child: _isScanning
                  ? const CircularProgressIndicator()
                  : _discoveredDevices.isEmpty
                      ? const Text('No devices found')
                      : ListView.builder(
                          itemCount: _discoveredDevices.length,
                          itemBuilder: (context, index) {
                            final device = _discoveredDevices[index];
                            if (device.name == "StackBlue") {
                              // Cambiar el título del AppBar cuando se presenta el dispositivo en la lista
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                setState(() {
                                  _appBarTitle = 'StackBlue encontrado';
                                });
                              });
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () => _connectToDevice(device),
                                      child: Card(
                                        color: Colors.white,
                                        shadowColor: Colors.blue,
                                        elevation: 5,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                device.name ?? 'Unknown Device',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  fontSize: 18,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                device.address,
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 16,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return ListTile(
                                title: Text(device.name ?? 'Unknown Device'),
                                subtitle: Text(device.address),
                              );
                            }
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}