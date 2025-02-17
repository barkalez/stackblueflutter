import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'adjust_screen.dart'; // Importar AdjustScreen

class CPerfilScreen extends StatefulWidget {
  const CPerfilScreen({super.key});

  @override
  CPerfilScreenState createState() => CPerfilScreenState();
}

class CPerfilScreenState extends State<CPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _sensibilidadController = TextEditingController();
  final TextEditingController _distanciaController = TextEditingController();
  final TextEditingController _pasosController = TextEditingController();

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String nombre = _nombreController.text;
    final String sensibilidad = _sensibilidadController.text;
    final String distancia = _distanciaController.text;
    final String pasos = _pasosController.text;

    if (nombre.isNotEmpty && sensibilidad.isNotEmpty && distancia.isNotEmpty && pasos.isNotEmpty) {
      final List<String> perfiles = prefs.getStringList('perfiles') ?? [];
      perfiles.add(nombre);
      await prefs.setStringList('perfiles', perfiles);
      await prefs.setString('perfil_$nombre', '$sensibilidad,$distancia,$pasos');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Perfil creado'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdjustScreen()),
          );
        }
      }
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String? _validateNombre(String? value) {
    if (value == null || value.isEmpty) {
      _showErrorMessage('El campo Nombre perfil está vacío');
      return 'Por favor ingrese un nombre de perfil';
    }
    final RegExp regex = RegExp(r'^[a-zA-Z0-9]{1,16}$');
    if (!regex.hasMatch(value)) {
      _showErrorMessage('Nombre perfil solo puede contener caracteres alfanuméricos y tener un máximo de 16 caracteres');
      return 'Nombre perfil inválido';
    }
    return null;
  }

  String? _validateSensibilidad(String? value) {
    if (value == null || value.isEmpty) {
      _showErrorMessage('El campo Sensibilidad tornillo está vacío');
      return 'Por favor ingrese la sensibilidad del tornillo';
    }
    final RegExp regex = RegExp(r'^\d*\.\d+$');
    if (!regex.hasMatch(value)) {
      _showErrorMessage('Sensibilidad tornillo debe ser un número decimal positivo');
      return 'Sensibilidad tornillo inválida';
    }
    return null;
  }

  String? _validateDistancia(String? value) {
    if (value == null || value.isEmpty) {
      _showErrorMessage('El campo Distancia por vuelta está vacío');
      return 'Por favor ingrese la distancia por vuelta';
    }
    final RegExp regex = RegExp(r'^\d+(\.\d+)?$');
    if (!regex.hasMatch(value) || double.tryParse(value)! <= 0) {
      _showErrorMessage('Distancia por vuelta debe ser un número positivo');
      return 'Distancia por vuelta inválida';
    }
    return null;
  }

  String? _validatePasos(String? value) {
    if (value == null || value.isEmpty) {
      _showErrorMessage('El campo Pasos por vuelta está vacío');
      return 'Por favor ingrese los pasos por vuelta';
    }
    final RegExp regex = RegExp(r'^[1-9]\d*$');
    if (!regex.hasMatch(value)) {
      _showErrorMessage('Pasos por vuelta debe ser un número entero positivo');
      return 'Pasos por vuelta inválido';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Perfil'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre perfil'),
                validator: _validateNombre,
              ),
              TextFormField(
                controller: _sensibilidadController,
                decoration: const InputDecoration(labelText: 'Sensibilidad tornillo (mm)'),
                validator: _validateSensibilidad,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              TextFormField(
                controller: _distanciaController,
                decoration: const InputDecoration(labelText: 'Distancia por vuelta (mm)'),
                validator: _validateDistancia,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              TextFormField(
                controller: _pasosController,
                decoration: const InputDecoration(labelText: 'Pasos por vuelta en FullStep'),
                validator: _validatePasos,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16), // Espacio entre el formulario y el botón
              SizedBox(
                width: 200, // Ancho fijo para el botón
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _saveProfile();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Color de fondo del botón Crear perfil
                    foregroundColor: Colors.white, // Color del texto del botón
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), // Padding del botón
                    textStyle: const TextStyle(
                      fontSize: 18, // Tamaño del texto
                      fontWeight: FontWeight.bold, // Peso del texto
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Bordes redondeados
                    ),
                  ),
                  child: const Text('Crear perfil'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _sensibilidadController.dispose();
    _distanciaController.dispose();
    _pasosController.dispose();
    super.dispose();
  }
}