import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:testratraflutter/config.dart';

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
    final url = Uri.parse(urls + '/$userId/exercisesHistory/$exerciseId');

    final response = await http.post(url);

    if (response.statusCode == 200) {
      print('Exercice ajouté à historique');
    } else {
      throw Exception(
          'Erreur : impossible d\'ajouter l\'exercice à historique');
    }
  }

  int _timeInSeconds = 0;
  bool _isActive = false;
  late Timer _timer;
  late String idUser;

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    idUser = jwtDecodedToken['_id'];


    _timeInSeconds = widget.exercise['time'] * 60;
  }

  int mean = 115;
  int stdDev = 3;
  int bpm = 0;

  void _startTimer() {
    final random = Random();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeInSeconds == 0) {
        addToHistory(idUser, widget.exercise['_id']);
        _resetTimer();
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Bravo vous avez réussi cette exercice"),
            content: Text(
                "l'exercice c'est mis dans votre historique, vous pouvez le recommencer à tout moment "),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(token: widget.token),
                    ),
                  );
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
      } else {
        setState(() {
          _timeInSeconds--;
          bpm = _truncatedNormalDistribution(mean, stdDev, 80, 150, random);
        });
      }
    });

    setState(() {
      _isActive = true;
    });
  }

  int _truncatedNormalDistribution(int mean, int stdDev, int min, int max,
      Random random) {
    int result = (mean + _normalDistribution(stdDev.toDouble(), random))
        .round();
    result = result.clamp(min, max);
    return result;
  }

  double _normalDistribution(double stdDev, Random random) {
    double u1 = 1.0 - random.nextDouble();
    double u2 = 1.0 - random.nextDouble();
    double z = sqrt(-2.0 * log(u1)) * cos(2.0 * pi * u2);
    return stdDev * z;
  }


  void _resetTimer() {
    setState(() {
      _isActive = false;
      _timeInSeconds = widget.exercise['time'] * 60;
      bpm = 0;
    });

    if (_timer != null) {
      _timer.cancel();
    }

    String timeLeft = _formatTime(_timeInSeconds);
    Text("Temps restant : $timeLeft");
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



