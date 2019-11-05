import 'package:flutter/material.dart';

import 'layout.dart';

class DispositivoDetalhe extends StatefulWidget {
  @override
  _DispositivoDetalheState createState() => _DispositivoDetalheState();
}

class _DispositivoDetalheState extends State<DispositivoDetalhe> {
  TextEditingController cnome = TextEditingController();
  TextEditingController clocal = TextEditingController();
  TextEditingController cdistancia = TextEditingController();
  bool configurado = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configurar Dispositivo"),
        actions: <Widget>[
          FlatButton(
            onPressed: () {},
            child: Text("Salvar"),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 5.0,
            child: Column(
              children: <Widget>[
                Layout().secao("Configure o Dispositivo"),
                Layout().titulo("Nome do Dispositivo"),
                Layout().caixadetexto(cnome, "Dê um nome para o dispositivo"),
                Layout().titulo("Local"),
                Layout().caixadetexto(clocal, "Qual o local do dispositivo?"),
                Layout().titulo("Distância de alerta - Sinal Luminoso"),
                Layout().caixadetexto(cdistancia, "Distância em centímetros"),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: InkWell(
                    onTap: () {
                      if (cnome.text.isEmpty) {
                        Layout().dialog1botao(
                            context, "Ups", "Escreva o nome do dispositivo");
                      } else if (clocal.text.isEmpty) {
                        Layout().dialog1botao(
                            context, "Ups", "Escreva o local do dispositivo");
                      } else if (cdistancia.text.isEmpty) {
                        Layout().dialog1botao(context, "Distância de alerta",
                            "Escreva a distancia que o cachorro pode se aproximar do dispositivo até o acionamento");
                      } else {
                        configurado = true;
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
      ),
    );
  }
}
