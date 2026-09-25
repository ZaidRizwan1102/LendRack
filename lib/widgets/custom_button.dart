import 'package:flutter/material.dart';
import 'package:wallet/utils/responsive.dart';

class CustomButton extends StatelessWidget {
  final String buttonText;
  final Color? buttonColor;
  final IconData? buttonIcon; // Icon before text
  final IconData? trailingIcon; // Optional icon after text
  final VoidCallback moveTo;
  final double? height;
  final double? width;
  final double? iconSize;
  final double? fontSize;

  const CustomButton({
    super.key,
    required this.buttonText,
    required this.moveTo,
    this.buttonColor,
    this.buttonIcon,
    this.trailingIcon,
    this.height,
    this.width,
    this.iconSize,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);

    return Center(
      child: ElevatedButton(
        onPressed: moveTo,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(size.widthPerc(3)),
          ),
          fixedSize: Size(
            width ?? size.widthPerc(85),
            height ?? size.heightPerc(6),
          ),
          backgroundColor: buttonColor ?? Theme.of(context).colorScheme.primary,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon before text
            if (buttonIcon != null) ...[
              Icon(
                buttonIcon,
                color: Theme.of(context).cardColor,
                size: iconSize ?? size.widthPerc(5.6),
              ),
              SizedBox(width: size.widthPerc(3)),
            ],

            // Text content
            Text(
              buttonText,
              style: TextStyle(
                fontSize: fontSize ?? 19,
                color: Theme.of(context).cardColor,
              ),
            ),

            // Icon after text
            if (trailingIcon != null) ...[
              SizedBox(width: size.widthPerc(3)),
              Icon(
                trailingIcon,
                color: Theme.of(context).colorScheme.surface,
                size: iconSize ?? size.widthPerc(5.6),
              ),
            ],
          ],
        ),
      ),
    );
  }
}