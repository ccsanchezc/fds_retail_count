import 'package:flutter/material.dart';
import 'views/home/home.dart';
import 'views/form/form.dart';
const String homeViewRoute = '/';
const String formViewRoute = 'form';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case homeViewRoute:
      return MaterialPageRoute(builder: (_) => HomePage());
    case formViewRoute:
      return MaterialPageRoute(builder: (_) => FormPage()
      );
      break;
    default:
      return MaterialPageRoute(builder: (_) => HomePage());
  }
}
