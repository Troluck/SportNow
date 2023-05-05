import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:testratraflutter/config.dart';

import 'DescriptionPage.dart';



class HistoryPage extends StatefulWidget {
  final token;
  const HistoryPage({@required this.token,Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List exercises = [];
  late List<bool> isFavoriteList;



  Future<List> fetchAllHistoryExercises(String userId) async {

    var url = Uri.parse(urls+'/$userId/exercisesHistory');
    var response = await http.get(url);
    print(url);

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      setState(() {
        exercises = jsonResponse['data'];
        for(int i = 0; i < exercises.length; i++) {
          print(exercises[i]['exercise']['title']);
        }


        /*isFavoriteList = List.generate(exercises.length, (index) => false);*/

        if (exercises ==null){
          print("error");
        }
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
    fetchAllHistoryExercises(idUser);


  }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
          appBar: AppBar(
            title: Text("Historique"),
          ),
          body:Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  exercises.isEmpty ? Text("Aucun historique trouvé") :
                  Expanded(
                    child: ListView.builder(
                      itemCount: exercises.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(exercises[index]['exercise']['title']),
                          subtitle: Text(exercises[index]['exercise']['time'].toString()+" minutes"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(DateFormat('dd/MM/yyyy à HH:mm').format(DateTime.parse(exercises[index]['date']).add(Duration(hours: 2)))),

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

