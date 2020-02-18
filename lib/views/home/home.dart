import 'package:fds_retail_count/views/FileManager/FileManager.dart';
import 'package:flutter/material.dart';
import 'package:fds_retail_count/utils/colors.dart';
import 'package:fds_retail_count/models/zona.dart';
import 'package:date_format/date_format.dart';
import 'package:fds_retail_count/views/form/form.dart';
import 'package:fds_retail_count/views/FileManager/FileManager.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final zoneNameController = TextEditingController();
  final List<String> log = <String>[];
  List<Zona> selectedZona;
  @override
  void initState() {
    super.initState();

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
        title: Text('App count bola '),
        backgroundColor: AppColors.primaryColor,
       actions: <Widget>[
         IconButton(
           icon: Icon( Icons.settings ),
           onPressed: () {
             Navigator.push(
               context,
               MaterialPageRoute(builder: (context) => FileManagerPage()),
             );
             }
         ),
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
        Expanded(flex: 8, child: _buildTableControll()),
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

  void onSelectedRowChanged({bool selected, Zona zonasel}) {
    setState(() {
      if (selected) {
        selectedZona.add(zonasel);
      } else {
        selectedZona.remove(zonasel);
      }
    });
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
      rows: zonas
          .map((Zona zonas) => DataRow(
                selected: selectedZona.contains(zonas),
                onSelectChanged: (bool selected) =>
                    onSelectedRowChanged(selected: selected, zonasel: zonas),
                cells: [
                  DataCell(Text('${zonas.name}')),
                  DataCell(Text(_format(zonas.date))),
                  DataCell(Text('${zonas.count}')),
                ],
              ))
          .toList(),
      sortColumnIndex: 0,
    );
  }

  String _format(DateTime date) {
    return (formatDate(
        DateTime(date.year, date.month, date.day), [yyyy, '-', mm, '-', dd]));
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
              child: Text('Eliminar'),
              color: Colors.red,
              onPressed: () {
                if (selectedZona.length == zonas.length) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Alerta"),
                          content: Text("Se eliminaran todos los registros"),
                          actions: <Widget>[
                            FlatButton(
                                onPressed: () => _deleteSelectAll(),
                                child: Text('OK')),
                            FlatButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('CANCEL')),
                          ],
                        );
                      });
                } else {
                  _deleteSelectAll();
                }
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
}
