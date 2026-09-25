import 'package:flutter/material.dart';
import 'package:wallet/screens/login.dart';
import 'package:wallet/screens/signup.dart';
import 'package:wallet/utils/handler.dart';
import 'package:wallet/utils/responsive.dart';
import 'package:wallet/widgets/custom_button.dart';

class AccountContainer extends StatelessWidget {
  const AccountContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);
    final move = AppHandler(context);

    return Container(
      width: size.widthPerc(85),
      // 1. Replaced fixed height with minHeight baseline
      constraints: BoxConstraints(minHeight: size.heightPerc(19)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size.widthPerc(3)),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: size.widthPerc(0.2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size.widthPerc(6),
          vertical: size.heightPerc(2), // Added bottom padding safety
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 2. FittedBox ensures header scales down on narrow physical screens
            const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "Back up & Sync Your Data",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            Divider(color: Theme.of(context).textTheme.bodySmall?.color),
            SizedBox(height: size.heightPerc(0.5)),

            // 3. IntrinsicHeight matches divider height to column height dynamically
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // LEFT COLUMN (LOGIN)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Already have an account?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                        SizedBox(height: size.heightPerc(1)),
                        CustomButton(
                          buttonText: "Login",
                          moveTo: () {
                            move.toPage(Login());
                          },
                          width: size.widthPerc(30),
                          height: size.heightPerc(3.5),
                          fontSize: 15,
                        ),
                      ],
                    ),
                  ),

                  // 4. Clean vertical divider without hardcoded height
                  VerticalDivider(
                    width: size.widthPerc(4),
                    thickness: 1.5,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),

                  // RIGHT COLUMN (SIGN UP)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Don't have an account?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                        SizedBox(height: size.heightPerc(1)),
                        CustomButton(
                          buttonText: "Sign Up",
                          moveTo: () {
                            move.toPage(Signup());
                          },
                          width: size.widthPerc(30),
                          height: size.heightPerc(3.5),
                          fontSize: 15,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
