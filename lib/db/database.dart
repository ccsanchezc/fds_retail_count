import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:fds_retail_count/models/masterdata.dart';
import 'package:fds_retail_count/models/zonasdb.dart';
import 'package:sqflite/sql.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:fds_retail_count/db/firestore.dart'; //firestore
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseProvider {
  DatabaseProvider._();

  static final DatabaseProvider db = DatabaseProvider._();
  Database _database;
  List<Zona_Field> listg = new List<Zona_Field>();

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
    final fire = await Api("material");
    //var table = await db.rawQuery("SELECT MAX(material)+1 as material FROM Material");
    //int id = table.first["material"];
    //material.material = id;
    var raw = await db.insert(
      "Material",
      material.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    fire.ref.document(material.material).setData(material.toMap());

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
    final fire = await Api("zona");
    Future<List<Zona_Field>>  list2 =  null;
    List<Zona_Field> list = null;
    List<String> liss = new List<String>();
    var response = await db.rawQuery(
        'SELECT zona,date, SUM(canti_count) as canti_count from ZONA GROUP BY zona,date');
    print("voy a traer documentos");
    final QuerySnapshot result = await fire.ref.getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
     documents.map((data) =>  liss.add(data.documentID)).toList();
      list2 = getDocument(liss, fire);

    return list2;
  }

  Future<List<Zona_Field>> getDocument(List<String> resulta, Api fire) async {
    listg =  new  List<Zona_Field>();
    List<Zona_Field> list = new  List<Zona_Field>();
    for(int i=0 ; i < resulta.length;i++ ){
      final QuerySnapshot result =
      await fire.ref.document(resulta[i]).collection("material").getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
      documents.map((data) => list.add(Zona_Field.fromMap(data.data))).toList();
    }


    return  list;
  }

  //Query
  //muestra un solo cliente por el id la base de datos
  Future<List<Zona_Field>> getZonaWithId(var id) async {
    final db = await database;
    var response = await db.query("Zona ", where: "zona = ?", whereArgs: [id]);
    List<Zona_Field> list = response.map((c) => Zona_Field.fromMap(c)).toList();

    return list;
  }

  Future<List<Zona_Field>> getZonaWithIddate(var id, var date) async {
    final db = await database;
    print("entre a traer cosas");
    print("ID" + id + "Date" + date);
    var response = await db
        .query("Zona ", where: "zona = ? and date = ?", whereArgs: [id, date]);

    print(response);
    List<Zona_Field> list = response.map((c) => Zona_Field.fromMap(c)).toList();
    return list;
  }

  Future<Zona_Field> getZonaWithIdMaterial(var id, var mat) async {
    final db = await database;
    var response = await db.query("Zona",
        where: "zona = ? and material = ?", whereArgs: [id, mat]);
    return response.isNotEmpty ? Zona_Field.fromMap(response.first) : null;
  }

  Future<List<Zona_Field>> getZonaBarcodeCount() async {
    final db = await database;

    var response = await db.rawQuery(
        'SELECT bar_code , SUM(canti_count) as canti_count from ZONA GROUP BY bar_code');

    List<Zona_Field> list = response.map((c) => Zona_Field.fromMap(c)).toList();
    //print(list);
    return list;
  }

  //Insert
  addZonaToDatabase(Zona_Field material) async {
    final db = await database;
    final fire = Api("zona");
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
        fire.ref
            .document(material.zona)
            .collection("material")
            .document(material.material)
            .setData(material.toMap());
        fire.ref.document(material.zona).setData({'zona': '${material.zona}'});
        //fire.ref.document(material.zona).setData(material.toMap());

        return raw;
      }
    }).catchError((onError) {
      print('Caught $onError'); // Handle the error.
    });
  }

  //Delete
  //Delete client with id
  deleteZonaWithId(var id) async {
    final db = await database;
    final fire = await Api("zona");
    fire.ref.document(id).collection("material").where("zona", isEqualTo: id);
    return db.delete("Zona", where: "zona = ?", whereArgs: [id]);
  }

  deleteZonaWithIddate(var id, var date) async {
    final db = await database;
    final fire = await Api("zona");
    print("Eliminar " + id);
    var finla = fire.ref.document(id).collection("material").where("zona", isEqualTo: id);
    await fire.ref.document(id).delete();

    return db
        .delete("Zona", where: "zona = ? and date = ?", whereArgs: [id, date]);
  }

  deleteZonaWithIdMat(var id, var date, var mat) async {
    final db = await database;
    final fire = await Api("zona");
    fire.ref.document(id).collection("material").document(mat).delete();
    fire.ref.document(id).delete();
    return db.delete("Zona",
        where: "zona = ? and material = ? and date = ?",
        whereArgs: [id, mat, date]);
  }

  //Delete all clients
  deleteAllZona() async {
    final db = await database;
    db.delete("Zona");
  }

  //Update
  updateZona(Zona_Field zona) async {
    final db = await database;
    final fire = await Api("zona");

    var response = await db.update("Zona", zona.toMap(),
        where: "zona = ? and  material = ?",
        whereArgs: [zona.zona, zona.material]);

    var document = await fire.ref
        .document(zona.zona)
        .collection("material")
        .document(zona.material);
    document.get().then((datasnapshot) {
      if (datasnapshot.exists) {
        fire.ref
            .document(zona.zona)
            .collection("material")
            .document(zona.material)
            .updateData(zona.toMap());
      } else {
        print("No such user");
      }
    });

    return response;
  }
}
