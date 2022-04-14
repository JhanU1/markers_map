import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makers_map/domain/controllers/camera_controller.dart';
import 'package:makers_map/utils/image/image.dart';

class TakePhotoPage extends StatelessWidget {
  TakePhotoPage({Key? key}) : super(key: key) {
    localCameraController = Get.find();
    _initializeControllerFuture =
        localCameraController.initInternalCameraController();
    nPhoto = Get.arguments[1];
    listImages = Get.arguments[0];
  }
  late RxList<Map<String, dynamic>> listImages = Get.arguments[0];
  late RxString nPhoto;
  late LocalCameraController localCameraController;
  late Future<void> _initializeControllerFuture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(localCameraController.controller.value!);
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image =
                await localCameraController.controller.value!.takePicture();
            image.readAsBytes().then((bytes) {
              listImages.add({"picture": ImageUtils.base64String(bytes)});
              nPhoto.value = "1/${listImages.length}";
            }).catchError((e) {
              print(e);
            });
            Get.back();

            // If the picture was taken, display it on a new screen
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
