import 'package:permission_handler/permission_handler.dart';

class PermissionService {

  Future<bool> requestLocationPermission() async {

    PermissionStatus status = await Permission.location.request();

    if (status.isGranted) {
      return true;
    }

    return false;
  }

  Future<bool> requestNotificationPermission() async {

    PermissionStatus status =
        await Permission.notification.request();

    if (status.isGranted) {
      return true;
    }

    return false;
  }

}