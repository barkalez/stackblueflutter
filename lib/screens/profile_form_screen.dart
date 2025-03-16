// lib/screens/profile_form_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_button.dart';

class ProfileFormScreen extends StatefulWidget {
  const ProfileFormScreen({super.key});

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _stepsPerTurnController = TextEditingController();
  final _distancePerTurnController = TextEditingController();
  final _screwSensitivityController = TextEditingController();

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      final newProfile = Profile(
        name: _nameController.text,
        stepsPerTurn: int.parse(_stepsPerTurnController.text),
        distancePerTurn: double.parse(_distancePerTurnController.text),
        screwSensitivity: double.parse(_screwSensitivityController.text),
      );

      // Obtenemos la lista existente o creamos una nueva
      final profilesJson = prefs.getString('profiles') ?? '[]';
      final List<dynamic> profilesList = jsonDecode(profilesJson);
      final profiles = profilesList.map((e) => Profile.fromJson(e)).toList();

      // Añadimos el nuevo perfil
      profiles.add(newProfile);
      await prefs.setString('profiles', jsonEncode(profiles.map((e) => e.toJson()).toList()));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil guardado exitosamente')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _stepsPerTurnController.dispose();
    _distancePerTurnController.dispose();
    _screwSensitivityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Nuevo Perfil'),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Crear Nuevo Perfil',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _nameController,
                  label: 'Nombre de perfil',
                  hint: 'Ej: Perfil 1',
                  validator: (value) =>
                      value!.isEmpty ? 'Ingresa un nombre' : null,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _stepsPerTurnController,
                  label: 'Pasos por vuelta',
                  hint: 'Ej: 3200',
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty || int.tryParse(value) == null
                          ? 'Ingresa un número válido'
                          : null,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _distancePerTurnController,
                  label: 'Distancia por vuelta (mm)',
                  hint: 'Ej: 8.0',
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) =>
                      value!.isEmpty || double.tryParse(value) == null
                          ? 'Ingresa un número válido'
                          : null,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _screwSensitivityController,
                  label: 'Sensibilidad tornillo',
                  hint: 'Ej: 1.5',
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) =>
                      value!.isEmpty || double.tryParse(value) == null
                          ? 'Ingresa un número válido'
                          : null,
                ),
                const SizedBox(height: 30),
                CustomButton(
                  text: 'Guardar perfil',
                  color: Colors.teal.shade700,
                  onPressed: _saveProfile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.teal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.teal),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
        filled: true,
        fillColor: Colors.teal.shade50,
      ),
      validator: validator,
    );
  }
}