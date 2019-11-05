

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Layout {


  Widget itemdrawer(text, icon, destino, context) {
    return Card(
      elevation: 2.0,
      child: InkWell(
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => destino));
        },
        child: ListTile(
          title: Text(text),
          leading: Icon(icon),
        ),
      ),
    );
  }

  Widget titulo(texto) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        texto,
        style: TextStyle(fontWeight: FontWeight.bold),textAlign: TextAlign.center,
      ),
    );
  }

  Widget segmented(opcoes, opcao, funcao, context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: CupertinoSegmentedControl<int>(
            selectedColor: Colors.blue,
            borderColor: Colors.blue,
            children: opcoes,
            onValueChanged: (val) {
              funcao(val);
            },
            groupValue: opcao),
      ),
    );
  }

  Widget secao(texto) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Container(
        width: 500.0,
        height: 25.0,
        child: Center(
            child: Text(
              texto,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
            )),
      ),
    );
  }


  dialog1botao(context, titulo, texto) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: new Text(titulo),
            content: new Text(texto),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text(
                  "OK",
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  Widget caixadetexto(controller, placeholder) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: CupertinoTextField(
        minLines: 1,
        maxLines: 1,
        controller: controller,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.amber)),
        textCapitalization: TextCapitalization.sentences,
        autofocus: false,
        placeholder: placeholder,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
      ),
    );
  }


}