import 'package:flutter/material.dart';
import 'package:wallet/utils/responsive.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: size.widthPerc(100),
      height: size.heightPerc(6.5),
      padding: EdgeInsets.symmetric(horizontal: size.widthPerc(4.5)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            isDark
                ? 'assets/images/logo_dark.png' // Logo for dark mode (e.g., white text)
                : 'assets/images/logo_light.png',
            height: size.heightPerc(4.8),
          ),
          SizedBox(width: size.widthPerc(1.5)),
          Center(
            child: Text(
              "LendRack",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
