import 'package:flutter/material.dart';
import 'package:fds_retail_count/models/masterdata.dart';
import 'package:fds_retail_count/utils/FileUtils.dart';
import 'package:fds_retail_count/db/database.dart';
import 'dart:convert';
import 'package:fds_retail_count/utils/colors.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fds_retail_count/auth/auth.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  static final _usernameController = TextEditingController();
  static final _passController = TextEditingController();
  Auth auth = new Auth();
  AnimationController controller;
  Animation<double> animation;

  GlobalKey<FormState> _key = GlobalKey();

  String _correo;
  String _contrasena;
  String mensaje = '';
  bool _set = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: _logginSap(),
      backgroundColor: AppColors.statusBarColor,
    );
  }

  final logo = Hero(
    tag: 'hero',
    child: CircleAvatar(
      backgroundColor: Colors.transparent,
      radius: 48.0,
      child: Image.asset('assets/logo.png'),
    ),
  );

  _logginSap() {
    return Center(
      child: ListView(
        //shrinkWrap: true,
        padding: EdgeInsets.only(top: 8.0, left: 24.0, right: 24.0),
        children: <Widget>[logo, SizedBox(height: 20.0), loginForm()],
      ),
    );
  }

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
                    hintText: 'Ingrese Correo',
                    labelText: 'Ingrese Correo',
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
                  obscureText: true,
                  onSaved: (text) => _contrasena = text,
                ),
                IconButton(
                  onPressed: () async {
                    if (_key.currentState.validate()) {
                      var valui;

                      _key.currentState.save();

                      try {
                        valui = await auth.signIn(_correo, _contrasena);
                        _set = true;
                      } catch (error) {
                        _set = false;
                        switch (error.code) {
                          case "ERROR_USER_NOT_FOUND":
                            {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: Container(
                                        child: Text("Usuario no Encontrado"),
                                      ),
                                    );
                                  });
                            }
                            break;
                          case "ERROR_INVALID_EMAIL":
                            {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: Container(
                                        child: Text("Correo invalido"),
                                      ),
                                    );
                                  });
                            }
                            break;
                          case "ERROR_WRONG_PASSWORD":
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    content: Container(
                                      child: Text("Contraseña incorrecta"),
                                    ),
                                  );
                                });

                            break;
                        }
                      }
                      if (valui != null && _set == true) {
                        Navigator.pop(context, valui);
                      }
//
                    }
                  },
                  icon: Icon(
                    Icons.assignment_turned_in,
                    size: 42.0,
                    color: Colors.blue[800],
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    if (_key.currentState.validate()) {
                      _key.currentState.save();
                      //Aqui se llamaria a su API para hacer el login
                      var valui = await auth.signUp(_correo, _contrasena);
                      if (valui != null) {
                        Navigator.pop(context, valui);
                      }
                    }
                  },
                  icon: Icon(
                    Icons.note_add,
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
}
