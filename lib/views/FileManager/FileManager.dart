import 'package:flutter/material.dart';
import 'package:fds_retail_count/models/masterdata.dart';
import 'package:fds_retail_count/utils/FileUtils.dart';
import 'package:fds_retail_count/db/database.dart';
import 'dart:convert';
import 'package:fds_retail_count/utils/colors.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class FileManagerPage extends StatefulWidget {
  @override
  FileManagerPageState createState() => FileManagerPageState();
}

class FileManagerPageState extends State<FileManagerPage> {
  final logo = Hero(
    tag: 'hero',
    child: CircleAvatar(
      backgroundColor: Colors.transparent,
      radius: 48.0,
      child: Image.asset('assets/logo.png'),
    ),
  );

  final email = TextFormField(
    keyboardType: TextInputType.emailAddress,
    autofocus: false,
    initialValue: 'USERSAP',
    decoration: InputDecoration(
      hintText: 'User',
      contentPadding: EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 10.0),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
    ),
  );

  final password = TextFormField(
    autofocus: false,
    initialValue: 'some password',
    obscureText: true,
    decoration: InputDecoration(
      hintText: 'Password',
      contentPadding: EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 5.0),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
    ),
  );

  final loginButton = Padding(
    padding: EdgeInsets.symmetric(vertical: 10.0),
    child: RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      onPressed: () {
        print("Loggin!");
      },
      padding: EdgeInsets.fromLTRB(20.0, 2.0, 20.0, 10.0),
      color: Colors.lightBlueAccent,
      child: Text('Log In', style: TextStyle(color: Colors.white)),
    ),
  );


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: _logginSap(),
      floatingActionButton: _floatAction(),
      backgroundColor: AppColors.statusBarColor,
    );
  }

  _logginSap() {
    return Center(
      child: ListView(
        //shrinkWrap: true,
        padding: EdgeInsets.only(top: 8.0, left: 24.0, right: 24.0),
        children: <Widget>[
          logo,
          SizedBox(height: 20.0),
          email,
          SizedBox(height: 8.0),
          password,
          SizedBox(height: 24.0),
          loginButton,

        ],
      ),
    );
  }

  _floatAction() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22.0),
      // this is ignored if animatedIcon is non null
      // child: Icon(Icons.add),
      //visible: _dialVisible,
      curve: Curves.bounceIn,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      onOpen: () => print('OPENING DIAL'),
      onClose: () => print('DIAL CLOSED'),
      tooltip: 'Speed Dial',
      heroTag: 'speed-dial-hero-tag',
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 5.0,
      shape: CircleBorder(),
      children: [
        SpeedDialChild(
            child: Icon(Icons.file_upload),
            backgroundColor: Colors.red,
            label: 'Cargar TXT',
            //labelStyle: TextTheme(fontSize: 18.0),
            onTap: () => _import()),
        SpeedDialChild(
          child: Icon(Icons.file_download),
          backgroundColor: Colors.blue,
          label: 'Descargar TXT',
          //labelStyle: TextTheme(fontSize: 18.0),
          onTap: () => _export(),
        ),
      ],
    );
  }

  _import() {
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
