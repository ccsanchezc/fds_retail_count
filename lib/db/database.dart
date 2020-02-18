
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:fds_retail_count/models/masterdata.dart';
import 'package:fds_retail_count/models/zonasdb.dart';
import 'package:sqflite/sql.dart';
import 'package:sqflite/sqlite_api.dart';


class DatabaseProvider{
  DatabaseProvider._();

  static final  DatabaseProvider db = DatabaseProvider._();
  Database _database;

  //para evitar que abra varias conexciones una y otra vez podemos usar algo como esto..
  Future<Database> get database async {
    if(_database != null) return _database;
    _database = await getDatabaseInstanace();
    return _database;
  }

  Future<Database> getDatabaseInstanace() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, "data.db");
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute("CREATE TABLE Material ("
              "material varchar(18) primary key,"
              "name TEXT,"
              "color TEXT"
              "talla TEXT"
              "bar_code TEXT"
              "depto TEXT"
              "mvgr1 TEXT"
              "cantidad TEXT"
              );
        });
  }

  //Query
  //muestra todos los clientes de la base de datos
  Future<List<Material>> getAllMaterial() async {
    final db = await database;
    var response = await db.query("Material");
    List<Material> list = response.map((c) => Material.fromMap(c)).toList();
    return list;
  }

  //Query
  //muestra un solo cliente por el id la base de datos
  Future<Material> getMaterialWithId(int id) async {
    final db = await database;
    var response = await db.query("Material", where: "id = ?", whereArgs: [id]);
    return response.isNotEmpty ? Material.fromMap(response.first) : null;
  }

  //Insert
  addMaterialToDatabase(Material material) async {
    final db = await database;
    var table = await db.rawQuery("SELECT MAX(material)+1 as material FROM Material");
    int id = table.first["material"];
    material.material = id;
    var raw = await db.insert(
      "Material",
      material.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return raw;

  }

  //Delete
  //Delete client with id
  deleteMaterialWithId(int id) async {
    final db = await database;
    return db.delete("Material", where: "material = ?", whereArgs: [id]);
  }

  //Delete all clients
  deleteAllMaterial() async {
    final db = await database;
    db.delete("Material");
  }

  //Update
  updateMaterial(Material material) async {
    final db = await database;
    var response = await db.update("Material", material.toMap(),
        where: "material = ?", whereArgs: [material.material]);
    return response;
  }
  /*
// INICIO DE ZONAS DB
  //Query
  //muestra todos los clientes de la base de datos
  Future<List<Material>> getAllMaterial() async {
    final db = await database;
    var response = await db.query("Material");
    List<Material> list = response.map((c) => Material.fromMap(c)).toList();
    return list;
  }

  //Query
  //muestra un solo cliente por el id la base de datos
  Future<Material> getMaterialWithId(int id) async {
    final db = await database;
    var response = await db.query("Material", where: "id = ?", whereArgs: [id]);
    return response.isNotEmpty ? Material.fromMap(response.first) : null;
  }

  //Insert
  addMaterialToDatabase(Material material) async {
    final db = await database;
    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM Client");
    int id = table.first["id"];
    material.id = id;
    var raw = await db.insert(
      "Material",
      material.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return raw;

  }

  //Delete
  //Delete client with id
  deleteMaterialWithId(int id) async {
    final db = await database;
    return db.delete("Material", where: "id = ?", whereArgs: [id]);
  }

  //Delete all clients
  deleteAllMaterial() async {
    final db = await database;
    db.delete("Material");
  }

  //Update
  updateMaterial(Material material) async {
    final db = await database;
    var response = await db.update("Material", material.toMap(),
        where: "id = ?", whereArgs: [material.id]);
    return response;
  }
  
   */
}
