import 'dart:math';

import 'package:fds_retail_count/models/masterdata.dart';
import 'package:flutter/material.dart';
import 'package:fds_retail_count/utils/colors.dart';
import 'package:fds_retail_count/models/masterdata.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/services.dart';
import 'package:fds_retail_count/db/database.dart';

class DetailPage extends StatefulWidget {
  String namezone;
  String date;

  DetailPage({Key key, @required this.namezone, @required this.date})
      : super(key: key);
  @override
  DetailPageState createState() => DetailPageState(this.namezone, this.date);
}

class DetailPageState extends State<DetailPage> {
  final material = new TextEditingController();
  final name = new TextEditingController();
  final color = new TextEditingController();
  final talla = new TextEditingController();
  final bar_code = new TextEditingController();
  final depto = new TextEditingController();
  final mvgr1 = new TextEditingController();
  final cantidad = new TextEditingController();

  String namezone;
  String date;
  Material_data materialinfo = new Material_data();
  DetailPageState(this.namezone, this.date);
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
        title: Text('Zona: ' + this.namezone),
        backgroundColor: AppColors.primaryColor,
      ),
      //body: _buildTableControll(),
      body: FutureBuilder<List<Zona_Field>>(
        //we call the method, which is in the folder db file database.dart
        future: DatabaseProvider.db.getZonaWithIddate(this.namezone, this.date),
        builder:
            (BuildContext context, AsyncSnapshot<List<Zona_Field>> snapshot) {
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
                    DatabaseProvider.db.deleteZonaWithIdMat(
                        item.zona, item.date, item.material);
                  },
                  //Now we paint the list with all the records, which will have a number, name, phone
                  child: Padding(
                    padding: EdgeInsets.only(left: 12, right: 12),
                    child: Card(
                      child: ListTile(
                        onTap: ,
                        title: Text(item.name),
                        subtitle: Text(item.material),
                        leading: CircleAvatar(
                            child: Text(item.canti_count.toString())),
                        //If we press one of the cards, it takes us to the page to edit, with the data onTap:
                        //This method is in the file add_editclient.dart
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
        //new ListView(
        //children: ZonasCount.map(_buildItem).toList(),
      ),

      backgroundColor: AppColors.statusBarColor,
    );
  }
}
