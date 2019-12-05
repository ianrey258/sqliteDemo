import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'data.dart';

class DBHelper{
  static Database _db;
  static const String ID = 'id';
  static const String TITLE = 'title';
  static const String ACTIVITY = 'activity';
  static const String DATETIME = 'datetime';
  static const String TABLE = 'Data';
  static const String DB_NAME = 'data.db';

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }
 
  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }
 
  _onCreate(Database db, int version) async {
    await db
        .execute("CREATE TABLE $TABLE ($ID INTEGER PRIMARY KEY, $TITLE TEXT,$ACTIVITY TEXT,$DATETIME TEXT)");
  }

  Future<List<Data>> getDatas() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(TABLE, columns: [ID,TITLE,ACTIVITY,DATETIME]);
    List<Data> datas = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        datas.add(Data.fromMap(maps[i]));
      }
    }
    return datas;
  }

  Future<Data> insert(Data data) async {
    var dbClient = await db;
    data.id = await dbClient.insert(TABLE, data.toMap());
    return data;
  }

  Future<int> update(Data data) async {
    var dbClient = await db;
    return await dbClient.update(TABLE, data.toMap(),
        where: '$ID = ?', whereArgs: [data.id]);
  }

  Future<int> delete(int id) async {
    var dbClient = await db;
    return await dbClient.delete(TABLE, where: '$ID = ?', whereArgs: [id]);
  }
 
  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }

}