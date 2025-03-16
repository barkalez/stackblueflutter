// lib/navigation/routes.dart
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../screens/control_screen.dart';
import '../screens/devices_screen.dart';
import '../screens/home_screen.dart';
import '../screens/profile_creation_screen.dart';
import '../screens/profile_form_screen.dart';
import '../screens/profile_list_screen.dart';
import '../screens/stack_screen.dart';
import '../screens/control_manual_screen.dart';

class Routes {
  static const String home = '/';
  static const String devices = '/devices';
  static const String control = '/control';
  static const String profileCreation = '/profile_creation';
  static const String profileForm = '/profile_form';
  static const String profileList = '/profile_list';
  static const String stackScreen = '/stack_screen';
  static const String controlManualScreen = '/control_manual_screen';

  static final Logger _logger = Logger();

  static final routes = <String, WidgetBuilder>{
    home: (context) => const HomeScreen(),
    devices: (context) => const DevicesScreen(), // Sin argumentos
    control: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      if (args == null || args['deviceAddress'] == null) {
        _logger.w('No se proporcionó deviceAddress para ControlScreen');
        throw const FormatException('deviceAddress argument is required for ControlScreen');
      }
      return ControlScreen(
        deviceAddress: args['deviceAddress'] as String,
      );
    },
    profileCreation: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      return ProfileCreationScreen(
        deviceAddress: args?['deviceAddress'] as String?,
      );
    },
    profileForm: (context) => const ProfileFormScreen(),
    profileList: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      if (args == null || args['deviceAddress'] == null) {
        _logger.w('No se proporcionó deviceAddress para ProfileListScreen');
        throw const FormatException('deviceAddress argument is required for ProfileListScreen');
      }
      return ProfileListScreen(
        deviceAddress: args['deviceAddress'] as String,
      );
    },
    stackScreen: (context) => const StackScreen(),
    controlManualScreen: (context) => const ControlManualScreen(),
  };
}