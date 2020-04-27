import 'package:flutter/material.dart';
import 'package:fds_retail_count/models/masterdata.dart';
import 'package:fds_retail_count/utils/FileUtils.dart';
import 'package:fds_retail_count/db/database.dart';
import 'dart:convert';
import 'package:fds_retail_count/utils/colors.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fds_retail_count/db/firestore.dart';

class FileManagerPage extends StatefulWidget {
  @override
  FileManagerPageState createState() => FileManagerPageState();
}

class FileManagerPageState extends State<FileManagerPage>  with SingleTickerProviderStateMixin{
  static final _usernameController = TextEditingController();
  static final _passController = TextEditingController();

   AnimationController controller;
   Animation<double> animation ;

  GlobalKey<FormState> _key = GlobalKey();

  String _correo;
  String _contrasena;
  String mensaje = '';

  bool _logueado = false;
  initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);

    //    Descomentar las siguientes lineas para generar un efecto de "respiracion"
    animation.addStatusListener((status) {
       if (status == AnimationStatus.completed) {
         controller.reverse();
       } else if (status == AnimationStatus.dismissed) {
         controller.forward();
       }
     });

    controller.forward();
  }

  dispose() {
    // Es importante SIEMPRE realizar el dispose del controller.
    controller.dispose();
    super.dispose();
  }


  final logo = Hero(
    tag: 'hero',
    child: CircleAvatar(
      backgroundColor: Colors.transparent,
      radius: 48.0,
      child: Image.asset('assets/logo.png'),
    ),
  );
  Widget loginForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
           // AnimatedLogo(animation: animation),
          ],
        ),
        Container(
          width: 300.0, //size.width * .6,
          child: Form(
            key: _key,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _usernameController,
                  validator: (text) {
                    if (text.length == 0) {
                      return "Este campo correo es requerido";
                    }
                   //   return "El formato para correo no es correcto";
                  //  }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                  maxLength: 50,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'Ingrese su usuario SAP',
                    labelText: 'Usuario SAP',
                    counterText: '',
                    icon:
                    Icon(Icons.email, size: 32.0, color: Colors.blue[800]),
                  ),
                  onSaved: (text) => _correo = text,
                ),
                TextFormField(
                  validator: (text) {
                    if (text.length == 0) {
                      return "Este campo contraseña es requerido";
                    } else if (text.length <= 5) {
                      return "Su contraseña debe ser al menos de 5 caracteres";
                    } //else if (!contRegExp.hasMatch(text)) {
                    //  return "El formato para contraseña no es correcto";
                  //  }
                    return null;
                  },
                  controller: _passController,
                  keyboardType: TextInputType.text,
                  maxLength: 20,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'Ingrese su Contraseña',
                    labelText: 'Contraseña',
                    counterText: '',
                    icon: Icon(Icons.lock, size: 32.0, color: Colors.blue[800]),
                  ),
                  onSaved: (text) => _contrasena = text,
                ),
                IconButton(
                  onPressed: () {
                    if (_key.currentState.validate()) {
                      _key.currentState.save();
                      //Aqui se llamaria a su API para hacer el login
                      setState(() {
                        _logueado = true;
                      });
                      mensaje = 'Gracias \n $_correo \n $_contrasena';
//                      Una forma correcta de llamar a otra pantalla
//                      Navigator.of(context).push(HomeScreen.route(mensaje));
                    }
                  },
                  icon: Icon(
                    Icons.arrow_forward,
                    size: 42.0,
                    color: Colors.blue[800],
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
 /* final email = TextFormField(
    keyboardType: TextInputType.emailAddress,
    controller: _usernameController,
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
        print("Loggin!" + _usernameController.text);
      },
      padding: EdgeInsets.fromLTRB(20.0, 2.0, 20.0, 10.0),
      color: Colors.lightBlueAccent,
      child: Text('Log In', style: TextStyle(color: Colors.white)),
    ),
  );*/

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
          loginForm()
         // email,
          //SizedBox(height: 8.0),
          //password,
          //SizedBox(height: 24.0),
         //loginButton,

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
class AnimatedLogo extends AnimatedWidget {
  // Maneja los Tween estáticos debido a que estos no cambian.
  static final _opacityTween = Tween<double>(begin: 0.1, end: 1.0);
  static final _sizeTween = Tween<double>(begin: 0.0, end: 150.0);

  AnimatedLogo({Key key, Animation<double> animation})
      : super(key: key, listenable: animation);

  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    return Opacity(
      opacity: _opacityTween.evaluate(animation),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        height: _sizeTween.evaluate(animation), // Aumenta la altura
        width: _sizeTween.evaluate(animation), // Aumenta el ancho
        child: FlutterLogo(),
      ),
    );
  }
}