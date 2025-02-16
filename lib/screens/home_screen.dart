import 'package:flutter/material.dart';
import '../bluetooth/bluetooth_manage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  String _receivedData = '';

  void _sendData() async {
    String data = _controller.text;
    if (data.isNotEmpty) {
      bool success = await BluetoothManager.sendDataToDevice(data);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Datos enviados: $data')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al enviar datos')),
          );
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _startListeningToData();
  }

  void _startListeningToData() {
    BluetoothManager.onDataReceived().listen((data) {
      if (mounted) {
        setState(() {
          _receivedData = data;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Ingrese datos',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendData,
              child: const Text('Enviar'),
            ),
            const SizedBox(height: 20),
            Text('Datos recibidos: $_receivedData'),
          ],
        ),
      ),
    );
  }
}