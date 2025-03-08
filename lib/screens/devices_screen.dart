// lib/screens/devices_screen.dart
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_button.dart'; // Añadido para el botón de reintento
import '../bluetooth/bluetooth_device.dart';
import '../bluetooth/bluetooth_service.dart';
import '../navigation/routes.dart';

/// Pantalla para descubrir y conectar dispositivos Bluetooth en StackBlue.
///
/// Escanea dispositivos Bluetooth, filtra aquellos con "StackBlue" en el nombre,
/// y permite conectar al ESP32 para controlar la plataforma de macrofotografía.
class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  final BluetoothService _bluetoothService = BluetoothService();
  final List<BluetoothDevice> _discoveredDevices = [];
  bool _isScanning = false;
  final Logger _logger = Logger();
  String _appBarTitle = 'Buscando a StackBlue';

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  /// Inicia el escaneo de dispositivos Bluetooth usando el servicio.
  Future<void> _startScan() async {
    if (_isScanning) return; // Evitar múltiples escaneos simultáneos
    setState(() {
      _isScanning = true;
      _discoveredDevices.clear(); // Limpiar lista al reintentar
      _appBarTitle = 'Buscando a StackBlue';
    });

    try {
      final stream = _bluetoothService.scanDevices();
      final subscription = stream.listen((device) {
        if (device.name?.contains("StackBlue") ?? false) {
          if (!_discoveredDevices.contains(device)) {
            setState(() {
              _discoveredDevices.add(device);
              _appBarTitle = 'StackBlue encontrado';
            });
          }
        }
      });

      // Esperar 10 segundos y luego cancelar el escaneo
      await Future.delayed(const Duration(seconds: 10));
      subscription.cancel();
    } catch (e) {
      _logger.e('Error al iniciar escaneo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al escanear: $e')),
        );
      }
    } finally {
      setState(() => _isScanning = false);
    }
  }

  /// Conecta a un dispositivo Bluetooth y navega a la pantalla de control.
  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      setState(() => _isScanning = true); // Mostrar indicador mientras conecta
      await _bluetoothService.connect(device.address);
      _logger.i('Conectado a ${device.name}');
      if (mounted) {
        Navigator.pushNamed(
          context,
          AppRoutes.control,
          arguments: {
            'bluetoothService': _bluetoothService,
            'deviceAddress': device.address,
          },
        );
      }
    } catch (e) {
      _logger.e('Error al conectar con ${device.name}: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al conectar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  @override
  void dispose() {
    _bluetoothService.disconnect(); // Asegurar desconexión al salir
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: _appBarTitle),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _isScanning
                    ? const CircularProgressIndicator()
                    : _discoveredDevices.isEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'No se encontraron dispositivos',
                                style: TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 20),
                              CustomButton(
                                text: 'Reintentar escaneo',
                                color: Colors.blue,
                                onPressed: _startScan,
                              ),
                            ],
                          )
                        : _buildDeviceList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye la lista de dispositivos descubiertos.
  Widget _buildDeviceList() {
    return ListView.builder(
      itemCount: _discoveredDevices.length,
      itemBuilder: (context, index) {
        final device = _discoveredDevices[index];
        return GestureDetector(
          onTap: () => _connectToDevice(device),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    device.name ?? 'Dispositivo desconocido',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    device.address,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}