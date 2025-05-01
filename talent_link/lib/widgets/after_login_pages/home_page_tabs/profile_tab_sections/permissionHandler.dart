import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<bool> checkAndRequestPermissions() async {
    Map<Permission, PermissionStatus> statuses =
        await [Permission.camera, Permission.microphone].request();

    print("Permission statuses: $statuses");

    return statuses[Permission.camera]!.isGranted &&
        statuses[Permission.microphone]!.isGranted;
  }

  static Future<bool> checkPermissions() async {
    bool cameraGranted = await Permission.camera.isGranted;
    bool microphoneGranted = await Permission.microphone.isGranted;

    print(
      "Camera permission: $cameraGranted, Microphone permission: $microphoneGranted",
    );

    return cameraGranted && microphoneGranted;
  }
}
