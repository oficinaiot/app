import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'meusdispositivos.dart';
import 'configuracoes.dart';
import 'package:flutter/material.dart';
import 'layout.dart';
import 'login.dart';

void main() {
  SyncfusionLicense.registerLicense(
      "NT8mJyc2IWhiZH1gfWN9YmdoYmF8YGJ8ampqanNiYmlmamlmanMDHmg2PzI6PTYgMDskMj02IRM0PjI6P30wPD4=");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AdestraKit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'AdestraKit'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _user;
  Map<String, dynamic> dispositivos1 = Map();
  Map<String, dynamic> alarmes = Map();
  List<InvasoesData> myData = List();
  int count,index1 = 0;

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _auth.currentUser();
    return user;
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser().then((user) async {
      if (user == null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Login()));
        return;
      } else {
        setState(() {
          _user = user;
        });

        buscardispositivos();
      }
    });
  }

  void buscaalarmes() {
    DatabaseReference alarmesf =
        FirebaseDatabase.instance.reference().child("alarme");
    final DatabaseReference Pesquisa = alarmesf.child("24:6F:28:17:1A:74");
    Pesquisa.once().then((DataSnapshot snapshot) {
      Map map = Map();
      map = snapshot.value;
      setState(() {
        map.forEach((key, value) {
          print(key);
          alarmes[key] = value;
          alarmes.values.toList().map((item) {
            // item.forEach
          });
      });
alarmes.forEach((key, value){
  setState(() {
    myData.add(InvasoesData("${alarmes.keys.toList()[index1].replaceAll(':', '/')}", alarmes.values.toList()[index1].length));
  });
  index1++;
        });
    });
  });
  }

  void buscardispositivos() {
    DatabaseReference dispositivos =
        FirebaseDatabase.instance.reference().child("configEsp");
    final DatabaseReference usuarioPesquisa = dispositivos.child(_user.uid);
    //    Query usuarioPesquisa = dispositivos.child(_user.uid);
    // Query usuarioPesquisa = dispositivos.orderByKey().limitToFirst(2);
    usuarioPesquisa.once().then((DataSnapshot snapshot) {
      Map map = Map();
      map = snapshot.value;
      setState(() {
        map.forEach((key, value) {
          print(key);
          dispositivos1[key] = value;
        });
      });

      buscaalarmes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("AdestraKit"),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: (_user != null && _user.email != null)
                  ? Text(_user.email)
                  : Container(),
            ),
            Layout().itemdrawer("Configurar Dispositivo",
                Icons.settings_bluetooth, Configuracoes(), context),
            Layout().itemdrawer(
                "Meus Dispositivos", Icons.adjust, MeusDispositivos(), context),
            Card(
              child: InkWell(
                onTap: () {
                  showCupertinoDialog(
                      context: context,
                      builder: (context) {
                        return CupertinoAlertDialog(
                          title: new Text("Ups"),
                          content: new Text("Deseja sair?"),
                          actions: <Widget>[
                            CupertinoDialogAction(
                              isDefaultAction: true,
                              child: Text("OK",
                                  style: TextStyle(color: Colors.blue)),
                              onPressed: () {
                                _auth.signOut().then((user) {
                                  Navigator.pop(context);
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Login()));
                                });
                              },
                            ),
                            CupertinoDialogAction(
                              isDefaultAction: true,
                              child: Text("CANCELAR",
                                  style: TextStyle(color: Colors.blue)),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      });
                },
                child: ListTile(
                  title: Text("Sair"),
                  leading: Icon(Icons.power_settings_new),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.5,
              child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  // Chart title
                  title: ChartTitle(text: 'Evolução do Adestramento'),
                  // Enable legend
                  legend: Legend(isVisible: true),
                  // Enable tooltip
                  tooltipBehavior: TooltipBehavior(enable: true),
                  zoomPanBehavior: ZoomPanBehavior(enablePinching: true,zoomMode: ZoomMode.xy,enablePanning: true,enableDoubleTapZooming: true,enableSelectionZooming: true),

                  series: <LineSeries<InvasoesData, String>>[
                   LineSeries<InvasoesData, String>(
                      dataSource: myData.reversed.toList(),
                      xValueMapper: (InvasoesData invasao, _) => invasao.data,
                      yValueMapper: (InvasoesData invasao, _) => invasao.invasoes,
                      legendItemText: "Invasão",
                      // Enable data label
                      dataLabelSettings: DataLabelSettings(isVisible: true),
                      color: Colors.red,
                    )
                  ]
              ),
            ),
            Expanded(
                child: ListView.builder(
              itemCount: alarmes.length,
              itemBuilder: (BuildContext context, int index) {
//                setState(() {
//                  myData.add(InvasoesData("${alarmes.keys.toList()[index].replaceAll(':', '/')}", alarmes.values.toList()[index].length));
//                });

                return Card(
                    elevation: 3.0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(
                            'Data: ${alarmes.keys.toList()[index].replaceAll(':', '/')}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                              '${alarmes.values.toList()[index].length} invasões'),
                        ],
                      ),
                    ));
              },
            )),
            (alarmes == null)
                ? Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Nesta tela inicial serão apresentados \ngráficos de evolução do adestramento.\n\n\n Versão inicial para configurar o dispositivo \ne verificar layout de telas: \nLogin e Meus Dispositivos.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                          height: MediaQuery.of(context).size.height * 0.4,
                          width: MediaQuery.of(context).size.height * 0.4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: NetworkImage(
                                    'http://giphygifs.s3.amazonaws.com/media/mCRJDo24UvJMA/giphy.gif'),
                                fit: BoxFit.contain),
                          )),
                    ],
                  )
                : Container(),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class InvasoesData {
  InvasoesData(this.data, this.invasoes);

  final String data;
  final int invasoes;
}
