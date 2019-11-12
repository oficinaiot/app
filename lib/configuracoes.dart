import 'dart:async';
import 'dart:convert' show utf8;
import 'dart:io';
import 'package:adestrakit/meusdispositivos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'layout.dart';
import 'login.dart';

class Configuracoes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Configurar IOT",
      debugShowCheckedModeBanner: false,
      home: Wifi(),
    );
  }
}

class Wifi extends StatefulWidget {
  @override
  _WifiState createState() => _WifiState();
}

class _WifiState extends State<Wifi> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _user;
  String SERVICE_UUID = '87b34f52-4765-4d3a-b902-547751632d72';
  String CHARACTERISTIC_UUID = 'a97d209a-b1d6-4edf-b67f-6a0c25fa42c9';
  String TARGET_DEVICE_NAME = 'AdestraKit';

  String wifinome;
  String wifiBSSID;
  String wifiip;
  String rede;
  String _connectionStatus = 'Unknown';
  bool encontroudispositivo = false;
  bool redewifi = false;

  String senhaenviada, dispositivoid, nome, local, distancia;

  int  meiodistancia;

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _auth.currentUser();
    return user;
  }

  final Connectivity _connectivity = Connectivity();

  FlutterBlue flutterBlue = FlutterBlue.instance;
  StreamSubscription<ScanResult> scanSubscription;
  StreamSubscription<ConnectivityResult> subscription;

  BluetoothDevice deviceencontrado;
  BluetoothDevice targetDevice;
  BluetoothCharacteristic targetCharacteristic;

  TextEditingController senha = TextEditingController();
  TextEditingController cnome = TextEditingController();
  TextEditingController clocal = TextEditingController();
  TextEditingController cdistancia = TextEditingController();
  TextEditingController crede = TextEditingController();

  bool configurado = false;
  bool compartilhado = false;
  bool pronto = false;


  String connectionText = " ";

  @override
  void initState() {
    super.initState();

    startScan();
    initConnectivity();
    subscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    getCurrentUser().then((user) async {
      if (user == null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Login()));
        return;
      } else {
        setState(() {
          _user = user;
        });
      }
    });
  }

  startScan() {
    setState(() {
      connectionText = "Conecte o dispositivo à energia.\n\n A luz indicativa deve estar azul, caso não esteja, clique no botão RESET.\n\nBuscando Dispositivo";
    });

    scanSubscription = flutterBlue.scan().listen((scanResult) {
      targetDevice = scanResult.device;
      //  print('${targetDevice.name} found! rssi: ${scanResult.rssi}');

      if (scanResult.device.name.contains(TARGET_DEVICE_NAME)) {
        stopScan();

        setState(() {
          connectionText = "Dispositivo Encontrado";
        });

        targetDevice = scanResult.device;

        connectToDevice();
      }
    }, onDone: () => stopScan());
  }

  connectToDevice() async {
    if (targetDevice == null) {
      return;
    }
    setState(() {
      connectionText = "Conectando com o Dispositivo";
    });

    await targetDevice.connect();

    setState(() {
      connectionText = "Dispositivo Conectado";
    });

    discoverServices();
  }

  discoverServices() async {
    if (targetDevice == null) {
      return;
    }

    List<BluetoothService> services = await targetDevice.discoverServices();

    services.forEach((service) {
      print(service.uuid.toString());
      print(service.characteristics.toString());
      if (service.uuid.toString() == SERVICE_UUID) {
        service.characteristics.forEach((chara) {
          if (chara.uuid.toString() == CHARACTERISTIC_UUID)
            targetCharacteristic = chara;
          setState(() {
            encontroudispositivo = true;
            connectionText = "Tudo certo com o Dispositivo";
          });
        });
      }
    });
  }

  writeData(String data) async {
    if (targetCharacteristic == null) {
      return;
    }

    List<int> bytes = utf8.encode(data);
    await targetCharacteristic.write(bytes);
  }

  disconectFromDevice() {
    if (targetDevice == null) {
      return;
    }
    targetDevice.disconnect();
    setState(() {
      connectionText = "Dispositivo Desconectado";
    });
  }

  submitwifi() {
    var wifidata = "${crede.text},${senha.text},aeiou,${cnome.text},${clocal.text},${cdistancia.text},${_user.uid}";
    writeData(wifidata);
  }

  stopScan() {
    scanSubscription?.cancel();
    scanSubscription = null;
  }

  @override
  void dispose() {
    stopScan();
    subscription.cancel();
    scanSubscription?.cancel();
    super.dispose();
  }



  Future<void> initConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return;
    }
    _updateConnectionStatus(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("Conecte seu AdestraKit"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            (redewifi != null && redewifi)
                ? Center(
                    child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      connectionText,
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.w600),textAlign: TextAlign.center,
                    ),
                  ))
                : Text(
                    "Não encontramos rede wifi.\n É necessário estar em uma rede wifi \npara conectar com o AdestraKit.\nTente novamente.",
                    textAlign: TextAlign.center,
                  ),
            (!encontroudispositivo)
                ? Image.network(
                    'https://media.giphy.com/media/jAYUbVXgESSti/giphy.gif')
                : Container(),
            (encontroudispositivo)
                ? Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          color: Colors.blue[400],
                          elevation: 5.0,
                          child: Column(
                            children: <Widget>[
                              Layout().secao("Configure o Dispositivo"),
                              Layout().titulo("Nome do Dispositivo"),
                              Layout().caixadetexto(
                                  cnome, "Dê um nome para o dispositivo"),
                              Layout().titulo("Local"),
                              Layout().caixadetexto(
                                  clocal, "Qual o local do dispositivo?"),
                              Layout().titulo(
                                  "Distância de alerta - Sinal Luminoso"),
                              Layout().caixadetexto(
                                  cdistancia, "Distância em centímetros"),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: InkWell(
                                  onTap: () {
                                    if (cnome.text.isEmpty) {
                                      Layout().dialog1botao(context, "Ups",
                                          "Escreva o nome do dispositivo");
                                    } else if (clocal.text.isEmpty) {
                                      Layout().dialog1botao(context, "Ups",
                                          "Escreva o local do dispositivo");
                                    } else if (cdistancia.text.isEmpty) {
                                      Layout().dialog1botao(
                                          context,
                                          "Distância de alerta",
                                          "Escreva a distancia que o cachorro pode se aproximar do dispositivo até o acionamento");
                                    }
                                    else {
                                      FocusScope.of(context).requestFocus(FocusNode());
                                      setState(() {
                                        configurado = true;
                                      });
                                    }
                                  },
                                  child: Card(
                                      elevation: 8.0,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text(
                                          'OK',
                                          textAlign: TextAlign.center,
                                        ),
                                      )),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: (configurado)
                            ? Card(
                          color: Colors.red[300],
                                elevation: 5.0,
                                child: Container(
                                  child: Column(
                                    children: <Widget>[
                                      Layout().secao("Compartilhe sua rede Wi-Fi"),
                                      Text(
                                        "Esta é a rede wifi que você compartilhará com o monitor:",
                                        textAlign: TextAlign.center,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child:
                                           Layout().caixadetexto(crede, "Nome da rede wifi"),
//                                        Text(
//                                            (rede != null) ? rede : "",
//                                            style: TextStyle(
//                                                fontSize: 18.0,
//                                                fontWeight: FontWeight.w600)),
                                      ),
                                      Text("Escreva abaixo a senha do wifi"),
                                      Layout()
                                          .caixadetexto(senha, "Senha WiFi"),
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: InkWell(
                                          onTap: () {
                                            if (senha.text.isEmpty) {
                                              Layout().dialog1botao(
                                                  context,
                                                  "Ups",
                                                  "Escreva a senha do Wifi");
                                            } else {
                                              if (crede.text.isEmpty){
                                                Layout().dialog1botao(
                                                    context,
                                                    "Ups",
                                                    "Escreva o nome da rede Wifi");
                                              } else {

                                              submitwifi();
                                              FocusScope.of(context).requestFocus(FocusNode());
                                             setState(() {
                                               compartilhado = true;
                                             });
                                            }}
                                          },
                                          child: Card(
                                              elevation: 8.0,
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                    12.0),
                                                child: Text(
                                                  'COMPARTILHAR',
                                                  textAlign: TextAlign.center,
                                                ),
                                              )),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            : Container(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: (compartilhado)
                            ? Card(
                            color: Colors.green[300],
                            elevation: 5.0,
                            child: Container(
                              child: Column(
                                children: <Widget>[
                                  Layout().secao("Quase Pronto"),
                                  Layout().titulo("Aperte o botão de RESET na parte superior do dispositivo e aguarde a luz indicativa ficar verde e parar de piscar.\n\n A luz verde piscando, indica que o dispositivo está tentando conectar à rede. Caso a luz não estabilize, repita esta procedimento."),

                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          pronto = true;
                                        });
                                      },
                                      child: Card(
                                          elevation: 8.0,
                                          child: Padding(
                                            padding: const EdgeInsets.all(
                                                12.0),
                                            child: Text(
                                              'A luz está verde e parou de piscar',
                                              textAlign: TextAlign.center,
                                            ),
                                          )),
                                    ),
                                  ),
                                ],
                              ),
                            ))
                            : Container(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: (pronto)
                            ? Card(
                            color: Colors.amber[300],
                            elevation: 5.0,
                            child: Container(
                              child: Column(
                                children: <Widget>[
                                  Layout().secao("Parabéns"),
                                  Layout().titulo("Seu dispositivo foi configurado com sucesso e está conectado à internet.\n\nEncontre-o, clicando em 'Meus Dispositivos''\n\nCaso altere as configurações da rede wifi - nome e senha, repita o procedimento."),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context, MaterialPageRoute(builder: (context) => MeusDispositivos()));
                                      },
                                      child: Card(
                                          elevation: 8.0,
                                          child: Padding(
                                            padding: const EdgeInsets.all(
                                                12.0),
                                            child: Text(
                                              'OK',
                                              textAlign: TextAlign.center,
                                            ),
                                          )),
                                    ),
                                  ),
                                ],
                              ),
                            ))
                            : Container(),
                      ),
                    ],
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        String wifiName, wifiBSSID, wifiIP;

        try {
          if (Platform.isIOS) {
            LocationAuthorizationStatus status =
                await _connectivity.getLocationServiceAuthorization();
            if (status == LocationAuthorizationStatus.notDetermined) {
              status =
                  await _connectivity.requestLocationServiceAuthorization();
            }
            if (status == LocationAuthorizationStatus.authorizedAlways ||
                status == LocationAuthorizationStatus.authorizedWhenInUse) {
              wifiName = await _connectivity.getWifiName();
            } else {
              wifiName = await _connectivity.getWifiName();
            }
          } else {
            wifiName = await _connectivity.getWifiName();
          }
        } on PlatformException catch (e) {
          print(e.toString());
          wifiName = "Não conseguimos pegar o nome da rede. Tente novamente.";
        }

        try {
          if (Platform.isIOS) {
            LocationAuthorizationStatus status =
                await _connectivity.getLocationServiceAuthorization();
            if (status == LocationAuthorizationStatus.notDetermined) {
              status =
                  await _connectivity.requestLocationServiceAuthorization();
            }
            if (status == LocationAuthorizationStatus.authorizedAlways ||
                status == LocationAuthorizationStatus.authorizedWhenInUse) {
              wifiBSSID = await _connectivity.getWifiBSSID();
            } else {
              wifiBSSID = await _connectivity.getWifiBSSID();
            }
          } else {
            wifiBSSID = await _connectivity.getWifiBSSID();
          }
        } on PlatformException catch (e) {
          print(e.toString());
          wifiBSSID = "Failed to get Wifi BSSID";
        }

        try {
          wifiIP = await _connectivity.getWifiIP();
        } on PlatformException catch (e) {
          print(e.toString());
          wifiIP = "Failed to get Wifi IP";
        }

        setState(() {
          rede = wifiName;
          crede.text = wifiName;
          wifiip = wifiIP;
          redewifi = true;
          _connectionStatus = '$result\n'
              'Wifi Name: $wifiName\n'
              'Wifi BSSID: $wifiBSSID\n'
              'Wifi IP: $wifiIP\n';
        });
        break;
      case ConnectivityResult.mobile:
      case ConnectivityResult.none:
        setState(() => _connectionStatus = result.toString());
        break;
      default:
        setState(() => _connectionStatus = 'Failed to get connectivity.');
        break;
    }
  }
}
