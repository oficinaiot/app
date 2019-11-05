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
          print('Connected and read ${snapshot.value}');
        });



      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Meus Dispositivos"),
        actions: <Widget>[
          FlatButton(
            textColor: Colors.white,
            onPressed: (){
//              Navigator.push(
//                  context, MaterialPageRoute(builder: (context) => destino));
            },
            child: Text("Registrar"),
          )
        ],
      ),
      body: Column(),
    );
  }
}
