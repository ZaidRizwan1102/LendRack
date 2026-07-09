import 'package:flutter/material.dart';
import 'package:wallet/utils/responsive.dart';

class AddRecord extends StatelessWidget {
  const AddRecord({super.key});

  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);
    return Padding(
      padding: EdgeInsets.only(left: size.widthPerc(4),right: size.widthPerc(4)),
      child: ElevatedButton.icon(onPressed: (){},
          icon: Icon(Icons.add_box_outlined,
          color: Colors.white,
            size: size.widthPerc(7),
          ),
          label: Text('Add Record',
          style: TextStyle(
            fontSize: 23,
            color: Colors.white
          ),),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(size.widthPerc(3))
          ),
          fixedSize: Size(size.widthPerc(90), size.heightPerc(7)),
          backgroundColor: Color(0xFF001540)
        ),
      ),
    );
  }
}
