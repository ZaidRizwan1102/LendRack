import 'package:flutter/material.dart';
import 'package:wallet/utils/responsive.dart';

class InputHeading extends StatelessWidget{
  final String heading;

  InputHeading({
    super.key,
    required this.heading
  });
  @override
  Widget build(BuildContext context){
    final size = Responsive(context);
    return Padding(
          padding: EdgeInsetsGeometry.only(left: size.widthPerc(2)),
          child: Text(heading,
          style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          letterSpacing: size.widthPerc(0.3)
        ),
      )
     );
  }
}