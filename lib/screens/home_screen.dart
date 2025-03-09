// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../navigation/routes.dart'; // Asegúrate de importar routes.dart
import '../widgets/custom_appbar.dart';
import '../widgets/custom_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Home Screen'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButton(
                text: 'Buscar dispositivos',
                color: Colors.blue,
                onPressed: () {
                  Navigator.pushNamed(context, Routes.devices); // Cambiado de AppRoutes a Routes
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}