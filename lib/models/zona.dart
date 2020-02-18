import 'package:flutter/material.dart';

class Zona {
  Zona(this.name, this.date, this.count);
  final String name;
  final DateTime date ;
  final int count;

  bool selected = false;
}

final List<String> zonaColumns = [
  'Name',
  'Date',
  'Count',
]; // , 'Population'

final List<Zona> zonas =[
  Zona('Chongqing', DateTime.now(), 30751600),
  Zona('Shanghai', DateTime.now(), 24256800),
  Zona('Beijing', DateTime.now(), 21516000),
  Zona('Lagos', DateTime.now(), 16060303),
  Zona('Chengdu', DateTime.now(), 16044700),
  Zona('Karachi', DateTime.now(), 14910352),
  Zona('Dhaka', DateTime.now(), 14399000),
  Zona('Guangzhou', DateTime.now(), 14043500),
  Zona('Istanbul', DateTime.now(), 14025000),
  //Zona('Tokyo', DateTime.now(), 13839910),
  //Zona('Tokyo', DateTime.now(), 13839910),
  //Zona('Tokyo', DateTime.now(), 13839910),
  //Zona('Tokyo', DateTime.now(), 13839910),
 // Zona('Tokyo', DateTime.now(), 13839910),
  Zona('Tokyo', DateTime.now(), 13839910),
];
//comment test for initial commit upload all project
