import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  List<BluetoothDevice> devices = [];
  final Logger _logger = Logger();
  BluetoothConnection? connection;

  // 🔥 GlobalKey para el ScaffoldMessenger
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _requestBluetoothPermissions();
  }

  Future<void> _requestBluetoothPermissions() async {
    PermissionStatus bluetoothPermission = await Permission.bluetoothConnect.request();
    PermissionStatus locationPermission = await Permission.location.request();
    PermissionStatus bluetoothScanPermission = await Permission.bluetoothScan.request();

    if (bluetoothPermission.isGranted && locationPermission.isGranted && bluetoothScanPermission.isGranted) {
      _logger.i("Todos los permisos concedidos");
      _scanDevices();
    } else {
      _logger.w("Permisos necesarios no concedidos");
    }
  }

  void _scanDevices() async {
    List<BluetoothDevice> discoveredDevices = [];
    FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        if (!discoveredDevices.contains(r.device)) {
          discoveredDevices.add(r.device);
        }
      });
    });

    setState(() {
      devices = discoveredDevices;
    });
  }

  void _connectToDevice(BluetoothDevice device) async {
    try {
      _logger.i("Intentando conectar con ${device.name ?? 'Dispositivo desconocido'}...");
      connection = await BluetoothConnection.toAddress(device.address);

      if (connection != null && connection!.isConnected) {
        _logger.i("Conectado a ${device.name ?? 'Dispositivo desconocido'}");

        if (!mounted) return;

        // 🔥 Usamos scaffoldMessengerKey en lugar de ScaffoldMessenger.of(context)
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text("Conectado a ${device.name ?? 'Dispositivo desconocido'}"),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      _logger.e("Error al conectar con ${device.name ?? 'Dispositivo desconocido'}: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey, // 🔥 Asociamos el GlobalKey aquí
      home: Scaffold(
        appBar: AppBar(title: Text("Bluetooth con ESP32")),
        body: ListView.builder(
          itemCount: devices.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(devices[index].name ?? "Dispositivo desconocido"),
              subtitle: Text(devices[index].address),
              onTap: () {
                _connectToDevice(devices[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
