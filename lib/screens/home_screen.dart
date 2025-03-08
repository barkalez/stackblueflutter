// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_appbar.dart';
import '../navigation/routes.dart';

/// Pantalla inicial de la aplicación StackBlue.
///
/// Muestra un botón para iniciar la búsqueda de dispositivos Bluetooth.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final _logger = Logger();

  /// Navega a la pantalla de dispositivos Bluetooth.
  void _navigateToDevicesScreen(BuildContext context) {
    _logger.i('Buscar StackBlue button pressed');
    Navigator.pushNamed(context, AppRoutes.devices);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Home'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                const SizedBox(height: 20),
              CustomButton(
                text: 'Buscar StackBlue',
                color: Colors.green,
                onPressed: () => _navigateToDevicesScreen(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}