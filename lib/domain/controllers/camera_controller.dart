import 'package:camera/camera.dart';
import 'package:get/get.dart';

class LocalCameraController extends GetxController {
  LocalCameraController() {
    init();
  }
  late Rx<CameraDescription?> cameraDescription = Rx<CameraDescription?>(null);
  late Rx<CameraController?> controller = Rx<CameraController?>(null);
  init() async {
    final cameras = await availableCameras();
    this.cameraDescription.value = cameras.first;
    controller.value = CameraController(
      // Get a specific camera from the list of available cameras.
      cameras.first,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );
  }

  initInternalCameraController() async {
    return controller.value?.initialize();
  }
}
