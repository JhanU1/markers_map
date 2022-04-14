class CommentModel {
  CommentModel({this.id, this.comment, this.makerId, this.title});

  final int? id;
  final String? comment;
  final int? makerId;
  final String? title;

  Map<String, dynamic> toMap({withOutValues = const <String>[]}) {
    Map<String, dynamic> map = {
      'id': id,
      'comment': comment,
      'id_marker': makerId,
      'title': title,
    };
    map.removeWhere((key, value) => withOutValues.contains(key));
    return map;
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'],
      comment: map['comment'],
      makerId: map['id_marker'],
      title: map['title'],
    );
  }

  @override
  String toString() {
    return '{id: $id, comment: $comment, makerId: $makerId, title: $title}';
  }
}
