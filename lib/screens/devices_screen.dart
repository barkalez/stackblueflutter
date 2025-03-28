// lib/screens/devices_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart' as serial;
import '../bluetooth/bluetooth_device.dart';
import '../bluetooth/bluetooth_service.dart';
import '../navigation/routes.dart';
import '../utils/message_utils.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_button.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key}); // Eliminamos bluetoothService como parámetro

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
        MessageUtils.showErrorMessage(
          context,
          'Se requieren permisos Bluetooth para escanear dispositivos'
        );
      }
    }
  }

  Future<void> _startScan() async {
    final bluetoothService = Provider.of<BluetoothService>(context, listen: false); // Obtenemos del Provider
    setState(() => isScanning = true);
    try {
      late final StreamSubscription<BluetoothDevice> discoverySubscription;
      discoverySubscription = bluetoothService.scanDevices().listen(
        (device) {
          _logger.i('Dispositivo encontrado durante el escaneo: ${device.name} - ${device.address}');
          if (device.name == "StackBlue") {
            if (mounted) {
              setState(() {
                // Verificar que no esté duplicado
                if (!devices.any((d) => d.address == device.address)) {
                  devices.add(device);
                  _logger.i('Dispositivo StackBlue añadido a la lista: ${device.name} - ${device.address}');
                }
              });
              // Detener el escaneo una vez encontrado StackBlue
              discoverySubscription.cancel();
              setState(() => isScanning = false);
            }
          } else {
            _logger.i('Dispositivo ignorado: ${device.name} - ${device.address}');
          }
        },
        onError: (e) {
          _logger.e('Error durante el escaneo: $e');
          if (mounted) {
            MessageUtils.showErrorMessage(
              context,
              'Error al escanear: $e'
            );
            setState(() => isScanning = false);
          }
        },
        onDone: () {
          if (mounted) {
            setState(() => isScanning = false);
          }
        },
      );

      // Por seguridad, detener el escaneo después de 12 segundos si no se ha encontrado StackBlue
      Future.delayed(const Duration(seconds: 12), () {
        discoverySubscription.cancel();
        if (mounted) {
          setState(() => isScanning = false);
        }
      });
    } catch (e) {
      _logger.e('Error al escanear: $e');
      if (mounted) {
        MessageUtils.showErrorMessage(
          context,
          'Error al escanear: $e'
        );
        setState(() => isScanning = false);
      }
    }
  }

  Future<void> _connectToDevice(String address) async {
    final bluetoothService = Provider.of<BluetoothService>(context, listen: false); // Obtenemos del Provider
    try {
      List<serial.BluetoothDevice> bondedDevices = await serial.FlutterBluetoothSerial.instance.getBondedDevices();
      bool isBonded = bondedDevices.any((device) => device.address == address);

      if (!isBonded) {
        _logger.w('El dispositivo $address no está emparejado');
        if (mounted) {
          MessageUtils.showInfoMessage(
            context,
            'Por favor, empareja "StackBlue" en la configuración Bluetooth'
          );
        }
        return;
      }
      
      // Mostrar un indicador de progreso mientras se conecta
      if (mounted) {
        MessageUtils.showProgressDialog(
          context,
          'Conectando al dispositivo...',
          dismissible: false
        );
      }

      await bluetoothService.connect(address);
      
      // Cerrar el diálogo de progreso
      if (mounted) {
        Navigator.of(context).pop(); // Cerrar diálogo
        
        Navigator.pushNamed(
          context,
          Routes.profileCreation,
          arguments: {
            'deviceAddress': address, // Solo pasamos deviceAddress
          },
        );
      }
    } catch (e) {
      _logger.e('Error al conectar: $e');
      if (mounted) {
        // Cerrar el diálogo de progreso si está abierto
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        
        MessageUtils.showErrorMessage(
          context,
          'Error al conectar: $e'
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