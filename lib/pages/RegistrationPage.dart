import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
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
  bool _isObscure = true;


  void registerUser()async{
    if(emailController.text.isNotEmpty && passwordController.text.isNotEmpty){
      var regBody={
        "email": emailController.text,
        "password": passwordController.text,

      };

      var response = await http.post(
        Uri.parse(urls + "/registration"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody),
      );

      if (response.statusCode == 200) {
        _showSuccessDialog();
      }
      else if (response.statusCode == 416) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Utilisateur déja existant")));

      }
      else if (response.statusCode == 417) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Le mot de passe n'est pas conforme")));

      }
      else if (response.statusCode == 418) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("L'email n'est pas conforme")));

      }


      
    }else{
      setState(() {
        _isNotValidate = true;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Inscription réussie"),
          content: const Text("Votre compte a été enregistré avec succès !"),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ],
        );
      },
    );
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
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),

                if (passwordController.text.isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        " 8 caractères - ",
                        style: TextStyle(
                          color: passwordController.text.length >= 8 ? Colors.green : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        "une minuscule - ",
                        style: TextStyle(
                          color: passwordController.text.contains(new RegExp(r'[a-z]')) ? Colors.green : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                         "une majuscule - ",
                        style: TextStyle(
                          color: passwordController.text.contains(new RegExp(r'[A-Z]')) ? Colors.green : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        "un chiffre - ",
                        style: TextStyle(
                          color: passwordController.text.contains(new RegExp(r'[0-9]')) ? Colors.green : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        "caractère spécial",
                        style: TextStyle(
                          color: passwordController.text.contains(new RegExp(r'[!@#$%^&*(),.?":{}|<>-]')) ? Colors.green : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ],
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