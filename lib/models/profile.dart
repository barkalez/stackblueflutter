// lib/models/profile.dart
class Profile {
  final String name;
  final int stepsPerTurn;
  final double distancePerTurn;
  final double screwSensitivity;

  Profile({
    required this.name,
    required this.stepsPerTurn,
    required this.distancePerTurn,
    required this.screwSensitivity,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'stepsPerTurn': stepsPerTurn,
        'distancePerTurn': distancePerTurn,
        'screwSensitivity': screwSensitivity,
      };

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        name: json['name'] as String,
        stepsPerTurn: json['stepsPerTurn'] as int,
        distancePerTurn: json['distancePerTurn'] as double,
        screwSensitivity: json['screwSensitivity'] as double,
      );
}

// Variables globales para el perfil seleccionado
Profile? selectedProfile;