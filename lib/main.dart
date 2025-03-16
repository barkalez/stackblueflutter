// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        ChangeNotifierProvider<BluetoothService>(
          create: (_) => BluetoothService(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: Routes.home,
        routes: Routes.routes,
      ),
    );
  }
}