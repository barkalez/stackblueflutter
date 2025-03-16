// lib/screens/profile_creation_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../navigation/routes.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_button.dart';
import '../bluetooth/bluetooth_service.dart';

class ProfileCreationScreen extends StatefulWidget {
  final String? deviceAddress; // Solo mantenemos deviceAddress

  const ProfileCreationScreen({
    super.key,
    this.deviceAddress,
  }); // Eliminamos bluetoothService

  @override
  State<ProfileCreationScreen> createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen> {
  bool _hasProfiles = false;

  @override
  void initState() {
    super.initState();
    _checkProfiles();
  }

  Future<void> _checkProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final profilesJson = prefs.getString('profiles') ?? '[]';
    final profilesList = jsonDecode(profilesJson) as List;
    setState(() {
      _hasProfiles = profilesList.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<BluetoothService>(context); // Obtenemos del Provider global

    return Scaffold(
      appBar: const CustomAppBar(title: 'Crear Perfil'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButton(
                text: 'Crear perfil',
                color: Colors.teal,
                onPressed: () {
                  Navigator.pushNamed(context, Routes.profileForm).then((_) {
                    _checkProfiles();
                  });
                },
              ),
              if (_hasProfiles) ...[
                const SizedBox(height: 20),
                CustomButton(
                  text: 'Cargar perfiles',
                  color: Colors.teal.shade300,
                  onPressed: () {
                    if (widget.deviceAddress == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No hay dispositivo conectado')),
                      );
                      return;
                    }
                    Navigator.pushNamed(
                      context,
                      Routes.profileList,
                      arguments: {
                        'deviceAddress': widget.deviceAddress, // Solo pasamos deviceAddress
                      },
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}