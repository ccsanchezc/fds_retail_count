import 'package:fds_retail_count/views/FileManager/FileManager.dart';
import 'package:fds_retail_count/views/detail/detail.dart';
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
        Expanded(
          flex: 1,
          child: inputFieldName(),
        ),
        Expanded(
          flex: 1,
          child: ButtonBars(),
        ),
        Expanded(
          flex: 8,
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
                      key: UniqueKey(),
                      background: Container(color: Colors.red),
                      onDismissed: (diretion) {
                        DatabaseProvider.db
                            .deleteZonaWithIddate(item.zona, item.date);
                      },
                      //Now we paint the list with all the records, which will have a number, name, phone
                      child: Card(
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
                          //If we press one of the cards, it takes us to the page to edit, with the data onTap:
                          //This method is in the file add_editclient.dart
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

  Widget _buildTableControll() {
    final width = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: width * 1.4,
        child: ListView(
          children: <Widget>[
            _buildTable(),
          ],
        ),
      ),
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
      children: <Widget>[
        ButtonBar(
          children: <Widget>[
            FlatButton(
              child: Text('Eliminar todo'),
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
            ),
            FlatButton(
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
            ),
            FlatButton(
              child: Text('Nuevo'),
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
            ),
          ],
        )
      ],
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
