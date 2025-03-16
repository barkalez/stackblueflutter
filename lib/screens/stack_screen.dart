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
    _initialPositionController = TextEditingController();
    _finalPositionController = TextEditingController();
    _photoCountController = TextEditingController();
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

  Widget _buildDefineButton(BuildContext context) {
    Provider.of<BluetoothService>(context); // Obtenemos del Provider
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            Routes.controlManualScreen,
          ); // No necesitamos pasar bluetoothService
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal.shade600,
          foregroundColor: Colors.white,
          minimumSize: const Size(60, 30),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Definir',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              TextField(
                controller: _initialPositionController,
                decoration: InputDecoration(
                  labelText: 'Posición inicial',
                  suffixIcon: _buildDefineButton(context),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _finalPositionController,
                decoration: InputDecoration(
                  labelText: 'Posición final',
                  suffixIcon: _buildDefineButton(context),
                ),
                keyboardType: TextInputType.number,
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