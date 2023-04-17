import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;

import 'DescriptionPage.dart';

class FavoritePage extends StatefulWidget {
  final token;
  const FavoritePage({@required this.token,Key? key}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List exercises = [];
  late List<bool> isFavoriteList;

  Future<List> fetchAllFavoriteExercices(String userId) async {

    var url = Uri.parse('http://localhost:3000/$userId/exercises');
    var response = await http.get(url);
    print(url);

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      setState(() {
        exercises = jsonResponse['data'];
        isFavoriteList = List.generate(exercises.length, (index) => false);

      });
      return exercises;
    } else {
      throw Exception('Failed to load exercises');
    }
  }
  late String idUser;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Map<String,dynamic> jwtDecodedToken= JwtDecoder.decode(widget.token);
    idUser = jwtDecodedToken['_id'];
    fetchAllFavoriteExercices(idUser);

    print(idUser);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          exercises.isEmpty ? Text("Aucun favori trouvé") :
          Expanded(
          child: ListView.builder(
            itemCount: exercises.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(exercises[index]['title']),
                subtitle: Text(exercises[index]['time'].toString()+" minutes"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [


                    ElevatedButton(
                      child: Text("Commencer l'exercice"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DescriptionPage(widget.token,exercises[index])),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),]
    ),
        )
    );
  }
}
