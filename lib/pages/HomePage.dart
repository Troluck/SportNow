import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:testratraflutter/pages/BluetoothPage.dart';
import 'package:testratraflutter/pages/DescriptionPage.dart';
import 'package:testratraflutter/pages/FavoritePage.dart';
import 'package:testratraflutter/pages/HistoryPage.dart';
import 'package:testratraflutter/config.dart';



class HomePage extends StatefulWidget {
  final token;
      const HomePage({@required this.token,Key? key}) : super(key: key);
    
      @override
      State<HomePage> createState() => _HomePageState();
    }
    
    class _HomePageState extends State<HomePage> {
      List exercises = [];
      List exercisesFav = [];
      late List<bool> isFavoriteList;

      Future<List> FetchAllExercise() async {
        var url = Uri.parse(urls + '/findAllExercise');
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
        final url = Uri.parse(urls + '/$userId/exercises/$exerciseId');

        final response = await http.post(url);

        if (response.statusCode == 200) {
          print('Exercice ajouté aux favoris');
        } else {
          throw Exception(
              'Erreur : impossible d\'ajouter l\'exercice aux favoris');
        }
      }

      Future<void> deleteFavorite(String userId, String exerciseId) async {
        final url = Uri.parse(urls + '/$userId/exercises/$exerciseId');

        final response = await http.delete(url);

        if (response.statusCode == 200) {
          print('Exercice supprimé des favoris');
        } else {
          throw Exception(
              'Erreur : impossible de supprimer l\'exercice aux favoris');
        }
      }

      Future<List> fetchAllFavoriteExercices(String userId) async {
        var url = Uri.parse(urls + '/$userId/exercises');
        var response = await http.get(url);


        if (response.statusCode == 200) {
          var jsonResponse = jsonDecode(response.body);
          setState(() {
            exercisesFav = jsonResponse['data'];
            isFavoriteList =
                List.generate(exercisesFav.length, (index) => false);
          });
          return exercisesFav;
        } else {
          throw Exception('Failed to load exercises');
        }
      }

      late String email;
      late String idUser;
      late String idExercise;


      @override
      void initState() {
        super.initState();

        final jwtDecodedToken = JwtDecoder.decode(widget.token);
        email = jwtDecodedToken['email'];
        idUser = jwtDecodedToken['_id'];


        fetchAllFavoriteExercices(idUser).then((favorites) {
          final idsSet = Set<String>.from(favorites.map((fav) => fav['_id']));

          setState(() {
            exercisesFav = favorites;
            isFavoriteList =
                exercises.map((exercise) => idsSet.contains(exercise['_id']))
                    .toList();
          });
        });

        FetchAllExercise();
      }

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: exercises.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Text(exercises[index]['title']),
                        subtitle: Text(
                            exercises[index]['time'].toString() + " minutes"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                isFavoriteList[index] ? Icons.favorite : Icons
                                    .favorite_border,
                                color: isFavoriteList[index]
                                    ? Colors.red
                                    : null,
                              ),
                              onPressed: () {
                                idExercise = exercises[index]['_id'];
                                if (isFavoriteList[index]) {
                                  deleteFavorite(idUser, idExercise);
                                } else {
                                  addFavorite(idUser, idExercise);
                                }
                                setState(() {
                                  isFavoriteList[index] =
                                  !isFavoriteList[index];
                                });
                              },
                            ),

                            ElevatedButton(
                              child: Text("Commencer l'exercice"),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) =>
                                      DescriptionPage(
                                          widget.token, exercises[index])),
                                );
                              },
                            ),
                          ],
                        ),

                      );
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme
                        .of(context)
                        .scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 5,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FloatingActionButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FavoritePage(token: widget.token),
                              ),
                            );
                          },
                          child: Icon(Icons.favorite),
                          tooltip: 'Voir les favoris',
                        ),
                        FloatingActionButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    HistoryPage(token: widget.token),
                              ),
                            );
                          },
                          child: Icon(Icons.history),
                          tooltip: 'historique',
                        ),
                        FloatingActionButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>
                                  BluetoothPage()),
                            );
                          },
                          child: Icon(Icons.bluetooth),
                          tooltip: 'bluetooth',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }





