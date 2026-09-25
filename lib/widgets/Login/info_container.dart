import 'package:flutter/material.dart';
import 'package:wallet/utils/responsive.dart';
import 'package:wallet/widgets/custom_input_field.dart';

class InfoContainer extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const InfoContainer({
    super.key,
    required this.emailController,
    required this.passwordController,
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
          bottom: size.heightPerc(3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "EMAIL",
              style: TextStyle(
                fontSize: 17,
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
              "PASSWORD",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            CustomInputField(
              controller: passwordController,
              hintText: "Enter current password",
              svgPath: 'assets/images/current_password.svg',
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
