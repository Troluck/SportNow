import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testratraflutter/config.dart';
import 'package:testratraflutter/constants/global_variables.dart';
import 'package:testratraflutter/pages/HomePage.dart';
import 'package:testratraflutter/pages/RegistrationPage.dart';
import 'package:testratraflutter/router.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
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
    return MaterialApp(
      title: 'Amazon Clone',
      theme: ThemeData(
        scaffoldBackgroundColor: GlobalVariables.backgroundColor,
      ),
      onGenerateRoute:(settings)=>generateRoute(settings) ,
      home: (token !=null && JwtDecoder.isExpired(token) == false)?HomePage(token: token): const RegistrationPage()
    );
  }
}