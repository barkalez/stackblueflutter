// lib/screens/control_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../bluetooth/bluetooth_service.dart';
import '../navigation/routes.dart';
import '../widgets/custom_appbar.dart';
import 'control_screen_controller.dart';
import 'dart:async';

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
      // Mensaje eliminado temporalmente para pruebas
    } catch (e) {
      // Mensaje eliminado temporalmente para pruebas
    }
  }

  Future<void> _sendHomingCommand(ControlScreenController controller) async {
    try {
      await controller.sendHomingCommand();
      // Mensaje eliminado temporalmente para pruebas
      
      // Iniciar verificación para mostrar mensaje cuando la posición llegue a 0
      // _checkPositionAfterHoming(); // Comentado temporalmente
      
    } catch (e) {
      // Mensaje eliminado temporalmente para pruebas
    }
  }

  // Método temporalmente comentado para pruebas
  /*
  void _checkPositionAfterHoming() {
    // Referencia al servicio Bluetooth
    final bluetoothService = Provider.of<BluetoothService>(context, listen: false);
    
    // Verificar inmediatamente
    if (bluetoothService.currentPosition == 0 && mounted) {
      MessageUtils.showSuccessMessage(context, 'Homing realizado');
      return;
    }
    
    // Contador para limitar el tiempo total de verificación
    int checkCount = 0;
    const maxChecks = 20; // 10 segundos máximo (20 * 500ms)
    
    // Crear un temporizador periódico
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      checkCount++;
      
      // Detener si el widget ya no está montado
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      // Detener después del número máximo de intentos
      if (checkCount >= maxChecks) {
        timer.cancel();
        return;
      }
      
      // Verificar si la posición ha llegado a 0 (o cerca de 0)
      if (bluetoothService.currentPosition == 0) {
        timer.cancel();
        MessageUtils.showSuccessMessage(context, 'Homing realizado');
      } else if (bluetoothService.currentPosition < 10) {
        // Si está cerca de 0 pero no exactamente en 0, considerarlo como completado
        timer.cancel();
        MessageUtils.showSuccessMessage(context, 'Homing realizado');
      }
    });
  }
  */

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