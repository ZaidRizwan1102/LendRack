import 'package:flutter/material.dart';
import 'package:wallet/utils/handler.dart';
import 'package:wallet/utils/responsive.dart';
import 'package:wallet/widgets/custom_button.dart';

class SignupBackButtons extends StatelessWidget {
  final VoidCallback? onSignupPressed;

  const SignupBackButtons({super.key, this.onSignupPressed});

  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);
    final move = AppHandler(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomButton(
          buttonText: "Back",
          moveTo: move.goBack,
          buttonIcon: Icons.arrow_back_rounded,
          width: size.widthPerc(40),
        ),
        SizedBox(width: size.widthPerc(5)),
        CustomButton(
          buttonText: "Sign Up",
          moveTo: onSignupPressed ?? () {},
          trailingIcon: Icons.arrow_forward_rounded,
          width: size.widthPerc(40),
        ),
      ],
    );
  }
}
