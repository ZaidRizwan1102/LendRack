import 'package:flutter/material.dart';
import 'package:wallet/utils/responsive.dart';

class ContinueWith extends StatelessWidget {
  const ContinueWith({super.key});

  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: size.widthPerc(7),
              right: size.widthPerc(3),
            ),
            child: Divider(
              thickness: 2,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
        Text(
          "OR CONTINUE WITH",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: size.widthPerc(3),
              right: size.widthPerc(7),
            ),
            child: Divider(
              thickness: 2,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
      ],
    );
  }
}
