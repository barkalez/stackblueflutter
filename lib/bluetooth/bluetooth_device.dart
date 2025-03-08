// lib/bluetooth/bluetooth_device.dart
/// Modelo que representa un dispositivo Bluetooth detectado o conectado en StackBlue.
///
/// Utilizado para almacenar información básica de dispositivos Bluetooth encontrados
/// durante el escaneo y para gestionar la conexión con el ESP32 en el proyecto de macrofotografía.
class BluetoothDevice {
  /// Nombre del dispositivo (puede ser nulo si no está disponible).
  final String? name;

  /// Dirección única del dispositivo (MAC address).
  final String address;

  /// Constructor constante para crear un dispositivo Bluetooth.
  const BluetoothDevice({
    this.name,
    required this.address,
  });

  /// Crea un [BluetoothDevice] a partir de un mapa (por ejemplo, desde JSON o datos nativos).
  factory BluetoothDevice.fromMap(Map<String, dynamic> map) {
    return BluetoothDevice(
      name: map['name'] as String?,
      address: map['address'] as String,
    );
  }

  /// Convierte el dispositivo a un mapa para serialización.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BluetoothDevice &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          address == other.address;

  @override
  int get hashCode => Object.hash(name, address);

  @override
  String toString() => 'BluetoothDevice(name: $name, address: $address)';
}