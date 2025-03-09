// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stackblue/screens/control_screen.dart';
import 'package:stackblue/screens/devices_screen.dart';
import 'package:stackblue/screens/home_screen.dart';
import 'bluetooth/bluetooth_service.dart';
import 'navigation/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BluetoothService>(create: (_) => BluetoothService()), // Cambiado de Provider a ChangeNotifierProvider
      ],
      child: Builder(
        builder: (context) {
          final bluetoothService = Provider.of<BluetoothService>(context, listen: false);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            initialRoute: Routes.home,
            routes: {
              Routes.home: (_) => const HomeScreen(),
              Routes.devices: (_) => DevicesScreen(bluetoothService: bluetoothService),
              Routes.control: (context) {
                final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
                return ControlScreen(
                  bluetoothService: args['bluetoothService'] as BluetoothService,
                  deviceAddress: args['deviceAddress'] as String,
                );
              },
            },
          );
        },
      ),
    );
  }
}