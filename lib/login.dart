import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'layout.dart';
import 'main.dart';


class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  int opcao = 0;
  Map<int, Widget> opcoes = const <int, Widget>{
    0: Text("Primeiro Acesso"),
    1: Text("Já sou Usuário"),
  };

  void mudardosegmento(val) {
    setState(() {
      opcao = val;
    });
  }

  TextEditingController cnome = TextEditingController();
  TextEditingController cemail = TextEditingController();
  TextEditingController csenha = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Login"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
                height:  MediaQuery.of(context).size.height * 0.4,
                width:  MediaQuery.of(context).size.height * 0.4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: NetworkImage('https://media.giphy.com/media/4Zo41lhzKt6iZ8xff9/giphy.gif'),
                      fit: BoxFit.contain),
                )),
            Layout().segmented(opcoes, opcao, mudardosegmento, context),
            (opcao == 0)
                ? Column(
                    children: <Widget>[
                      Layout().caixadetexto(cnome, "Nome"),
                      Layout().caixadetexto(cemail, "e-mail"),
                      Layout().caixadetexto(csenha, "senha"),
                    ],
                  )
                : Column(
                    children: <Widget>[
                      Layout().caixadetexto(cemail, "e-mail"),
                      Layout().caixadetexto(csenha, "senha")
                    ],
                  ),
            RaisedButton(
              onPressed: () {
                (opcao == 0 ) ? createuser() : loginUser();
              },
              elevation: 3.0,
              child: Text("Entrar"),
            )
          ],
        ),
      ),
    );
  }

  Future<FirebaseUser> loginUser() async {
    FirebaseUser user;
    try {
      AuthResult result;
      result = await _auth.signInWithEmailAndPassword(
          email: cemail.text, password: csenha.text);
      user = result.user;

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MyHomePage()));

      return user;
    } on Exception catch (e) {
      print(e);
      Layout().dialog1botao(context, "Ups",
          "Suas credenciais estão incorretas. \n Tente novamente.");
    }
  }


  Future<FirebaseUser> createuser() async {
    FirebaseUser user;
    try {

        Map<String, dynamic> map = Map();
        AuthResult result;
        result = await _auth.createUserWithEmailAndPassword(
            email: cemail.text, password: csenha.text);
        user = result.user;
        map['email'] = user.email;
        map['displayName'] = cnome.text;

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MyHomePage()));
        return user;



    } on Exception catch (e) {
      print(e);
      Layout().dialog1botao(context, "Ups",
          "Erro: $e");


    }
  }


}
