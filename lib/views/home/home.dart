import 'dart:ui';

import 'package:fds_retail_count/views/FileManager/FileManager.dart';
import 'package:fds_retail_count/views/detail/detail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fds_retail_count/utils/colors.dart';
import 'package:fds_retail_count/models/zona.dart';
import 'package:fds_retail_count/models/masterdata.dart';
import 'package:date_format/date_format.dart';
import 'package:fds_retail_count/views/form/form.dart';
import 'package:fds_retail_count/db/database.dart';
import 'package:fds_retail_count/views/FileManager/FileManager.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final zoneNameController = TextEditingController();
  final List<String> log = <String>[];
  List<Zona_Field> selectedZona;
  @override
  void initState() {
    super.initState();
    _getAllZonas();
    selectedZona = [];
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    zoneNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App count FDS '),
        backgroundColor: AppColors.primaryColor,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FileManagerPage()),
                );
              }),
        ],
      ),
      //body: _buildTableControll(),
      body: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 1, 12, 3),
          child: inputFieldName(),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: ButtonBars(),
        ),
        Expanded(
          flex: 1,
          child: FutureBuilder<List<Zona_Field>>(
            //we call the method, which is in the folder db file database.dart
            future: DatabaseProvider.db.getAllZona(),
            builder: (BuildContext context,
                AsyncSnapshot<List<Zona_Field>> snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  physics: BouncingScrollPhysics(),
                  //Count all records
                  itemCount: snapshot.data.length,
                  //all the records that are in the client table are passed to an item Client item = snapshot.data [index];
                  itemBuilder: (BuildContext context, int index) {
                    Zona_Field item = snapshot.data[index];
                    //delete one register for id

                    return Dismissible(
                      //TRANSFROMAR EN FUNCIÓN
                      key: UniqueKey(),
                      background: Container(color: Colors.red),
                      onDismissed: (diretion) {
                     // if (_confirmDismiss()== true){
                        DatabaseProvider.db
                            .deleteZonaWithIddate(item.zona, item.date);


                      },
                      child: Padding(
                        padding: EdgeInsets.only(left: 12, right: 12),
                        child: new Card(
                          child: ListTile(
                            title: Text(item.zona),
                            subtitle: Text(item.date),
                            leading: CircleAvatar(
                                child: Text(item.canti_count.toString())),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => DetailPage(
                                            namezone: item.zona,
                                            date: item.date,
                                          )));
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
          //new ListView(
          //children: ZonasCount.map(_buildItem).toList(),
        ),
        //_buildTableControll()),
      ]),
      backgroundColor: AppColors.statusBarColor,
    );
  }

  Future<bool> _confirmDismiss() async {
    bool val = null;
    final bool res = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm"),
          content: const Text("Are you sure you wish to delete this item?"),
          actions: <Widget>[
            FlatButton( child : Text ("Si") ,onPressed: () => ( { val = true , Navigator.of(context).pop() } )),
            FlatButton(child : Text ("No"),onPressed: () => ({ val = false , Navigator.of(context).pop() })),
          ],
        );
      },
    );
  }

  void onSelectedRowChanged({bool selected, Zona_Field zonasel}) {
    setState(() {
      if (selected) {
        selectedZona.add(zonasel);
      } else {
        selectedZona.remove(zonasel);
      }
    });
  }

  Widget _buildItem(Zona_Field zona) {
    print("Dentro de listado");
    print("Soy Zona : " + zona.zona);

    return Card(
      child: ListTile(
        title: new Text('Zona : ${zona.zona}'),
        subtitle: new Text('Fecha: ${zona.date}'),
        leading: new Icon(Icons.map),
        onTap: () {
          _getAllZonasId(zona.zona);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      DetailPage(namezone: zona.zona, date: zona.date)));
        },
      ),
    );
  }

  Widget _buildTable() {
    return DataTable(
      columns: zonaColumns
          .map(
            (String column) => DataColumn(
              label: Text(column),
              //onSort: (int columnIndex, bool ascending) => onSortColumn(
              //  columnIndex: columnIndex, ascending: ascending),
            ),
          )
          .toList(),
      rows: ZonasCount.map((Zona_Field zonas) => DataRow(
            selected: selectedZona.contains(zonas),
            onSelectChanged: (bool selected) =>
                onSelectedRowChanged(selected: selected, zonasel: zonas),
            cells: [
              DataCell(Text('${zonas.zona}')),
              DataCell(Text(_format(zonas.date))),
              DataCell(Text('${zonas.canti_count}')),
            ],
          )).toList(),
      sortColumnIndex: 0,
    );
  }

  String _format(String date) {
    //print(date);
    // print(date.substring(0,4));
    // print(date.substring(4,6));
    // print(date.substring(6,8));
    return date; //date.substring(1,4) + "-" + date.substring(4,2)  +  "-" + date.substring(6,2);
  }

  Widget inputFieldName() {
    return TextFormField(
      controller: zoneNameController,
      decoration: const InputDecoration(
        hintText: '¿Como se llamará la zona?',
        labelText: 'Nombre de Zona',
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );
  }

  // ignore: non_constant_identifier_names
  void _deleteSelectAll() {
    for (final i in selectedZona) {
      zonas.remove(i);
    }
    selectedZona = [];
  }

  Widget ButtonBars() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      //children: <Widget>[
      //ButtonBar(
      children: <Widget>[
        Expanded(
            flex: 5,
            child: new FlatButton(
              child: Text(
                'Eliminar todo',
                style: TextStyle(color: Colors.white),
              ),
              color: Colors.red,
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Alerta"),
                        content: Text("Se eliminaran todos los registros"),
                        actions: <Widget>[
                          FlatButton(
                              onPressed: DatabaseProvider.db.deleteAllZona(),
                              child: Text('OK')),
                          FlatButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('CANCEL')),
                        ],
                      );
                    });

                /** */
              },
            )),
        /* FlatButton(
              child: Text('Modificar'),
              color: Colors.blue,
              onPressed: () {
                if (selectedZona.length == 1) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              FormPage(namezone: selectedZona.first.name)));
                } else {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Alerta"),
                          content: Text("Solo se puede modificar 1 zona"),
                        );
                      });
                }
                /** */
              },
            ),*/
        Expanded(
            flex: 5,
            child: new FlatButton(
              child: Text(
                'Nuevo',
                style: TextStyle(color: Colors.white),
              ),
              color: Colors.green,
              onPressed: () {
                print("entre");
                if (zoneNameController.text.isEmpty) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Alerta"),
                          content: Text("Nombre de zona está vacio"),
                        );
                      });
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              FormPage(namezone: zoneNameController.text)));
                }
              },
            )),
      ],
      //  )
      //],
    );
  }

  void _getAllZonas() async {
    setState(() {
      ZonasCount.clear();
      if (selectedZona != null) selectedZona.clear();
      print("entre a traer zonas");
      final zonafield = DatabaseProvider.db.getAllZona();

      zonafield.then((res) {
        for (int i = 0; i < res.length; i++) {
          print(res[i].zona.toString() + "" + res[i].material.toString());
          ZonasCount.add(res[i]);
        }
      }).catchError((onError) {
        print('Caught $onError'); // Handle the error.
      });
    });
  }

  void _getAllZonasId(var id) {
    setState(() {
      ZonasCount.clear();

      final zonafield = DatabaseProvider.db.getZonaWithId(id);

      zonafield.then((res) {
        for (int i = 0; i < res.length; i++) {
          print(res[i].zona.toString() + "" + res[i].material.toString());
          ZonasCount.add(res[i]);
        }
      }).catchError((onError) {
        print('Caught $onError'); // Handle the error.
      });
    });
  }
}
