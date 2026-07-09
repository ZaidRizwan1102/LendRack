import 'package:flutter/material.dart';
import 'package:wallet/screens/home_page.dart';

void main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFF5F0F0),
        // textTheme: ThemeData.light().textTheme.apply(
        //   bodyColor: Color(0xFF001540),
        //   displayColor: Color(0xFF001540)
        // ),

      ),
      home: HomePage()
    );
  }
}