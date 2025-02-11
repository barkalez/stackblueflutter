import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../services/bluetooth_service.dart';
import '../widgets/device_list_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  BluetoothService bluetoothService = BluetoothService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bluetooth con ESP32")),
      body: StreamBuilder<List<BluetoothDevice>>(
        stream: bluetoothService.scanDevices(), // Usamos el stream que emite los dispositivos conforme se descubren
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Indicador mientras escanea
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return Center(child: Text('No se encontraron dispositivos'));
          }

          List<BluetoothDevice> devices = snapshot.data ?? [];

          return ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              return DeviceListTile(
                device: devices[index],
                onTap: () {
                  bluetoothService.connectToDevice(devices[index], context);
                },
              );
            },
          );
        },
      ),
    );
  }
}

