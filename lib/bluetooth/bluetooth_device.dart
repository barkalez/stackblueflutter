// lib/bluetooth_device.dart
class BluetoothDevice {
  final String? name;
  final String address;

  BluetoothDevice({this.name, required this.address});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BluetoothDevice &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          address == other.address;

  @override
  int get hashCode => name.hashCode ^ address.hashCode;
}