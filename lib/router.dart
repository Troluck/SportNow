import 'package:flutter/material.dart';
import 'package:testratraflutter/pages/RegistrationPage.dart';

Route<dynamic> generateRoute(RouteSettings routeSettings){
  switch(routeSettings.name){
    case RegistrationPage.routeName:
      return MaterialPageRoute(settings: routeSettings,builder: (_)=>const RegistrationPage(),
      );
    default:
  return MaterialPageRoute(
    settings: routeSettings,
    builder: (_)=>const Scaffold(
      body: Center(
        child: Text("cette page n'existe pas")
      ),
    ),
  );
  }
}
