import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:testratraflutter/common/widgets/custom_textfield.dart';
import 'package:testratraflutter/constants/global_variables.dart';
import 'package:testratraflutter/config.dart';
import 'package:testratraflutter/pages/LoginPage.dart';

class RegistrationPage extends StatefulWidget {
  static const String routeName = '/loginPage()';
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isNotValidate = false;


  void registerUser()async{
    if(emailController.text.isNotEmpty && passwordController.text.isNotEmpty){
      var regBody={
        "email": emailController.text,
        "password": passwordController.text,

      };

      var response = await http.post(Uri.parse("http://localhost:3000/registration"),

      headers:{"Content-Type": "application/json",} ,
      body: jsonEncode(regBody));


      
    }else{
      setState(() {
        _isNotValidate = true;
      });
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
              "Welcome",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            ),
            const ListTile(
              title: Text(
                'Créer un compte',
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
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                errorText: _isNotValidate ? "Enter vos données" : null,
                hintText: "Password",
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                registerUser();

              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text('Inscription'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );

              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text('Déja un compte ?'),
            ),



          ],
        ),
      ),
    );
  }
}