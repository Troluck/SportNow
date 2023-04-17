import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:testratraflutter/pages/DescriptionPage.dart';
import 'package:testratraflutter/pages/FavoritePage.dart';



class HomePage extends StatefulWidget {
  final token;
      const HomePage({@required this.token,Key? key}) : super(key: key);
    
      @override
      State<HomePage> createState() => _HomePageState();
    }
    
    class _HomePageState extends State<HomePage> {
      List exercises = [];
      late List<bool> isFavoriteList;

      Future<List> FetchAllExercise() async {

        var url = Uri.parse('http://localhost:3000/findAllExercise');
        var response = await http.get(url);

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
      Future<void> addFavorite(String userId, String exerciseId) async {
        final url = Uri.parse('http://localhost:3000/$userId/exercises/$exerciseId');

        final response = await http.post(url);

        if (response.statusCode == 200) {
          print('Exercice ajouté aux favoris');
        } else {
          throw Exception('Erreur : impossible d\'ajouter l\'exercice aux favoris');
        }
      }
      Future<void> deleteFavorite(String userId, String exerciseId) async {
        final url = Uri.parse('http://localhost:3000/$userId/exercises/$exerciseId');

        final response = await http.delete(url);

        if (response.statusCode == 200) {
          print('Exercice supprimé des favoris');
        } else {
          throw Exception('Erreur : impossible de supprimer l\'exercice aux favoris');
        }
      }

  late String email;
      late String idUser;
      late String idExercise;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Map<String,dynamic> jwtDecodedToken= JwtDecoder.decode(widget.token);
    FetchAllExercise();

    email = jwtDecodedToken['email'];
    idUser = jwtDecodedToken['_id'];
    print(idUser);
  }
      @override
      Widget build(BuildContext context) {
        return Scaffold(
          body:Center(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(email),
              FloatingActionButton(onPressed:(){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoritePage(token: widget.token))
                );

              },child: Icon(Icons.favorite),
                tooltip: 'Voir les favoris'),
              
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
                        IconButton(
                          icon: Icon(
                            isFavoriteList[index] ? Icons.favorite : Icons.favorite_border,
                            color: isFavoriteList[index] ? Colors.red : null,
                          ),
                          onPressed: () {
                            idExercise = exercises[index]['_id'];
                            if (isFavoriteList[index]) {
                              deleteFavorite(idUser, idExercise);
                            } else {
                              addFavorite(idUser, idExercise);
                            }
                            setState(() {
                              isFavoriteList[index] = !isFavoriteList[index];

                            });
                          },
                        ),

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
              ),


            ],
          )
        )
        );
      }
    }
    