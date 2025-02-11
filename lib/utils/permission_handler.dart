import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  static Future<bool> checkPermissions() async {
    PermissionStatus bluetoothPermission = await Permission.bluetoothConnect.request();
    PermissionStatus locationPermission = await Permission.location.request();
    PermissionStatus bluetoothScanPermission = await Permission.bluetoothScan.request();

    return bluetoothPermission.isGranted && locationPermission.isGranted && bluetoothScanPermission.isGranted;
  }
}
