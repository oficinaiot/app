import 'package:adestrakit/layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class MeusDispositivos extends StatefulWidget {
  @override
  _MeusDispositivosState createState() => _MeusDispositivosState();
}

class _MeusDispositivosState extends State<MeusDispositivos> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _user;
  DatabaseReference itemRef;
  Map<String, dynamic> dispositivos1 = Map();

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _auth.currentUser();
    return user;
  }
  @override
  void initState() {
    super.initState();
    getCurrentUser().then((user) async {
      if (user != null) {
        print(user);
        setState(() {
          _user = user;
        });





        DatabaseReference dispositivos = FirebaseDatabase.instance.reference().child("configEsp");
        final DatabaseReference usuarioPesquisa = dispositivos.child(_user.uid);
    //    Query usuarioPesquisa = dispositivos.child(_user.uid);
       // Query usuarioPesquisa = dispositivos.orderByKey().limitToFirst(2);
        usuarioPesquisa.once().then((DataSnapshot snapshot) {
          Map map = Map();
          map = snapshot.value;
          setState(() {
          map.forEach((key,value){
            print(key);
            dispositivos1[key]=value;
          });
          });
        });



      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Meus Dispositivos"),
      ),
      body: ListView.builder(
          itemCount: dispositivos1.length,
          itemBuilder: (BuildContext context,int index){
            return Card(
              elevation: 3.0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      Layout().titulo('Dispositivo'),
                      Text('Nome: ${dispositivos1.values.toList()[index]['nomeAdestra']}'),
                      Text('Local: ${dispositivos1.values.toList()[index]['localAdestra']}'),
                      Text('Distância Alerta: ${dispositivos1.values.toList()[index]['distanciaLimite']}'),
                      Text('${dispositivos1.keys.toList()[index]}'),
                    ],
                  ),
                ));
          },
          ),
    );
  }
}
