import 'package:flutter/material.dart';  // Importa el paquete de Flutter para usar componentes visuales.
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';  // Importa el paquete para interactuar con Bluetooth.
import 'package:permission_handler/permission_handler.dart';  // Importa el paquete que gestiona los permisos.
import 'package:logger/logger.dart';  // Importa el paquete logger para gestionar logs (mensajes de depuración).

void main() {
  runApp(MyApp());  // Ejecuta la aplicación Flutter e inicia el widget `MyApp`.
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();  // Crea y asocia el estado del widget con la clase `MyAppState`.
}

class MyAppState extends State<MyApp> {
  List<BluetoothDevice> devices = [];  // Lista que almacenará los dispositivos Bluetooth encontrados.
  final Logger _logger = Logger();  // Crea una instancia del logger para registrar mensajes de depuración.

  @override
  void initState() {
    super.initState();
    // Al iniciar el widget, se solicita primero el permiso para acceder a Bluetooth.
    _requestBluetoothPermissions();  
  }

  // Función para solicitar los permisos necesarios
  Future<void> _requestBluetoothPermissions() async {
    // Solicita permisos para conectar y escanear dispositivos Bluetooth
    PermissionStatus bluetoothPermission = await Permission.bluetoothConnect.request();
    PermissionStatus locationPermission = await Permission.location.request();
    PermissionStatus bluetoothScanPermission = await Permission.bluetoothScan.request();

    // Verifica si todos los permisos han sido concedidos
    if (bluetoothPermission.isGranted && locationPermission.isGranted && bluetoothScanPermission.isGranted) {
      _logger.i("Todos los permisos concedidos");  // Logea el mensaje si los permisos fueron concedidos
      // Inicia el escaneo de dispositivos solo si los permisos fueron concedidos
      _scanDevices();
    } else {
      _logger.w("Permisos necesarios no concedidos");  // Logea una advertencia si los permisos no fueron concedidos
    }
  }

  // Función para escanear dispositivos Bluetooth
  void _scanDevices() async {
    List<BluetoothDevice> discoveredDevices = [];  // Lista donde se guardarán los dispositivos encontrados.
    FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        // Si el dispositivo no está ya en la lista, lo agrega
        if (!discoveredDevices.contains(r.device)) {
          discoveredDevices.add(r.device);  
        }
      });
    });

    // Actualiza el estado de la UI con los dispositivos descubiertos.
    setState(() {
      devices = discoveredDevices;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Bluetooth con ESP32")),  // Crea la barra superior con el título.
        body: ListView.builder(
          itemCount: devices.length,  // El número de elementos será el número de dispositivos encontrados.
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(devices[index].name ?? "Dispositivo desconocido"),  // Muestra el nombre del dispositivo o un mensaje por defecto.
              subtitle: Text(devices[index].address),  // Muestra la dirección del dispositivo.
              onTap: () {
                // Aquí conectaríamos con el dispositivo Bluetooth seleccionado.
              },
            );
          },
        ),
      ),
    );
  }
}
