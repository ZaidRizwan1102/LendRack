import 'package:flutter/material.dart';
import 'package:wallet/utils/responsive.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);
    return Container(
      width: size.widthPerc(100),
      height: size.heightPerc(6.5),
      padding: EdgeInsets.symmetric(horizontal: size.widthPerc(4.5)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/images/logo.svg', height: size.heightPerc(3.1),),
          SizedBox(width: size.widthPerc(1.5),),
          Text("LendRack", style: TextStyle(
            fontSize: 24, fontWeight: FontWeight.bold
          ),
          ),
          Spacer(),
          IconButton(onPressed: (){},
              icon: Icon(Icons.notifications_active_outlined)
          ),
        ],
      ),
    );
  }
}
