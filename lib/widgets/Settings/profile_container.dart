import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wallet/screens/edit_profile.dart';
import 'package:wallet/services/auth.dart';
import 'package:wallet/utils/handler.dart';
import 'package:wallet/utils/responsive.dart';
import 'package:wallet/widgets/custom_button.dart';

class ProfileContainer extends StatelessWidget {
  const ProfileContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);
    final move = AppHandler(context);

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        // Fallback to active instance if snapshot hasn't resolved yet
        final user = snapshot.data ?? FirebaseAuth.instance.currentUser;

        // Safely extract display name and email with fallbacks
        final displayName =
            (user?.displayName != null && user!.displayName!.isNotEmpty)
                ? user.displayName!
                : "User";
        final email = user?.email ?? "No email provided";

        // Check if the user logged in using Google Auth
        final isGoogleUser = user?.providerData
                .any((info) => info.providerId == 'google.com') ??
            false;

        return Container(
          width: size.widthPerc(85),
          height: size.heightPerc(19),
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
            padding: EdgeInsets.only(
              left: size.widthPerc(7),
              top: size.heightPerc(2),
              right: size.widthPerc(7),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(height: size.heightPerc(0.5)),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                SizedBox(height: size.heightPerc(1.5)),

                // Conditional rendering based on auth provider
                if (isGoogleUser)
                  CustomButton(
                    moveTo: () async {
                      await AuthService().signOut();
                    },
                    buttonText: "Sign Out",
                    buttonIcon: null,
                    height: size.heightPerc(5),
                    width: size.widthPerc(71), // Full width inside padding
                    fontSize: 16,
                    iconSize: 0,
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomButton(
                        moveTo: () {
                          move.toPage(const EditProfile());
                        },
                        buttonText: "Edit",
                        buttonIcon: Icons.mode_edit_outline_outlined,
                        height: size.heightPerc(5),
                        width: size.widthPerc(34),
                        fontSize: 16,
                        iconSize: size.widthPerc(4.5),
                      ),
                      CustomButton(
                        moveTo: () async {
                          await AuthService().signOut();
                        },
                        buttonText: "Sign Out",
                        buttonIcon: null,
                        height: size.heightPerc(5),
                        width: size.widthPerc(34),
                        fontSize: 16,
                        iconSize: 0,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}