import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:testratraflutter/pages/HomePage.dart';


class DescriptionPage extends StatefulWidget {
  final exercise;
  final token;
  const DescriptionPage( this.token,this.exercise, {Key? key}) : super(key: key);

  @override
  State<DescriptionPage> createState() => _DescriptionPageState();
}

class _DescriptionPageState extends State<DescriptionPage> {

  Future<void> addToHistory(String userId, String exerciseId) async {
    final url = Uri.parse('http://localhost:3000/$userId/exercisesHistory/$exerciseId');

    final response = await http.post(url);

    if (response.statusCode == 200) {
      print('Exercice ajouté à historique');
    } else {
      throw Exception('Erreur : impossible d\'ajouter l\'exercice à historique');
    }
  }

  int _timeInSeconds = 0;
  bool _isActive = false;
  late Timer _timer;
  late String idUser;

  @override
  void initState() {
    super.initState();
    Map<String,dynamic> jwtDecodedToken= JwtDecoder.decode(widget.token);
    idUser = jwtDecodedToken['_id'];

    print(idUser);
   /* _timeInSeconds = widget.exercise['time']*60;*/
     _timeInSeconds = 1;

  }

  int bpm = 0;
  void _startTimer() {
    final random = Random();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeInSeconds == 0) {
        //...
      } else {
        setState(() {
          _timeInSeconds--;
          bpm = random.nextInt(200); // Génère un nombre aléatoire entre 0 et 199.
        });
      }
    });
    setState(() {
      _isActive = true;
    });
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeInSeconds == 0) {
        addToHistory(idUser, widget.exercise['_id']);
        _resetTimer();
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text("Bravo vous avez réussi cette exercice"),
              content: Text("l'exercice c'est mis dans votre historique, vous pouvez le recommencer à tout moment "),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(token: widget.token)));
                    },
                    child: Text("OK"))
              ],
            ));
      } else {
        setState(() {
          _timeInSeconds--;
        });
      }
    });
  }

  void _resetTimer() {
    setState(() {
      _isActive = false;
      _timeInSeconds = 120;
    });
    if (_timer != null) {
      _timer.cancel();
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

@override
  Widget build(BuildContext context) {
  String timeLeft = _formatTime(_timeInSeconds);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise['title']),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.exercise['description']),
            SizedBox(height: 16),
            Text(widget.exercise['time'].toString() + ' minutes'),

            if(!_isActive)
            ElevatedButton(
              onPressed: _isActive ? null : _startTimer,
              child: Text("Démarrer"),
            ),

        Visibility(
          visible: _isActive,
          child: ElevatedButton(
            onPressed: _resetTimer,
            child: Text("Réinitialiser"),
          ),
        ),
            Text(
              "Temps restant : $timeLeft",
              style: TextStyle(fontSize: 24),
            ),
            Text(
              "BPM: $bpm",
              style: TextStyle(fontSize: 24),
            ),

          ],
        ),
      ),
    );
  }
}
