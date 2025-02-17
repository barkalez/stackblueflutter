import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cperfil_screen.dart'; // Importar CPerfilScreen

class EPerfilScreen extends StatefulWidget {
  const EPerfilScreen({super.key});

  @override
  EPerfilScreenState createState() => EPerfilScreenState();
}

class EPerfilScreenState extends State<EPerfilScreen> {
  List<String> _perfiles = [];

  @override
  void initState() {
    super.initState();
    _loadPerfiles();
  }

  Future<void> _loadPerfiles() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _perfiles = prefs.getStringList('perfiles') ?? [];
    });
  }

  void _editProfile(String nombre) async {
    final prefs = await SharedPreferences.getInstance();
    final String? perfilData = prefs.getString('perfil_$nombre');
    if (perfilData != null) {
      final List<String> datos = perfilData.split(',');
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditProfileForm(
              nombre: nombre,
              sensibilidad: datos[0],
              distancia: datos[1],
              pasos: datos[2],
            ),
          ),
        );
      }
    }
  }

  final List<Color> _colors = [
    Colors.blueAccent,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.purple,
    Colors.teal,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _perfiles.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'No se ha creado ningún perfil',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CPerfilScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Crear perfil'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _perfiles.length,
              itemBuilder: (context, index) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: SizedBox(
                      width: 200, // Ancho fijo para los botones
                      child: ElevatedButton(
                        onPressed: () => _editProfile(_perfiles[index]),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _colors[index % _colors.length], // Color del botón
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
                        child: Text(_perfiles[index]),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class EditProfileForm extends StatefulWidget {
  final String nombre;
  final String sensibilidad;
  final String distancia;
  final String pasos;

  const EditProfileForm({
    super.key,
    required this.nombre,
    required this.sensibilidad,
    required this.distancia,
    required this.pasos,
  });

  @override
  EditProfileFormState createState() => EditProfileFormState();
}

class EditProfileFormState extends State<EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _sensibilidadController;
  late TextEditingController _distanciaController;
  late TextEditingController _pasosController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.nombre);
    _sensibilidadController = TextEditingController(text: widget.sensibilidad);
    _distanciaController = TextEditingController(text: widget.distancia);
    _pasosController = TextEditingController(text: widget.pasos);
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String nombre = _nombreController.text;
    final String sensibilidad = _sensibilidadController.text;
    final String distancia = _distanciaController.text;
    final String pasos = _pasosController.text;

    if (nombre.isNotEmpty && sensibilidad.isNotEmpty && distancia.isNotEmpty && pasos.isNotEmpty) {
      final List<String> perfiles = prefs.getStringList('perfiles') ?? [];
      if (!perfiles.contains(nombre)) {
        perfiles.add(nombre);
      }
      await prefs.setStringList('perfiles', perfiles);
      await prefs.setString('perfil_$nombre', '$sensibilidad,$distancia,$pasos');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un nombre de perfil';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _sensibilidadController,
                decoration: const InputDecoration(labelText: 'Sensibilidad tornillo'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la sensibilidad del tornillo';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _distanciaController,
                decoration: const InputDecoration(labelText: 'Distancia por vuelta (mm)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la distancia por vuelta';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _pasosController,
                decoration: const InputDecoration(labelText: 'Pasos por vuelta en FullStep'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese los pasos por vuelta en FullStep';
                  }
                  return null;
                },
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
                  child: const Text('Guardar cambios'),
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