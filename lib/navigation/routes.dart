// lib/navigation/routes.dart
import 'package:flutter/material.dart';
import '../screens/control_screen.dart';
import '../screens/devices_screen.dart';
import '../screens/home_screen.dart';
import '../bluetooth/bluetooth_service.dart';

class Routes {
  static const String home = '/';
  static const String devices = '/devices';
  static const String control = '/control';

  static final routes = <String, WidgetBuilder>{
    home: (context) => const HomeScreen(),
    devices: (context) => DevicesScreen(
          bluetoothService: ModalRoute.of(context)!.settings.arguments as BluetoothService,
        ),
    control: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final bluetoothService = args['bluetoothService'] as BluetoothService;
      final deviceAddress = args['deviceAddress'] as String;
      return ControlScreen(
        bluetoothService: bluetoothService,
        deviceAddress: deviceAddress,
      );
    },
  };
}