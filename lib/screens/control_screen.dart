// lib/screens/control_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../bluetooth/bluetooth_service.dart';
import '../navigation/routes.dart';
import '../widgets/custom_appbar.dart';
import 'control_screen_controller.dart';

class ControlScreen extends StatelessWidget {
  final String deviceAddress;

  const ControlScreen({super.key, required this.deviceAddress});

  @override
  Widget build(BuildContext context) {
    final bluetoothService = Provider.of<BluetoothService>(context);
    return ChangeNotifierProvider(
      create: (_) => ControlScreenController(bluetoothService),
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Control Screen'),
        body: const ControlScreenView(),
      ),
    );
  }
}

class ControlScreenView extends StatefulWidget {
  const ControlScreenView({super.key});

  @override
  ControlScreenViewState createState() => ControlScreenViewState();
}

class ControlScreenViewState extends State<ControlScreenView> {
  Future<void> _sendSliderPosition(ControlScreenController controller, double value) async {
    try {
      await controller.sendSliderPosition(value);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Posición enviada')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _sendHomingCommand(ControlScreenController controller) async {
    try {
      await controller.sendHomingCommand();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Homing iniciado')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ControlScreenController>(context);
    // Escuchamos BluetoothService para actualizaciones de posición
    final bluetoothService = Provider.of<BluetoothService>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Posición: ${bluetoothService.currentPosition.toStringAsFixed(0)} pasos',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          Slider(
            value: bluetoothService.currentPosition, // Usamos posición global
            min: 0,
            max: controller.maxSteps,
            divisions: 40000,
            label: bluetoothService.currentPosition.toStringAsFixed(0),
            onChanged: (value) {
              if (!controller.isSendingCommand) {
                controller.updatePosition(value);
              }
            },
            onChangeEnd: (value) {
              if (!controller.isSendingCommand) {
                _sendSliderPosition(controller, value);
              }
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: controller.isSendingCommand
                ? null
                : () => _sendHomingCommand(controller),
            child: const Text('Homing'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, Routes.stackScreen);
            },
            child: const Text('Ir a Stack Screen'),
          ),
          if (controller.isSendingCommand) const CircularProgressIndicator(),
        ],
      ),
    );
  }
}