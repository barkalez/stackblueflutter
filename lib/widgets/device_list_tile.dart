import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class DeviceListTile extends StatelessWidget {
  final BluetoothDevice device;
  final VoidCallback onTap;

  const DeviceListTile({super.key, required this.device, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(device.name ?? "Dispositivo desconocido"),
      subtitle: Text(device.address),
      onTap: onTap,
    );
  }
}
