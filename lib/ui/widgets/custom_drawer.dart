import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:makers_map/domain/controllers/storage_controller.dart';

class CustomDrawer extends StatelessWidget {
  CustomDrawer({Key? key, required this.controller}) : super(key: key) {
    storageController = Get.find();
  }

  late StorageController storageController;
  Rx<GoogleMapController?> controller;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ObxValue<RxList<Marker>>(
          (value) => ListView(
                children: [
                  const DrawerHeader(
                      child: Text(
                        'Tus Markers',
                        style: TextStyle(fontSize: 30),
                        textAlign: TextAlign.center,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.teal,
                      )),
                  ...value
                      .map((marker) => ListTile(
                            title: Text(marker.markerId.toString()),
                            subtitle: Text(marker.position.toString()),
                            onTap: () {
                              if (controller.value != null) {
                                controller.value!.animateCamera(
                                  CameraUpdate.newCameraPosition(
                                    CameraPosition(
                                        target: LatLng(marker.position.latitude,
                                            marker.position.longitude),
                                        zoom: 15),
                                  ),
                                );
                              }

                              Get.back();
                            },
                          ))
                      .toList(),
                ],
              ),
          storageController.markers),
    );
  }
}
