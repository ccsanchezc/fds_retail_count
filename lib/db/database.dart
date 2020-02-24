import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:fds_retail_count/models/masterdata.dart';
import 'package:fds_retail_count/models/zonasdb.dart';
import 'package:sqflite/sql.dart';
import 'package:sqflite/sqlite_api.dart';

class DatabaseProvider {
  DatabaseProvider._();

  static final DatabaseProvider db = DatabaseProvider._();
  Database _database;

  //para evitar que abra varias conexciones una y otra vez podemos usar algo como esto..
  Future<Database> get database async {
    if (_database != null) return _database;
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
          "color TEXT,"
          "talla TEXT,"
          "bar_code TEXT,"
          "depto TEXT,"
          "mvgr1 TEXT,"
          "cantidad TEXT)  ");
      await db.execute("CREATE TABLE Zona ("
          "zona varchar(18)  ,"
          "material varchar(18)   ,"
          "bar_code TEXT,"
          "name TEXT,"
          "canti_count int,"
          "date TEXT,"
          "PRIMARY KEY (zona, material)) ");
    });
  }

  //Query
  //muestra todos los clientes de la base de datos
  Future<List<Material_data>> getAllMaterial() async {
    final db = await database;
    var response = await db.query("Material");
    List<Material_data> list =
        response.map((c) => Material_data.fromMap(c)).toList();
    return list;
  }

  //Query
  //muestra un solo cliente por el id la base de datos
  Future<Material_data> getMaterialWithId(var id) async {
    final db = await database;
    var response =
        await db.query("Material", where: "material = ?", whereArgs: [id]);
    return response.isNotEmpty ? Material_data.fromMap(response.first) : null;
  }

  Future<Material_data> getMaterialBarCodeWithId(var id) async {
    final db = await database;
    var response =
        await db.query("Material", where: "bar_code = ?", whereArgs: [id]);
    return response.isNotEmpty ? Material_data.fromMap(response.first) : null;
  }

  //Insert
  addMaterialToDatabase(Material_data material) async {
    final db = await database;
    //var table = await db.rawQuery("SELECT MAX(material)+1 as material FROM Material");
    //int id = table.first["material"];
    //material.material = id;

    var raw = await db.insert(
      "Material",
      material.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("sali");
    print(raw);
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
  updateMaterial(Material_data material) async {
    final db = await database;
    var response = await db.update("Material", material.toMap(),
        where: "material = ?", whereArgs: [material.material]);
    return response;
  }

// INICIO DE ZONAS DB
  //Query
  //muestra todos los clientes de la base de datos
  Future<List<Zona_Field>> getAllZona() async {
    final db = await database;
    var response = await db.query("Zona");
    List<Zona_Field> list = response.map((c) => Zona_Field.fromMap(c)).toList();
    return list;
  }

  //Query
  //muestra un solo cliente por el id la base de datos
  Future<Zona_Field> getZonaWithId(int id) async {
    final db = await database;
    var response = await db.query("Zona", where: "zona = ?", whereArgs: [id]);
    return response.isNotEmpty ? Zona_Field.fromMap(response.first) : null;
  }

  Future<Zona_Field> getZonaWithIdMaterial(var id, var mat) async {
    final db = await database;
    var response = await db.query("Zona",
        where: "zona = ? and material = ?", whereArgs: [id, mat]);
    return response.isNotEmpty ? Zona_Field.fromMap(response.first) : null;
  }

  //Insert
  addZonaToDatabase(Zona_Field material) async {
    final db = await database;
    var promise =
        getZonaWithIdMaterial("" + material.zona, "" + material.material);
    promise.then((res) {
      print("agregando");

      if (res != null) {
        print("existe");

        res.canti_count = material.canti_count + res.canti_count;

        return updateZona(res);
      } else {
        print("nuevo");

        var raw = db.insert(
          "Zona",
          material.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        return raw;
      }
    }).catchError((onError) {
      print('Caught $onError'); // Handle the error.
    });
  }

  //Delete
  //Delete client with id
  deleteZonaWithId(int id) async {
    final db = await database;
    return db.delete("Zona", where: "zona = ?", whereArgs: [id]);
  }

  //Delete all clients
  deleteAllZona() async {
    final db = await database;
    db.delete("Zona");
  }

  //Update
  updateZona(Zona_Field zona) async {
    final db = await database;
    var response = await db.update("Zona", zona.toMap(),
        where: "zona = ? and  material = ?", whereArgs: [zona.zona, zona.material]);
    return response;
  }
}
