import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makers_map/domain/controllers/camera_controller.dart';
import 'package:makers_map/domain/controllers/storage_controller.dart';
import 'package:makers_map/ui/my_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put<StorageController>(StorageController());
  Get.put<LocalCameraController>(LocalCameraController());

  runApp(MyApp());
}
