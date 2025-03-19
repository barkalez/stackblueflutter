// lib/screens/stack_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/profile.dart';
import '../widgets/custom_appbar.dart';
import '../navigation/routes.dart';
import '../bluetooth/bluetooth_service.dart';

class StackScreen extends StatefulWidget {
  const StackScreen({super.key}); // No necesitamos bluetoothService como parámetro

  @override
  State<StackScreen> createState() => _StackScreenState();
}

class _StackScreenState extends State<StackScreen> {
  late TextEditingController _stepsPerTurnController;
  late TextEditingController _distancePerTurnController;
  late TextEditingController _screwSensitivityController;
  late TextEditingController _initialPositionController;
  late TextEditingController _finalPositionController;
  late TextEditingController _photoCountController;

  @override
  void initState() {
    super.initState();
    _stepsPerTurnController = TextEditingController(text: selectedProfile?.stepsPerTurn.toString() ?? '');
    _distancePerTurnController = TextEditingController(text: selectedProfile?.distancePerTurn.toString() ?? '');
    _screwSensitivityController = TextEditingController(text: selectedProfile?.screwSensitivity.toString() ?? '');
    
    // Los controladores de posición se inicializarán con los valores del Provider en didChangeDependencies
    _initialPositionController = TextEditingController();
    _finalPositionController = TextEditingController();
    _photoCountController = TextEditingController();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Obtener el servicio después de que se haya inicializado el contexto
    final bluetoothService = Provider.of<BluetoothService>(context, listen: false);
    
    // Actualizar los controladores con los valores del servicio
    _initialPositionController.text = bluetoothService.stackStartPosition.toStringAsFixed(0);
    _finalPositionController.text = bluetoothService.stackEndPosition.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _stepsPerTurnController.dispose();
    _distancePerTurnController.dispose();
    _screwSensitivityController.dispose();
    _initialPositionController.dispose();
    _finalPositionController.dispose();
    _photoCountController.dispose();
    super.dispose();
  }

  // Método para navegar a control manual y definir la posición
  void _navigateToControlManual(bool isInitialPosition) {
    Navigator.pushNamed(context, Routes.controlManualScreen);
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothService = Provider.of<BluetoothService>(context);
    
    return Scaffold(
      appBar: const CustomAppBar(title: 'Crear Apilado'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _stepsPerTurnController,
                decoration: const InputDecoration(labelText: 'Pasos por vuelta'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _distancePerTurnController,
                decoration: const InputDecoration(labelText: 'Distancia por vuelta'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _screwSensitivityController,
                decoration: const InputDecoration(labelText: 'Sensibilidad'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              // Campo de posición inicial
              TextField(
                controller: _initialPositionController,
                decoration: InputDecoration(
                  labelText: 'Posición inicial',
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ElevatedButton(
                      onPressed: () => _navigateToControlManual(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade600,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(60, 30),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Definir', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  // Actualizar el valor en el servicio cuando se edita manualmente
                  if (value.isNotEmpty) {
                    bluetoothService.setStackStartPosition(double.tryParse(value) ?? 0);
                  }
                },
              ),
              
              const SizedBox(height: 16),
              
              // Campo de posición final
              TextField(
                controller: _finalPositionController,
                decoration: InputDecoration(
                  labelText: 'Posición final',
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ElevatedButton(
                      onPressed: () => _navigateToControlManual(false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade600,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(60, 30),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Definir', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  // Actualizar el valor en el servicio cuando se edita manualmente
                  if (value.isNotEmpty) {
                    bluetoothService.setStackEndPosition(double.tryParse(value) ?? 0);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _photoCountController,
                decoration: const InputDecoration(labelText: 'Número de fotos'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
    );
  }
}