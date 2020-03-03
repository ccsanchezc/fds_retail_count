import 'package:flutter/material.dart';
import 'package:fds_retail_count/utils/colors.dart';
import 'package:fds_retail_count/models/masterdata.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/services.dart';
import 'package:fds_retail_count/utils/FileUtils.dart';
import 'package:fds_retail_count/db/database.dart';
import 'dart:convert';

class FileManagerPage extends StatefulWidget {
  @override
  FileManagerPageState createState() => FileManagerPageState();
}

class FileManagerPageState extends State<FileManagerPage> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

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
        flex: 5,
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
        flex: 5,
        child: FlatButton(
          color: Colors.green,
          textColor: Colors.white,
          disabledColor: Colors.grey,
          disabledTextColor: Colors.black,
          padding: EdgeInsets.all(8.0),
          splashColor: Colors.blueAccent,
          onPressed: () {
            final promise = FileUtils.saveToFile(_export());
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
          },
          child: Text(
            "Descargar TXT",
            style: TextStyle(fontSize: 20.0),
          ),
        ),
      )
    ]);
  }
  String _export(){
   final _barcode  = DatabaseProvider.db.getZonaBarcodeCount();
    String export ="";

    _barcode.then((res) {
      print("tamaño");
      print(res.length);
      for (int i = 0; i < res.length; i++) {
        print("Ejemplo:" + res[i].toMap().toString());
        if(i == res.length - 1 ){
          export = export + res[i].bar_code+ ";" + res[i].canti_count.toString()+ '' ;
        }else{
         export = export + res[i].bar_code+ ";" + res[i].canti_count.toString()+ '\n' ;
        }
      }
    }).catchError((onError) {
      print('Caught $onError'); // Handle the error.
    });
    return export;
  }
  _format(String valor) {
    List<String> mate = valor.split("\r\n");
    String json_input = "{";
    DatabaseProvider.db.deleteAllMaterial();
    for (var name in mate) {
      List<String> matefinal = name.split("\t").toList();

      for (int i = 0; i < matefinal.length; i++) {

        if(i == matefinal.length - 1 ){
          json_input = json_input + '"' +Material_model[i].toString()+'"' + ":"  +'"' + matefinal[i]+'"' ;
        }else{
          json_input = json_input + '"' +Material_model[i].toString()+'"' + ":"  +'"' + matefinal[i]+'"' + ",";
        }

      }
      json_input = json_input + "}" ;

      Map userMap = jsonDecode(json_input);
      var user = Material_data.fromMap(userMap).toMap();
      user["cantidad"] = user["cantidad"].toString().split(".")[0] ;
    print( user);
      DatabaseProvider.db.addMaterialToDatabase(new Material_data(material: user["material"],name:user["name"],color: user["color"],talla: user["talla"],
                                                                  bar_code: user["bar_code"],depto: user["depto"],mvgr1: user["mvgr1"],cantidad:user["cantidad"]));
      json_input = "{";
    }

  }

  Widget FormBuilder() {
    return Form(
      key: _formKey,
      autovalidate: true,
      child: new ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: <Widget>[
          new TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.view_week),
              hintText: 'Codigo de barras',
              labelText: 'Codigo de barras',
            ),
            validator: (value) =>
                value.isEmpty ? 'Codigo de barras requerido' : null,
            keyboardType: TextInputType.number,
            inputFormatters: [
              WhitelistingTextInputFormatter.digitsOnly,
            ],
          ),
          new TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.extension),
              hintText: 'Material',
              labelText: 'Material',
            ),
            validator: (value) => value.isEmpty ? 'Material requerido' : null,
            keyboardType: TextInputType.number,
          ),
          new TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.text_fields),
              hintText: 'Nombre del material',
              labelText: 'Nombre del material',
            ),
            validator: (value) =>
                value.isEmpty ? 'Nombre Material requerido' : null,
            keyboardType: TextInputType.text,
          ),
          new TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.color_lens),
              hintText: 'Color',
              labelText: 'Color',
            ),
            //validator: (value) => value.isEmpty ? 'Color' : null,
            keyboardType: TextInputType.number,
            enabled: false,
            inputFormatters: [
              WhitelistingTextInputFormatter.digitsOnly,
            ],
          ),
          new TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.memory),
              hintText: 'Talla',
              labelText: 'Talla',
            ),
            enabled: false,
            keyboardType: TextInputType.number,
          ),
          new TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.equalizer),
              hintText: 'Cantidad',
              labelText: 'Cantidad',
            ),
            keyboardType: TextInputType.number,
          ),
          new Container(
              padding: const EdgeInsets.only(left: 40.0, top: 20.0),
              child: new RaisedButton(
                child: const Text('Submit'),
                onPressed: _submitForm,
              )),
        ],
      ),
    );
  }

  void _submitForm() {
    final FormState form = _formKey.currentState;

    if (!form.validate()) {
      showMessage('Algo fallo!  Por favor revisar y corregir.');
    } else {
      form.save(); //This invokes each onSaved event

      print('Form save called, newContact is now up to date...');
      /*print('Email: ${newContact.name}');
      print('Dob: ${newContact.dob}');
      print('Phone: ${newContact.phone}');
      print('Email: ${newContact.email}');
      print('Favorite Color: ${newContact.favoriteColor}');*/
      print('========================================');
      print('Submitting to back end...');
      print('TODO - we will write the submission part next...');
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
