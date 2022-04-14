import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:makers_map/data/models/comment_model.dart';
import 'package:makers_map/data/models/marker_model.dart';
import 'package:makers_map/data/models/picture_model.dart';
import 'package:makers_map/domain/controllers/storage_controller.dart';
import 'package:makers_map/ui/pages/add_comment.dart';
import 'package:makers_map/ui/pages/take_photo_page.dart';
import 'package:makers_map/utils/image/image.dart';

// ignore: must_be_immutable
class ShowMarker extends StatelessWidget {
  ShowMarker({
    Key? key,
  }) : super(key: key) {
    storageController = Get.find();
    if (Get.arguments.length > 1) {
      imgList = Get.arguments[0];
      comList = Get.arguments[1];
      nPhoto = RxString("0/${imgList.length}");
      _listUbication = [Get.arguments[2], Get.arguments[3]];
    } else {
      markerActive = Get.arguments[0];

      imgList = RxList<Map<String, dynamic>>(
          markerActive!.pictures!.map((e) => e.toMap()).toList());
      comList = RxList<Map<String, dynamic>>(
          markerActive!.comments!.map((e) => e.toMap()).toList());
      if (imgList.isNotEmpty) {
        nPhoto = RxString("1/${imgList.length}");
      } else {
        nPhoto = RxString("0/${imgList.length}");
      }
    }
  }

  late RxList<Map<String, dynamic>> imgList;
  late RxList<Map<String, dynamic>> comList;
  late RxString nPhoto;
  MarkerModel? markerActive;
  late StorageController storageController;
  late List<double>? _listUbication;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Get.arguments.length > 1
              ? const Text('Agregar Marker')
              : const Text('Actualizar Marker'),
          actions: Get.arguments.length == 1
              ? [
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await storageController.deleteMarker(markerActive!.id!);
                      storageController.markers.removeWhere(
                          (e) => e.mapsId.value == markerActive!.id.toString());

                      Get.back();
                    },
                  )
                ]
              : [],
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      "Imagenes",
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        Get.to(() => TakePhotoPage(),
                            arguments: [imgList, nPhoto]);
                      },
                      icon: const Icon(Icons.add_a_photo)),
                ],
              ),
            ),
            ObxValue<RxString>(
                (value) => Text(
                      value.value,
                      textAlign: TextAlign.center,
                    ),
                nPhoto),
            ObxValue<RxList<Map<String, dynamic>>>((value) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: CarouselSlider(
                  options: CarouselOptions(
                    onPageChanged: (index, reason) {
                      nPhoto.value = "${index + 1}/${imgList.length}";
                    },
                    enableInfiniteScroll: false,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 6),
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 5000),
                  ),
                  items: value
                      .map(
                        (img) => Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: ImageUtils.imageFromBase64String(
                                img["picture"]),
                          ),
                        ),
                      )
                      .toList(),
                ),
              );
            }, imgList),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      "Comentarios",
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        Get.to(() => AddComment(), arguments: [comList]);
                      },
                      icon: const Icon(Icons.add_comment)),
                ],
              ),
            ),
            ObxValue<RxList<Map<String, dynamic>>>((value) {
              return Column(
                children: [
                  // ignore: invalid_use_of_protected_member
                  ...List.generate(value.value.length, (index) {
                    return ListTile(
                      title: Text(value[index]['title']),
                      subtitle: Text(value[index]['comment']),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          print(value[index]);
                          print(value[index]["id_marker"]);
                          if (value[index]['id'] != null &&
                              value[index]["id_marker"] != null) {
                            await storageController.deleteComment(
                                id: value[index]['id'],
                                idMarker: value[index]['id_marker']);
                          }
                          value.removeAt(index);
                        },
                      ),
                    );
                  })
                ],
              );
            }, comList),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (markerActive == null) {
              print("Add marker");
              try {
                int? id = await storageController.addMarker({
                  "id": null,
                  "comments": comList
                      .map<CommentModel>((val) => CommentModel(
                            comment: val["comment"],
                            title: val["title"],
                          ))
                      .toList(),
                  "pictures": imgList
                      .map<PictureModel>((element) =>
                          PictureModel(pictureString: element["picture"]))
                      .toList(),
                  "latitude": _listUbication?.first,
                  "longitude": _listUbication?.last,
                });
                print(" new marker id:${id}");
                if (id != null) {
                  storageController.markers.add(Marker(
                      markerId: MarkerId(id.toString()),
                      position:
                          LatLng(_listUbication!.first, _listUbication!.last),
                      onTap: () async {
                        MarkerModel? c = await storageController.getMarker(id);
                        if (c != null) {
                          Get.to(() => ShowMarker(), arguments: [c]);
                        }
                      }));
                }

                Get.back();
              } catch (e) {
                print(e);
              }
            } else {
              try {
                await storageController.updateMarker(
                    id: markerActive!.id,
                    comments: comList
                        .map<CommentModel>((val) => CommentModel(
                              id: val["id"],
                              comment: val["comment"],
                              title: val["title"],
                            ))
                        .toList(),
                    pictures: imgList
                        .map<PictureModel>((element) => PictureModel(
                            pictureString: element["picture"],
                            id: element["id"]))
                        .toList());

                Get.back();
              } catch (e) {
                print(e);
              }
            }
          },
          child: const Icon(Icons.save),
        ));
  }
}
