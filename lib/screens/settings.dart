import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wallet/services/auth.dart';
import 'package:wallet/utils/responsive.dart';
import 'package:wallet/widgets/Settings/account_container.dart';
import 'package:wallet/widgets/Settings/app_preferance.dart';
import 'package:wallet/widgets/Settings/other_settings.dart';
import 'package:wallet/widgets/Settings/profile_container.dart';
import 'package:wallet/widgets/header.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            children: [
              const Header(),
              SizedBox(height: size.heightPerc(2)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.widthPerc(5)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Settings",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: size.heightPerc(0.4)),
                    Text(
                      "MANAGE YOUR PROFILE AND APP APPEARANCE",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    SizedBox(height: size.heightPerc(3)),

                    // Instant UI update with initialData check
                    Center(
                      child: StreamBuilder<User?>(
                        stream: AuthService().userChanges,
                        initialData: FirebaseAuth.instance.currentUser,
                        builder: (context, snapshot) {
                          final user = snapshot.data;
                          final isLoggedIn = user != null && !user.isAnonymous;

                          if (isLoggedIn) {
                            return const ProfileContainer();
                          }
                          return const AccountContainer();
                        },
                      ),
                    ),

                    SizedBox(height: size.heightPerc(3)),
                    Text(
                      "APP PREFERENCES",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    SizedBox(height: size.heightPerc(2)),
                    const Center(child: AppPreferance()),
                    SizedBox(height: size.heightPerc(3)),
                    Text(
                      "OTHER SETTINGS",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    SizedBox(height: size.heightPerc(2)),
                    const Center(child: OtherSettings()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}