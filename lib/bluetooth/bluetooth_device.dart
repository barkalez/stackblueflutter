// Define la clase BluetoothDevice.
class BluetoothDevice {
  // Campo final para almacenar el nombre del dispositivo.
  final String name;
  // Campo final para almacenar la dirección del dispositivo.
  final String address;

  // Constructor de la clase BluetoothDevice.
  // Requiere que se proporcionen el nombre y la dirección del dispositivo.
  BluetoothDevice({required this.name, required this.address});
}