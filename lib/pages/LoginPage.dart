import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testratraflutter/constants/global_variables.dart';
import 'package:testratraflutter/config.dart';
import 'package:testratraflutter/pages/HomePage.dart';
import 'package:testratraflutter/pages/RegistrationPage.dart';

class LoginPage extends StatefulWidget {
  static const String routeName = '/loginPage()';
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isNotValidate = false;
  bool _isObscure = true;
  late SharedPreferences prefs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSharedPref();
  }

  void initSharedPref()async{
    prefs = await SharedPreferences.getInstance();
  }




  void loginUser() async {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {

      var regBody = {
        "email": emailController.text,
        "password": passwordController.text,

      };
      try {
        var response = await http.post(Uri.parse(urls+'/login'),
            headers:{"Content-Type": "application/json",} ,
            body: jsonEncode(regBody));
        var jsonResponse = jsonDecode(response.body);
        if(jsonResponse["status"]){
          var myToken = jsonResponse["token"];
          prefs.setString('token',myToken);
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  HomePage(token:myToken )));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Adresse e-mail ou mot de passe incorrect")));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur de connexion : ${e.toString()}")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: GlobalVariables.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const Text(
              "SportNow",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            ),
            const ListTile(
              title: Text(
                'Connexion',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.text,
              decoration:  InputDecoration(
                filled: true,
                fillColor: Colors.white,
                errorText: _isNotValidate ? "Enter vos données" : null,
                hintText: "e-mail",
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
            ),
            TextField(
              controller: passwordController,
              keyboardType: TextInputType.text,
              obscureText: _isObscure,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                errorText: _isNotValidate ? "Enter vos données" : null,
                hintText: "Password",
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),

                  suffixIcon: IconButton(
                      icon: Icon(
                          _isObscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      }),


              ),
            ),
            ElevatedButton(
              onPressed: () {
                loginUser();


              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text('Connection'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegistrationPage()),
                );

              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text("Vous n'avez pas de compte"),
            ),



          ],
        ),
      ),
    );
  }
}