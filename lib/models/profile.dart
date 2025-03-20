// lib/models/profile.dart
class Profile {
  final String id;
  final String name;
  final double stepsPerTurn;
  final double distancePerTurn;
  final double screwSensitivity;
  final double totalDistance;

  Profile({
    required this.id,
    required this.name,
    required this.stepsPerTurn,
    required this.distancePerTurn,
    required this.screwSensitivity,
    required this.totalDistance,
  });

  // Crear un Profile desde un Map
  factory Profile.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic value, double defaultValue) {
      if (value == null) return defaultValue;
      if (value is int) return value.toDouble();
      if (value is double) return value;
      if (value is String) return double.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    return Profile(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name']?.toString() ?? 'Perfil sin nombre',
      stepsPerTurn: toDouble(json['stepsPerTurn'], 200.0),
      distancePerTurn: toDouble(json['distancePerTurn'], 8.0),
      screwSensitivity: toDouble(json['screwSensitivity'], 0.04),
      totalDistance: toDouble(json['totalDistance'], 40000.0),
    );
  }

  // Convertir a Map para guardar
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'stepsPerTurn': stepsPerTurn,
      'distancePerTurn': distancePerTurn,
      'screwSensitivity': screwSensitivity,
      'totalDistance': totalDistance,
    };
  }
}

// Variables globales para el perfil seleccionado
Profile? selectedProfile;