import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';
import 'dart:typed_data';

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

  // 🔥 GlobalKey para el Navigator
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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

        // Verificar si el widget sigue montado antes de usar el contexto
        if (!mounted) return;

        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text("Conectado a ${device.name ?? 'Dispositivo desconocido'}"),
            duration: Duration(seconds: 3),
          ),
        );

        // Esperar un frame antes de navegar
        await Future.delayed(Duration(milliseconds: 500));

        // Verificar nuevamente si el widget sigue montado antes de navegar
        if (!mounted) return;

        // Usar el GlobalKey para navegar
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => ControlScreen(connection: connection!),
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
      navigatorKey: navigatorKey, // 🔥 Asociamos el GlobalKey del Navigator
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

// 🔥 Nueva pantalla con TextField y botón Enviar
class ControlScreen extends StatefulWidget {
  final BluetoothConnection connection;

  const ControlScreen({super.key, required this.connection});

  @override
  ControlScreenState createState() => ControlScreenState();
}

class ControlScreenState extends State<ControlScreen> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _sendData() async {
  if (widget.connection.isConnected) {
    String message = _controller.text.trim();
    if (message.isNotEmpty) {
      // Agregar un salto de línea al final del mensaje (si es necesario)
      message += '\n';

      // Convertir el mensaje a Uint8List
      Uint8List data = Uint8List.fromList(message.codeUnits);

      // Enviar los datos
      widget.connection.output.add(data);

      // Esperar a que los datos se envíen completamente
      await widget.connection.output.allSent;

      // Limpiar el campo de texto después de enviar
      _controller.clear();

      // Verificar si el widget sigue montado antes de mostrar el SnackBar
      if (!mounted) return;

      // Mostrar un mensaje de éxito (opcional)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Mensaje enviado: $message"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  } else {
    // Mostrar un mensaje de error si la conexión no está activa
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error: No estás conectado al dispositivo"),
        duration: Duration(seconds: 2),
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Control del Motor")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: "Escribe un mensaje"),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sendData,
              child: Text("Enviar"),
            ),
          ],
        ),
      ),
    );
  }
}