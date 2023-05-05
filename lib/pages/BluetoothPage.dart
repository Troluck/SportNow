import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';


class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});

  @override
  _BluetoothPageState createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devices = [];

  @override
  void initState() {
    super.initState();
    requestPermission();
    // Initialisez le plugin Bluetooth
    flutterBlue.state.listen((state) {
      if (state == BluetoothState.on) {
        // Scan des périphériques Bluetooth
        flutterBlue.scanResults.listen((results) {
          for (ScanResult r in results) {
            if (!devices.contains(r.device)) {
              setState(() {
                devices.add(r.device);
              });
            }
          }
        });
        flutterBlue.startScan();
      }
    });
  }
  void requestPermission() async {
    if (await Permission.bluetoothScan.request().isGranted) {
      print("Permission granted");
    } else {
      print("Permission not granted");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth'),
      ),
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(devices[index].name),
            subtitle: Text(devices[index].id.toString()),
            onTap: () {
              // Connectez-vous au périphérique Bluetooth sélectionné
              flutterBlue.stopScan();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DevicePage(device: devices[index], key: UniqueKey(),)),
              );
            },
          );
        },
      ),
    );
  }
}

class DevicePage extends StatefulWidget {
  final BluetoothDevice device;

  DevicePage({required Key key, required this.device}) : super(key: key);

  @override
  _DevicePageState createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  List<BluetoothService> services = [];

  @override
  void initState() {
    super.initState();
    // Connexion au périphérique Bluetooth sélectionné
    widget.device.connect().then((value) {
      // Récupération des services disponibles sur le périphérique
      widget.device.discoverServices().then((value) {
        setState(() {
          services = value;
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    // Déconnexion du périphérique Bluetooth lorsqu'on quitte la page
    widget.device.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name),
      ),
      body: ListView.builder(
        itemCount: services.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(services[index].uuid.toString()),
            subtitle: Text(services[index].characteristics.length.toString() + ' caractéristiques'),
            onTap: () {
              // Affichage des caractéristiques du service sélectionné
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CharacteristicPage(service: services[index], key: UniqueKey(),)),
              );
            },
          );
        },
      ),
    );
  }
}

class CharacteristicPage extends StatefulWidget {
  final BluetoothService service;

  CharacteristicPage({required Key key, required this.service}) : super(key: key);

  @override
  _CharacteristicPageState createState() => _CharacteristicPageState();
}

class _CharacteristicPageState extends State<CharacteristicPage> {
  List<BluetoothCharacteristic> characteristics = [];

  @override
  void initState() {
    super.initState();
    widget.service.characteristics.forEach((characteristic) {
      characteristics.add(characteristic);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service.uuid.toString()),
      ),
      body: ListView.builder(
        itemCount: characteristics.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(characteristics[index].uuid.toString()),
            subtitle: Text(characteristics[index].properties.toString()),
            onTap: () {
// Affichage de la valeur de la caractéristique sélectionnée
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CharacteristicValuePage(characteristic: characteristics[index], key: UniqueKey(),)),
              );
            },
          );
        },
      ),
    );
  }
}

class CharacteristicValuePage extends StatefulWidget {
  final BluetoothCharacteristic characteristic;

  CharacteristicValuePage({required Key key, required this.characteristic}) : super(key: key);

  @override
  _CharacteristicValuePageState createState() => _CharacteristicValuePageState();
}

class _CharacteristicValuePageState extends State<CharacteristicValuePage> {
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
// Lecture de la valeur de la caractéristique
    widget.characteristic.read().then((value) {
      setState(() {
        textEditingController.text = String.fromCharCodes(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.characteristic.uuid.toString()),
      ),
      body: Column(
        children: [
          TextField(
            controller: textEditingController,
          ),
          ElevatedButton(
            child: Text('Envoyer'),
            onPressed: () {
// Écriture de la valeur de la caractéristique
              widget.characteristic.write(textEditingController.text.codeUnits);
            },
          ),
        ],
      ),
    );
  }
}