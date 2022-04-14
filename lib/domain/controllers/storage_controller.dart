import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:makers_map/data/data_source/local_data_source.dart';
import 'package:makers_map/data/models/comment_model.dart';
import 'package:makers_map/data/models/marker_model.dart';
import 'package:makers_map/data/models/picture_model.dart';
import 'package:makers_map/ui/pages/show_marker_page.dart';

class StorageController extends GetxController {
  StorageController() {
    markers = RxList<Marker>([]);
    _init();
  }
  _init() async {
    _localStorage = LocalDataSource();
    await _localStorage.initDatabase();
    List<Marker> c = await getMarkers();
    markers.value = c;
  }

  late LocalDataSource _localStorage;
  late RxList<Marker> markers;

  Future<List<Marker>> getMarkers() async {
    List list = await _localStorage.getMarkers();
    list = list
        .map<Marker>((marker) => Marker(
            markerId: MarkerId(marker.id.toString()),
            position: LatLng(marker.latitude, marker.longitude),
            onTap: () async {
              MarkerModel? c = await getMarker(marker.id!);
              if (c != null) {
                Get.to(() => ShowMarker(), arguments: [c]);
              }
            }))
        .toList();
    return list as List<Marker>;
  }

  Future<MarkerModel?> getMarker(int id) async {
    return await _localStorage.getMarker(id);
  }

  Future<int?> addMarker(Map<String, dynamic> map) async {
    return await _localStorage.addMarker(MarkerModel.fromMap(map));
  }

  Future<void> updateMarker(
      {id, pictures = const [], comments = const []}) async {
    MarkerModel? markerBd = await _localStorage.getMarker(id);
    if (markerBd != null) {
      List<PictureModel> picturesFiltered = [];
      List<CommentModel> commentsFiltered = [];

      pictures.forEach((picture) {
        if (markerBd.pictures!
            .where((element) => element.id == picture.id)
            .isEmpty) {
          picturesFiltered.add(picture);
        }
      });

      comments.forEach((comment) {
        if (markerBd.comments!
            .where((element) => element.id == comment.id)
            .isEmpty) {
          commentsFiltered.add(comment);
        }
      });

      await _localStorage.updateMarker(
          idMarker: id,
          newComments: commentsFiltered,
          newPictures: picturesFiltered);
    }
  }

  Future<void> deleteMarker(int id) async {
    await _localStorage.deleteMarker(id);
  }

  //detele comment
  Future<void> deleteComment({id, idMarker}) async {
    await _localStorage.deleteComment(id: id, idMarker: idMarker);
  }

  //detele picture
  Future<void> deletePicture({id, idMarker}) async {
    await _localStorage.deletePicture(id: id, idMarker: idMarker);
  }
}
