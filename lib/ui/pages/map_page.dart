import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:makers_map/domain/controllers/storage_controller.dart';
import 'package:makers_map/ui/pages/show_marker_page.dart';
import 'package:location/location.dart';
import 'package:makers_map/ui/widgets/custom_drawer.dart';

class MapPage extends StatelessWidget {
  MapPage({Key? key}) : super(key: key) {
    storageController = Get.find();
    _controller = Rx<GoogleMapController?>(null);
    currentLocation = RxBool(true);
  }

  late Rx<GoogleMapController?> _controller;
  final Location _location = Location();
  final RxDouble _latitude = RxDouble(0);
  final RxDouble _longitude = RxDouble(0);
  late StorageController storageController;
  late RxBool currentLocation;

  onMapCreated(GoogleMapController controller) {
    _controller.value = controller;

    _location.onLocationChanged.listen((l) {
      _latitude.value = l.latitude!;
      _longitude.value = l.longitude!;

      if (currentLocation.value) {
        _controller.value!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: LatLng(l.latitude!, l.longitude!), zoom: 15),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ObxValue<RxList<Marker>>(
        (value) => Scaffold(
              appBar: AppBar(
                title: const Text('Map'),
                actions: [
                  ObxValue<RxBool>(
                      (value) => IconButton(
                          icon: value.value
                              ? const Icon(Icons.my_location_rounded)
                              : const Icon(Icons.location_disabled_outlined),
                          onPressed: () {
                            value.value = !value.value;
                          }),
                      currentLocation)
                ],
              ),
              body: GoogleMap(
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                initialCameraPosition: const CameraPosition(
                  target: LatLng(
                    -34.92873,
                    -56.1645,
                  ),
                  zoom: 15,
                ),
                // ignore: invalid_use_of_protected_member
                markers: Set.from(value.value),
                onMapCreated: onMapCreated,
              ),
              drawer: CustomDrawer(
                controller: _controller,
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.startFloat,
              floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    Get.to(() => ShowMarker(), arguments: [
                      RxList<Map<String, dynamic>>(),
                      RxList<Map<String, dynamic>>(),
                      _latitude.value,
                      _longitude.value,
                    ]);
                  },
                  child: const Icon(Icons.add)),
            ),
        storageController.markers);
  }
}
