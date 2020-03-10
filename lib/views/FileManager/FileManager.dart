import 'package:flutter/material.dart';
import 'package:fds_retail_count/models/masterdata.dart';
import 'package:fds_retail_count/utils/FileUtils.dart';
import 'package:fds_retail_count/db/database.dart';
import 'dart:convert';

class FileManagerPage extends StatefulWidget {
  @override
  FileManagerPageState createState() => FileManagerPageState();
}

class FileManagerPageState extends State<FileManagerPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.add)),
                Tab(icon: Icon(Icons.storage))
              ],
            ),
            title: Text('Configuración'),
          ),
          body: TabBarView(
            children: [
              FilesManager(),
              Text("Conexión SAP..."),
            ],
          ),
        ),
      ),
    );
  }

  Widget FilesManager() {
    return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      Expanded(
        flex: 1,
        child: FlatButton(
          color: Colors.blue,
          textColor: Colors.white,
          disabledColor: Colors.grey,
          disabledTextColor: Colors.black,
          padding: EdgeInsets.all(8.0),
          splashColor: Colors.blueAccent,
          onPressed: () {
            final promise = FileUtils.readFromFile();
            promise.then((res) {
              _format(res);
              return showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Alerta"),
                      content: Text("Se cargo correctamente el archivo"),
                    );
                  });
            }).catchError((onError) {
              print('Caught $onError'); // Handle the error.
            });
          },
          child: Text(
            "Cargar TXT",
            style: TextStyle(fontSize: 20.0),
          ),
        ),
      ),
      Expanded(
        flex: 1,
        child: FlatButton(
          color: Colors.green,
          textColor: Colors.white,
          disabledColor: Colors.grey,
          disabledTextColor: Colors.black,
          padding: EdgeInsets.all(8.0),
          splashColor: Colors.blueAccent,
          onPressed: () {
            _export();
          },
          child: Text(
            "Descargar TXT",
            style: TextStyle(fontSize: 20.0),
          ),
        ),
      ),
      Expanded(
        flex: 8,
        child: Text(
          "",
          style: TextStyle(fontSize: 20.0),
        ),
      ),
    ]);
  }

  _export() {
    print("entre a funcion _export()");
    final _barcode = DatabaseProvider.db.getZonaBarcodeCount();
    String export = "";

    _barcode.then((res) {
      print("tamaño");
      print(res.length);
      for (int i = 0; i < res.length; i++) {
        if (i == res.length - 1) {
          export = export +
              res[i].bar_code +
              ";" +
              res[i].canti_count.toString() +
              '';
        } else {
          export = export +
              res[i].bar_code +
              ";" +
              res[i].canti_count.toString() +
              '\n';
        }
      }

      final promise = FileUtils.saveToFile(export);
      promise.then((res) {
        return showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Alerta"),
                content: Text("Se descargo correctamente el archivo"),
              );
            });
      }).catchError((onError) {
        print('Caught $onError'); // Handle the error.
      });
    }).catchError((onError) {
      print('Caught $onError'); // Handle the error.
    });
  }

  _format(String valor) {
    List<String> mate = valor.split("\r\n");
    String json_input = "{";
    DatabaseProvider.db.deleteAllMaterial();
    for (var name in mate) {
      List<String> matefinal = name.split("\t").toList();

      for (int i = 0; i < matefinal.length; i++) {
        if (i == matefinal.length - 1) {
          json_input = json_input +
              '"' +
              Material_model[i].toString() +
              '"' +
              ":" +
              '"' +
              matefinal[i] +
              '"';
        } else {
          json_input = json_input +
              '"' +
              Material_model[i].toString() +
              '"' +
              ":" +
              '"' +
              matefinal[i] +
              '"' +
              ",";
        }
      }
      json_input = json_input + "}";

      Map userMap = jsonDecode(json_input);
      var user = Material_data.fromMap(userMap).toMap();
      user["cantidad"] = user["cantidad"].toString().split(".")[0];
      print(user);
      DatabaseProvider.db.addMaterialToDatabase(new Material_data(
          material: user["material"],
          name: user["name"],
          color: user["color"],
          talla: user["talla"],
          bar_code: user["bar_code"],
          depto: user["depto"],
          mvgr1: user["mvgr1"],
          cantidad: user["cantidad"]));
      json_input = "{";
    }
  }

  showMessage(String message) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Alerta"),
            content: Text("Nombre de zona está vacio"),
          );
        });
    ;
  }
}
