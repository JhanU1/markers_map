class PictureModel {
  PictureModel({
    this.id,
    this.pictureString,
    this.makerId,
  });

  final int? id;
  final String? pictureString;
  final int? makerId;

  Map<String, dynamic> toMap({withOutValues = const <String>[]}) {
    Map<String, dynamic> map = {
      'id': id,
      'picture': pictureString,
      'id_marker': makerId,
    };
    map.removeWhere((key, value) => withOutValues.contains(key));
    return map;
  }

  factory PictureModel.fromMap(Map<String, dynamic> map) {
    return PictureModel(
      id: map['id'],
      pictureString: map['picture'],
      makerId: map['id_marker'],
    );
  }

  @override
  String toString() {
    return '{id: $id, pictureString: $pictureString, makerId: $makerId}';
  }
}
