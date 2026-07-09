import 'package:flutter/material.dart';

class Responsive {
  final BuildContext context;
  late double screenWidth;
  late double screenHeight;

  Responsive(this.context){
    screenWidth = MediaQuery.sizeOf(context).width;
    screenHeight = MediaQuery.sizeOf(context).height;
  }

  double widthPerc(double percent) => screenWidth* (percent/100);
  double heightPerc(double percent) => screenHeight* (percent/100);
}