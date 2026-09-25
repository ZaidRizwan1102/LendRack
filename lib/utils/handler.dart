import 'package:flutter/material.dart';

class AppHandler{
  final BuildContext context;
  AppHandler(this.context);

  void toPage(Widget destination){
    Navigator.push(context, 
    MaterialPageRoute(builder: (context)=> destination)
    );
  }
  void goBack() => Navigator.pop(context);
}