import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/services/auth.dart';
import 'package:wallet/utils/responsive.dart';
import 'package:wallet/widgets/custom_snackbar.dart';

class GoogleButton extends StatelessWidget {
  const GoogleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(size.widthPerc(3)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: size.widthPerc(0.2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () async {
          try {
            final userCredential = await AuthService().signInWithGoogle();

            if (userCredential != null && context.mounted) {
              CustomSnackBar.show(context, message: "Signed in successfully!");

              // 💡 FIX: Clear auth routes and navigate to root/home
              Navigator.of(context).popUntil((route) => route.isFirst);

              // Note: If you use a ValueNotifier/Provider to control bottom navbar index, 
              // reset index to 0 here (e.g., navigationProvider.setIndex(0);)
            }
          } catch (e) {
            if (context.mounted) {
              CustomSnackBar.show(context, message: e.toString());
            }
          }
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(size.widthPerc(3)),
          ),
          fixedSize: Size(size.widthPerc(85), size.heightPerc(6)),
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
        child: SvgPicture.asset(
          'assets/images/google_text.svg',
          height: size.heightPerc(7),
        ),
      ),
    );
  }
}