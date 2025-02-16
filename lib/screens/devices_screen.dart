import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../bluetooth/bluetooth_manage.dart';
import '../bluetooth/bluetooth_device.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  DevicesScreenState createState() => DevicesScreenState();
}

class DevicesScreenState extends State<DevicesScreen> {
  List<BluetoothDevice> _devices = [];

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (await Permission.bluetooth.request().isGranted &&
        await Permission.location.request().isGranted) {
      _scanForDevices();
    } else {
      // Manejar el caso en que los permisos no son concedidos
    }
  }

  Future<void> _scanForDevices() async {
    List<BluetoothDevice> devices = await BluetoothManager.scanForDevices();
    setState(() {
      _devices = devices;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Devices'),
      ),
      body: _devices.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _devices.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_devices[index].name),
                  subtitle: Text(_devices[index].address),
                );
              },
            ),
    );
  }
}