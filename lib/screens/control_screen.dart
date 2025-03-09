// lib/screens/control_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../bluetooth/bluetooth_service.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_button.dart';
import 'control_screen_controller.dart';

class ControlScreen extends StatelessWidget {
  final BluetoothService bluetoothService;
  final String deviceAddress;

  const ControlScreen({
    super.key,
    required this.bluetoothService,
    required this.deviceAddress,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ControlScreenController(bluetoothService),
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Control Screen'),
        body: const ControlScreenView(),
      ),
    );
  }
}

class ControlScreenView extends StatelessWidget {
  const ControlScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ControlScreenController>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(
              text: 'Homing',
              color: Colors.green,
              onPressed: controller.isSendingCommand ? () {} : () async {
                await controller.sendHomingCommand();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Homing iniciado")),
                  );
                }
              },
              enabled: !controller.isSendingCommand,
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: '1 revolución +',
              color: Colors.blue,
              onPressed: controller.isSendingCommand
                  ? () {}
                  : () => controller.sendOneRevolutionForward(),
              enabled: !controller.isSendingCommand,
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: '1 revolución -',
              color: Colors.red,
              onPressed: controller.isSendingCommand
                  ? () {}
                  : () => controller.sendOneRevolutionBackward(),
              enabled: !controller.isSendingCommand,
            ),
            const SizedBox(height: 20),
            Text(
              'Posición: ${controller.currentPosition.toStringAsFixed(0)} pasos',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Slider(
              value: controller.currentPosition,
              min: 0,
              max: ControlScreenController.maxSteps,
              divisions: 40000,
              label: controller.currentPosition.toStringAsFixed(0),
              onChanged: (value) {
                if (!controller.isSendingCommand) {
                  controller.updatePosition(value); // Cambiado a updatePosition
                }
              },
              onChangeEnd: (value) {
                if (!controller.isSendingCommand) {
                  controller.sendSliderPosition(value);
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