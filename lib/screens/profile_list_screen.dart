// lib/screens/profile_list_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile.dart';
import '../widgets/custom_appbar.dart';
import '../bluetooth/bluetooth_service.dart';
import '../navigation/routes.dart';

class ProfileListScreen extends StatefulWidget {
  final String deviceAddress; // Solo mantenemos deviceAddress

  const ProfileListScreen({
    super.key,
    required this.deviceAddress,
  }); // Eliminamos bluetoothService

  @override
  State<ProfileListScreen> createState() => _ProfileListScreenState();
}

class _ProfileListScreenState extends State<ProfileListScreen> {
  List<Profile> _profiles = [];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final profilesJson = prefs.getString('profiles') ?? '[]';
    final profilesList = jsonDecode(profilesJson) as List;
    if (mounted) {
      setState(() {
        _profiles = profilesList.map((e) => Profile.fromJson(e)).toList();
      });
    }
  }

  Future<void> _deleteProfile(int index) async {
    final prefs = await SharedPreferences.getInstance();
    _profiles.removeAt(index);
    await prefs.setString('profiles', jsonEncode(_profiles.map((e) => e.toJson()).toList()));

    if (!mounted) return;
    setState(() {});
    if (_profiles.isEmpty) {
      Navigator.pop(context);
    }
  }

  void _selectProfile(Profile profile) {
    Provider.of<BluetoothService>(context, listen: false); // Obtenemos del Provider

    if (!mounted) return;

    selectedProfile = profile; // Guardamos el perfil seleccionado
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Perfil "${profile.name}" cargado')),
    );
    // Navegamos a ControlScreen con solo deviceAddress
    Navigator.pushNamed(
      context,
      Routes.control,
      arguments: {
        'deviceAddress': widget.deviceAddress,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Lista de Perfiles'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _profiles.isEmpty
            ? const Center(child: Text('No hay perfiles guardados'))
            : ListView.builder(
                itemCount: _profiles.length,
                itemBuilder: (context, index) {
                  final profile = _profiles[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        profile.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pasos/vuelta: ${profile.stepsPerTurn}'),
                          Text('Distancia/vuelta: ${profile.distancePerTurn} mm'),
                          Text('Sensibilidad: ${profile.screwSensitivity} mm'),
                          Text('Recorrido total: ${profile.totalDistance} mm'), // Nueva línea
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProfile(index),
                      ),
                      onTap: () => _selectProfile(profile),
                    ),
                  );
                },
              ),
      ),
    );
  }
}