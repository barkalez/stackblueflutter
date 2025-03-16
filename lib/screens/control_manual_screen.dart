// lib/screens/control_manual_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../bluetooth/bluetooth_service.dart';
import '../widgets/custom_appbar.dart';
import 'control_screen_controller.dart';

class ControlManualScreen extends StatelessWidget {
  const ControlManualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bluetoothService = Provider.of<BluetoothService>(context);
    return ChangeNotifierProvider(
      create: (_) => ControlScreenController(bluetoothService),
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Control Manual'),
        body: const ControlManualScreenView(),
      ),
    );
  }
}

class ControlManualScreenView extends StatefulWidget {
  const ControlManualScreenView({super.key});

  @override
  ControlManualScreenViewState createState() => ControlManualScreenViewState();
}

class ControlManualScreenViewState extends State<ControlManualScreenView> {
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

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ControlScreenController>(context);
    final bluetoothService = Provider.of<BluetoothService>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Posición: ${bluetoothService.currentPosition.toStringAsFixed(0)} pasos',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Slider(
              value: bluetoothService.currentPosition, // Usamos posición global
              min: 0,
              max: ControlScreenController.maxSteps,
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
            if (controller.isSendingCommand) ...[
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }
}