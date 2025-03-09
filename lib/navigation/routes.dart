// lib/navigation/routes.dart
import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/devices_screen.dart';
import '../screens/control_screen.dart';
import '../bluetooth/bluetooth_service.dart';

class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String devices = '/devices';
  static const String control = '/control';

  static final Map<String, WidgetBuilder> routes = {
    home: (context) => const HomeScreen(),
    devices: (context) => const DevicesScreen(),
    control: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return ControlScreen(
        bluetoothService: args['bluetoothService'] as BluetoothService,
        deviceAddress: args['deviceAddress'] as String,
      );
    },
  };
}