import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_appbar.dart';
import 'devices_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logger = Logger();

    return Scaffold(
      appBar: const CustomAppBar(title: 'Home'),
      body: Center(
        child: CustomButton(
          text: 'Buscar StackBlue',
          color: Colors.green,
          onPressed: () {
            // Acción al presionar el botón
            logger.i('Buscar StackBlue button pressed');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DevicesScreen()),
            );
          },
        ),
      ),
    );
  }
}