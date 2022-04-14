import 'package:makers_map/data/models/comment_model.dart';
import 'package:makers_map/data/models/picture_model.dart';

class MarkerModel {
  MarkerModel({
    this.id,
    this.pictures,
    this.comments,
    this.latitude,
    this.longitude,
  });

  final int? id;
  final List<PictureModel>? pictures;
  final List<CommentModel>? comments;
  final double? latitude;
  final double? longitude;

  Map<String, dynamic> toMap({withOutValues = const <String>[]}) {
    Map<String, dynamic> map = {
      'id': id,
      'pictures': pictures,
      'comments': comments,
      'latitude': latitude,
      'longitude': longitude,
    };
    map.removeWhere((key, value) => withOutValues.contains(key));
    return map;
  }

  factory MarkerModel.fromMap(Map<String, dynamic> map) {
    return MarkerModel(
      id: map['id'],
      pictures: map['pictures'],
      comments: map['comments'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }

  @override
  String toString() {
    return '{id: $id, pictures: $pictures, comments: $comments, latitude: $latitude, longitude: $longitude}';
  }
}
