// lib/widgets/custom_appbar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stackblue/bluetooth/bluetooth_service.dart';
import 'package:stackblue/utils/message_utils.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final bluetoothService = Provider.of<BluetoothService>(context);

    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade800,
              Colors.blue.shade400,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2), // Línea 38 corregida
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      ),
      elevation: 4,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bluetoothService.isConnected
                  ? Colors.green.shade600
                  : Colors.red.shade400.withValues(alpha: 0.7),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3), // Línea 59 corregida
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.bluetooth,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () async {
                if (bluetoothService.isConnected) {
                  try {
                    // Desconectar si está conectado
                    await bluetoothService.disconnect();
                    if (context.mounted) {
                      MessageUtils.showInfoMessage(context, 'Desconectado de StackBlue');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      MessageUtils.showErrorMessage(context, 'Error al desconectar: $e');
                    }
                  }
                } else {
                  try {
                    // Intentar reconectar si está desconectado
                    await bluetoothService.reconnect();
                    if (context.mounted) {
                      MessageUtils.showSuccessMessage(context, 'Reconectado a StackBlue');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      MessageUtils.showErrorMessage(context, 'Error al reconectar: $e');
                    }
                  }
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}