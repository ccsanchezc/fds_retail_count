import 'package:flutter/material.dart';
import 'package:fds_retail_count/utils/colors.dart';
import 'package:fds_retail_count/models/zona.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/services.dart';

class FileManager extends StatefulWidget {
  String namezone;
  FileManager({Key key, @required this.namezone}) : super(key: key);
  @override
  FileManagerState createState() => FileManagerState(this.namezone);
}

class FileManagerState extends State<FileManager> {
  String namezone;
  FileManagerState(this.namezone);
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Custom FILE ' ),
        backgroundColor: AppColors.primaryColor,
      ),
      //body: _buildTableControll(),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Expanded(
            flex: 1,
            child: Text("Soy 1"),
          ),
          Expanded(
            flex: 1,
            child: Text("Soy 2"),
          ),
         // Expanded(flex: 8, child: FormBuilder()),
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

  void showMessage(String message, [MaterialColor color = Colors.red]) {
    _scaffoldKey.currentState.showSnackBar(
        new SnackBar(backgroundColor: color, content: new Text(message)));
  }
}
