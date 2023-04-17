import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_file.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_browser.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testratraflutter/config.dart';
import 'package:testratraflutter/constants/global_variables.dart';
import 'package:testratraflutter/pages/HomePage.dart';
import 'package:testratraflutter/pages/LoginPage.dart';
import 'package:testratraflutter/pages/RegistrationPage.dart';
import 'package:testratraflutter/router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async{

  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(token: prefs.getString('token'),));
}

class MyApp extends StatelessWidget {

  final token;

  const MyApp({
    @required this.token,
    Key? key,
}): super(key:key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(/*
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [
           Locale('en', 'US'), // English
           Locale('fr', 'FR'), // French
          // add more locales here
        ],*/
      title: 'Amazon Clone',
      theme: ThemeData(
        scaffoldBackgroundColor: GlobalVariables.backgroundColor,
      ),
      onGenerateRoute:(settings)=>generateRoute(settings) ,
      home: (token !=null && JwtDecoder.isExpired(token) == false)?HomePage(token: token): const LoginPage()
    );
  }
}