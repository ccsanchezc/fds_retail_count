import 'dart:math';

import 'package:fds_retail_count/models/masterdata.dart';
import 'package:flutter/material.dart';
import 'package:fds_retail_count/utils/colors.dart';
import 'package:fds_retail_count/models/masterdata.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/services.dart';
import 'package:fds_retail_count/db/database.dart';

class FormPage extends StatefulWidget {
  String namezone;

  FormPage({Key key, @required this.namezone}) : super(key: key);
  @override
  FormPageState createState() => FormPageState(this.namezone);
}

class FormPageState extends State<FormPage> {
  final material = new TextEditingController();
  final name = new TextEditingController();
  final color = new TextEditingController();
  final talla = new TextEditingController();
  final bar_code = new TextEditingController();
  final depto = new TextEditingController();
  final mvgr1 = new TextEditingController();
  final cantidad = new TextEditingController();

  String namezone;
  Material_data materialinfo = new Material_data();
  FormPageState(this.namezone);
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<String> _colors = <String>['', 'red', 'green', 'blue', 'orange'];
  String _color = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Nueva zona : ' + this.namezone),
        backgroundColor: AppColors.primaryColor,
      ),
      //body: _buildTableControll(),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Expanded(flex: 8, child: FormBuilder()),
        ]),
      ),

      backgroundColor: AppColors.statusBarColor,
    );
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
            controller: this.bar_code,
            onChanged: (value) {
              if (value.length > 0) {
                var promise =
                    DatabaseProvider.db.getMaterialBarCodeWithId(value);
                promise.then((res) {
                  this.materialinfo = res;
                  _updatecontroller();
                  print(res.toString());
                }).catchError((onError) {
                  _clearcontroller();
                  print('Caught $onError'); // Handle the error.
                });
              }
            },
            validator: (value) =>
                value.isEmpty ? 'Codigo de barras requerido' : null,
            keyboardType: TextInputType.number,
          ),
          new TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.extension),
              hintText: 'Material',
              labelText: 'Material',
            ),
            controller: this.material,
            onChanged: (value) {
              if (value.length > 0) {
                var promise = DatabaseProvider.db.getMaterialWithId(value);
                promise.then((res) {
                  this.materialinfo = res;
                  _updatecontroller();
                }).catchError((onError) {
                  _clearcontroller();
                  print('Caught $onError'); // Handle the error.
                });
              }
            },
            validator: (value) => value.isEmpty ? 'Material requerido' : null,
            keyboardType: TextInputType.number,
            inputFormatters: [
              WhitelistingTextInputFormatter.digitsOnly,
            ],
          ),
          new TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.text_fields),
              hintText: 'Nombre del material',
              labelText: 'Nombre del material',
            ),
            controller: this.name,
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
            controller: this.color,
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
            controller: this.talla,
            enabled: false,
            keyboardType: TextInputType.number,
          ),
          new TextFormField(
            decoration: const InputDecoration(
              icon: const Icon(Icons.equalizer),
              hintText: 'Cantidad',
              labelText: 'Cantidad',
            ),
            onSaved: (value) {
              this.materialinfo.cantidad = value;
            },
            controller: this.cantidad,
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

  void _clearcontroller() {
    //this.material.text  = "";
    this.name.text = "";
    this.color.text = "";
    this.talla.text = "";
    //this.bar_code.text = "";
    this.depto.text = "";
    this.mvgr1.text = "";
    this.cantidad.text = "";
  }

  void _updatecontroller() {
    this.material.text = this.materialinfo.material;
    this.name.text = this.materialinfo.name;
    this.color.text = this.materialinfo.color;
    this.talla.text = this.materialinfo.talla;
    this.bar_code.text = this.materialinfo.bar_code;
    this.depto.text = this.materialinfo.depto;
    this.mvgr1.text = this.materialinfo.mvgr1;
    this.cantidad.text = this.materialinfo.cantidad;
  }

  void _submitForm() {
    final FormState form = _formKey.currentState;

    if (!form.validate()) {
      showMessage('Algo fallo!  Por favor revisar y corregir.');
    } else {
      form.save(); //This invokes each onSaved event

      var now = new DateTime.now();
      String fecha = formatDate(
          DateTime(now.year, now.month, now.day), [yyyy, '-', mm, '-', dd]);
      DatabaseProvider.db.addZonaToDatabase(new Zona_Field(
          zona: this.namezone,
          bar_code: this.materialinfo.bar_code,
          material: this.materialinfo.material,
          name: this.materialinfo.name,
          canti_count: int.parse(this.materialinfo.cantidad),
          date:""+  fecha ));


      form.reset();
      Navigator.pop(context);

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

  void showMessage(String message, [MaterialColor color = Colors.red]) {
    _scaffoldKey.currentState.showSnackBar(
        new SnackBar(backgroundColor: color, content: new Text(message)));
  }
}
