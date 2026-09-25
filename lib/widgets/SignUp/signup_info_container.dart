import 'package:flutter/material.dart';
import 'package:wallet/utils/responsive.dart';
import 'package:wallet/widgets/custom_input_field.dart';

class SignupInfoContainer extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  const SignupInfoContainer({
    super.key,
    required this.emailController,
    required this.usernameController,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);
    return Container(
      width: size.widthPerc(85),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(size.widthPerc(3)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: size.widthPerc(0.2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: size.widthPerc(5),
          top: size.heightPerc(2),
          bottom: size.heightPerc(2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "EMAIL",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            CustomInputField(
              controller: emailController,
              hintText: "Enter your email",
              svgPath: 'assets/images/email.svg',
            ),
            SizedBox(height: size.heightPerc(3)),
            Text(
              "USERNAME",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            CustomInputField(
              controller: usernameController,
              hintText: "Enter your username",
              svgPath: 'assets/images/email.svg',
            ),
            SizedBox(height: size.heightPerc(3)),
            Text(
              "CREATE PASSWORD",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            CustomInputField(
              controller: passwordController,
              hintText: "Create password",
              svgPath: 'assets/images/new_password.svg',
              svgSize: size.widthPerc(6.5),
              svgPadding: size.widthPerc(2.5),
              isPassword: true,
            ),
            SizedBox(height: size.heightPerc(3)),
            Text(
              "CONFIRM PASSWORD",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            CustomInputField(
              controller: confirmPasswordController,
              hintText: "Enter confirm password",
              svgPath: 'assets/images/confirm_password.svg',
              svgSize: size.widthPerc(6.5),
              svgPadding: size.widthPerc(2.5),
              isPassword: true,
            ),
          ],
        ),
      ),
    );
  }
}
