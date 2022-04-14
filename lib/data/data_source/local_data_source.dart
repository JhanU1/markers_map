import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/comment_model.dart';
import '../models/marker_model.dart';
import '../models/picture_model.dart';

class LocalDataSource {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  initDatabase() async {
    String path = join(await getDatabasesPath(), 'database.db');
    print(path);
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    print("Creating tables");
    await db.execute(
        'CREATE TABLE markers(id INTEGER PRIMARY KEY AUTOINCREMENT, latitude REAL, longitude REAL)');
    await db.execute(
        'CREATE TABLE comments(id INTEGER PRIMARY KEY AUTOINCREMENT, id_marker INTERGER, title TEXT, comment TEXT, FOREIGN KEY (id_marker) REFERENCES markers(id))');
    await db.execute(
        'CREATE TABLE pictures(id INTEGER PRIMARY KEY AUTOINCREMENT, id_marker INTERGER, picture TEXT, FOREIGN KEY (id_marker) REFERENCES markers(id)) ');
  }

  Future<int?> addMarker(MarkerModel markerModel) async {
    final db = await database;
    var batch = db.batch();
    int idMarke = -1;
    idMarke = await db.transaction((txn) async {
      int idMarke = await txn.insert(
        'markers',
        markerModel.toMap(withOutValues: ['id', 'pictures', 'comments']),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return Future.value(idMarke);
    });

    if (idMarke != -1) {
      markerModel.pictures?.forEach((picture) {
        batch.insert(
          'pictures',
          {'id_marker': idMarke, 'picture': picture.pictureString},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
      markerModel.comments?.forEach((comment) {
        batch.insert(
          'comments',
          {
            'id_marker': idMarke,
            'comment': comment.comment,
            "title": comment.title
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
      await batch.commit(noResult: true);
      return idMarke;
    }
  }

  Future<MarkerModel?> getMarker(int id) async {
    final db = await database;

    var batch = db.batch();

    batch.query('markers', where: "id = ?", whereArgs: [id]);

    batch.query('pictures', where: "id_marker = ?", whereArgs: [id]);

    batch.query('comments', where: "id_marker = ?", whereArgs: [id]);

    List result = await batch.commit(noResult: false);
    if (result[0].isNotEmpty) {
      final pictures = result[1];
      final comments = result[2];
      Map<String, dynamic> map = {
        "pictures":
            pictures.map<PictureModel>((e) => PictureModel.fromMap(e)).toList(),
        "comments":
            comments.map<CommentModel>((e) => CommentModel.fromMap(e)).toList(),
        "latitude": result[0].first['latitude'],
        "longitude": result[0].first['longitude'],
        "id": result[0].first['id']
      };
      return Future.value(MarkerModel.fromMap(map));
    }
    return Future.error('Error');
  }

  Future getMarkers() async {
    final db = await database;
    List<MarkerModel> markersList = [];
    List<Map<String, Object?>>? markers;
    await db.transaction((txn) async {
      markers = await txn.query('markers');
    });
    var batch = db.batch();
    if (markers != null) {
      for (var marker in markers!) {
        batch.query('markers', where: "id = ?", whereArgs: [marker["id"]]);

        batch.query('pictures',
            where: "id_marker = ?", whereArgs: [marker["id"]]);

        batch.query('comments',
            where: "id_marker = ?", whereArgs: [marker["id"]]);
      }
      List result = await batch.commit(noResult: false);

      final countD = result.length / 3;
      int coint = countD.toInt();
      if (coint >= 1) {
        for (var i = 0; i < coint; i++) {
          final pictures = result[i * 3 + 1];
          final comments = result[i * 3 + 2];
          Map<String, dynamic> map = {
            "pictures": pictures
                .map<PictureModel>((e) => PictureModel.fromMap(e))
                .toList(),
            "comments": comments
                .map<CommentModel>((e) => CommentModel.fromMap(e))
                .toList(),
            "latitude": result[i * 3][0]['latitude'],
            "longitude": result[i * 3][0]['longitude'],
            "id": result[i * 3][0]['id']
          };

          markersList.add(MarkerModel.fromMap(map));
        }
      }
      return markersList;
    }

    return markersList;
  }

  Future<void> updateMarker(
      {idMarker, newComments = const [], newPictures = const []}) async {
    final db = await database;
    var batch = db.batch();
    List<Map<String, Object?>>? markers;
    await db.transaction((txn) async {
      markers = await txn.query('markers');
    });
    if (markers != null) {
      if (newPictures.isNotEmpty) {
        newPictures.forEach((picture) {
          batch.insert(
            'pictures',
            {'id_marker': idMarker, 'picture': picture.pictureString},
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        });
      }
      if (newComments.isNotEmpty) {
        newComments.forEach((comment) {
          batch.insert(
            'comments',
            {
              'id_marker': idMarker,
              'comment': comment.comment,
              "title": comment.title
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        });
      }
      await batch.commit(noResult: true);
    }
  }

  Future<void> addComment(CommentModel commentModel) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert(
        'comments',
        commentModel.toMap(withOutValues: ['id']),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<void> addPicture(PictureModel pictureModel) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert(
        'pictures',
        pictureModel.toMap(withOutValues: ['id']),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<void> deleteBD() async {
    await deleteDatabase(join(await getDatabasesPath(), 'database.db'));
  }

  Future<void> deleteMarker(idMarker) async {
    Database db = await database;
    await db.transaction((txn) async {
      await txn.delete('markers', where: "id = ?", whereArgs: [idMarker]);
      await txn
          .delete('comments', where: "id_marker = ?", whereArgs: [idMarker]);
      await txn
          .delete('pictures', where: "id_marker = ?", whereArgs: [idMarker]);
    });
  }

  Future<void> deleteComment({idMarker, id}) async {
    Database db = await database;
    await db.transaction((txn) async {
      await txn.delete('comments',
          where: "id_marker = ? AND id = ?", whereArgs: [idMarker, id]);
    });
  }

  Future<void> deletePicture({idMarker, id}) async {
    Database db = await database;
    await db.transaction((txn) async {
      await txn.delete('pictures',
          where: "id_marker = ? AND id = ?", whereArgs: [idMarker, id]);
    });
  }
}
