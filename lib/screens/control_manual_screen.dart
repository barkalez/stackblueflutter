// lib/screens/control_manual_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../bluetooth/bluetooth_service.dart';
import '../widgets/custom_appbar.dart';
import 'control_screen_controller.dart';
import '../widgets/custom_button.dart'; // Añadir esta importación

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
    
    // Calcular la altura para los botones grandes (triple de alto)
    final buttonHeight = 150.0; // Aproximadamente el triple de la altura estándar

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribuye el espacio entre widgets
        children: [
          // BOTÓN DE AVANZAR - ARRIBA
          GestureDetector(
            onLongPress: controller.isSendingCommand 
              ? null 
              : () {
                try {
                  controller.sendContinuousMovement(true);
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
            onLongPressEnd: (_) {
              try {
                controller.stopContinuousMovement();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al detener: $e')),
                );
              }
            },
            child: SizedBox(
              width: double.infinity, // Ocupa todo el ancho
              height: buttonHeight, // Triple de alto
              child: CustomButton(
                text: 'AVANZAR',
                onPressed: () {
                  final newPosition = bluetoothService.currentPosition + 100;
                  if (newPosition <= ControlScreenController.maxSteps) {
                    controller.updatePosition(newPosition);
                    _sendSliderPosition(controller, newPosition);
                  }
                },
                enabled: !controller.isSendingCommand,
                textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          
          // CONTENIDO CENTRAL - Sliders y posición
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Slider de velocidad
                  const SizedBox(height: 10),
                  Text(
                    'Velocidad: ${controller.currentSpeed} pasos/s',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Lento', style: TextStyle(fontSize: 12)),
                      Expanded(
                        child: Slider(
                          value: controller.currentSpeedIndex.toDouble(),
                          min: 0,
                          max: ControlScreenController.availableSpeeds.length - 1.0,
                          divisions: ControlScreenController.availableSpeeds.length - 1,
                          label: controller.currentSpeed.toString(),
                          onChanged: (value) {
                            if (!controller.isSendingCommand) {
                              controller.updateSpeedIndex(value.toInt());
                            }
                          },
                        ),
                      ),
                      const Text('Rápido', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  
                  // BOTÓN - ESTABLECER INICIO DE APILADO (REPOSICIONADO)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: CustomButton(
                      text: 'Establecer inicio de apilado',
                      onPressed: () {
                        final currentPos = bluetoothService.currentPosition;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Inicio de apilado establecido en la posición ${currentPos.toStringAsFixed(0)}'),
                          ),
                        );
                      },
                      enabled: !controller.isSendingCommand,
                    ),
                  ),
                  
                  // Slider de aceleración
                  const SizedBox(height: 10),
                  Text(
                    'Aceleración: ${controller.currentAcceleration} pasos/s²',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Suave', style: TextStyle(fontSize: 12)),
                      Expanded(
                        child: Slider(
                          value: controller.currentAccelerationIndex.toDouble(),
                          min: 0,
                          max: ControlScreenController.availableAccelerations.length - 1.0,
                          divisions: ControlScreenController.availableAccelerations.length - 1,
                          label: controller.currentAcceleration.toString(),
                          onChanged: (value) {
                            if (!controller.isSendingCommand) {
                              controller.updateAccelerationIndex(value.toInt());
                            }
                          },
                        ),
                      ),
                      const Text('Brusco', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  
                  // BOTÓN - ESTABLECER FINAL DE APILADO (REPOSICIONADO)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: CustomButton(
                      text: 'Establecer final de apilado',
                      onPressed: () {
                        final currentPos = bluetoothService.currentPosition;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Final de apilado establecido en la posición ${currentPos.toStringAsFixed(0)}'),
                          ),
                        );
                      },
                      enabled: !controller.isSendingCommand,
                    ),
                  ),
                  
                  // Texto de posición actual
                  const SizedBox(height: 10),
                  Text(
                    'Posición: ${bluetoothService.currentPosition.toStringAsFixed(0)} pasos',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  
                  // Slider de posición con el mismo estilo que los otros
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Pos 0', style: TextStyle(fontSize: 12)),
                      Expanded(
                        child: Slider(
                          value: bluetoothService.currentPosition,
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
                      ),
                      const Text('Pos 40k', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  
                ],
              ),
            ),
          ),
          
          // BOTÓN DE RETROCEDER - ABAJO
          GestureDetector(
            onLongPress: controller.isSendingCommand 
              ? null 
              : () {
                try {
                  controller.sendContinuousMovement(false);
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
            onLongPressEnd: (_) {
              try {
                controller.stopContinuousMovement();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al detener: $e')),
                );
              }
            },
            child: SizedBox(
              width: double.infinity, // Ocupa todo el ancho
              height: buttonHeight, // Triple de alto
              child: CustomButton(
                text: 'RETROCEDER',
                onPressed: () {
                  final newPosition = bluetoothService.currentPosition - 100;
                  if (newPosition >= 0) {
                    controller.updatePosition(newPosition);
                    _sendSliderPosition(controller, newPosition);
                  }
                },
                enabled: !controller.isSendingCommand,
                textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (controller.isSendingCommand) ...[
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ],
      ),
    );
  }
}