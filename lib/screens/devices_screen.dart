// Importa el paquete de Flutter para construir la interfaz de usuario.
import 'package:flutter/material.dart';
// Importa el paquete permission_handler para manejar permisos.
import 'package:permission_handler/permission_handler.dart';
// Importa el archivo bluetooth_manage.dart para manejar el Bluetooth.
import '../bluetooth/bluetooth_manage.dart';
// Importa el archivo bluetooth_device.dart que define la clase BluetoothDevice.
import '../bluetooth/bluetooth_device.dart';
// Importa el archivo home_screen.dart para navegar a la pantalla principal.
import 'home_screen.dart';

// Define la clase DevicesScreen que extiende StatefulWidget.
class DevicesScreen extends StatefulWidget {
  // Constructor de la clase DevicesScreen.
  const DevicesScreen({super.key});

  // Crea el estado asociado a este widget.
  @override
  DevicesScreenState createState() => DevicesScreenState();
}

// Define la clase DevicesScreenState que maneja el estado de DevicesScreen.
class DevicesScreenState extends State<DevicesScreen> {
  // Lista para almacenar los dispositivos Bluetooth encontrados.
  List<BluetoothDevice> _devices = [];

  // Método initState que se llama cuando se inicializa el estado.
  @override
  void initState() {
    super.initState();
    // Solicita permisos necesarios.
    _requestPermissions();
  }

  // Método para solicitar permisos necesarios.
  Future<void> _requestPermissions() async {
    // Solicita permisos de Bluetooth y ubicación.
    if (await Permission.bluetooth.request().isGranted &&
        await Permission.location.request().isGranted) {
      // Si los permisos son concedidos, inicia el escaneo de dispositivos.
      _scanForDevices();
    } else {
      // Manejar el caso en que los permisos no son concedidos.
    }
  }

  // Método para escanear dispositivos Bluetooth.
  Future<void> _scanForDevices() async {
    // Llama al método scanForDevices de BluetoothManager y almacena los dispositivos encontrados.
    List<BluetoothDevice> devices = await BluetoothManager.scanForDevices();
    // Actualiza el estado con la lista de dispositivos encontrados.
    if (mounted) {
      setState(() {
        _devices = devices;
      });
    }
  }

  // Método para conectar a un dispositivo Bluetooth.
  Future<void> _connectToDevice(BluetoothDevice device) async {
       bool success = await BluetoothManager.connectToDevice(device.address);

  // Si la conexión es exitosa, muestra un mensaje y navega a la pantalla principal.
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Conectado a ${device.name}')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // Si la conexión falla, muestra un mensaje de error.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al conectar a ${device.name}')),
        );
      }
    }
  }

  // Método build que construye la interfaz de usuario.
  @override
  Widget build(BuildContext context) {
    // Retorna un widget Scaffold que proporciona la estructura básica de la pantalla.
    return Scaffold(
      // Barra de la aplicación con el título.
      appBar: AppBar(
        title: const Text('Bluetooth Devices'),
      ),
      // Cuerpo de la pantalla que muestra un indicador de progreso o la lista de dispositivos.
      body: _devices.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              // Número de elementos en la lista.
              itemCount: _devices.length,
              // Construye cada elemento de la lista.
              itemBuilder: (context, index) {
                return ListTile(
                  // Muestra el nombre del dispositivo.
                  title: Text(_devices[index].name),
                  // Muestra la dirección del dispositivo.
                  subtitle: Text(_devices[index].address),
                  // Conecta al dispositivo cuando se toca el elemento de la lista.
                  onTap: () => _connectToDevice(_devices[index]),
                );
              },
            ),
    );
  }
}