import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/utils/handler.dart';
import 'package:wallet/utils/responsive.dart';
import 'package:wallet/widgets/EditProfile/edit_field_bottom_sheet.dart';
import 'package:wallet/widgets/EditProfile/password_bottom_sheet.dart';
import 'package:wallet/widgets/custom_button.dart';
import 'package:wallet/widgets/custom_snackbar.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String name = "";
  String email = "";
  String password = "••••••••";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final firebaseUser = FirebaseAuth.instance.currentUser;

    setState(() {
      // 1. Check local storage first, fallback to Firebase Auth
      name = prefs.getString('user_name') ?? firebaseUser?.displayName ?? "No Name Set";
      email = prefs.getString('user_email') ?? firebaseUser?.email ?? "No Email Found";
    });
  }

  Future<void> _updateName(String newName) async {
    final trimmedName = newName.trim();
    if (trimmedName.isEmpty) {
      CustomSnackBar.show(context, message: "Name cannot be empty");
      return;
    }

    // 1. Save to local storage immediately
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', trimmedName);

    setState(() {
      name = trimmedName;
    });

    // 2. Backup to Firebase Auth
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateDisplayName(trimmedName);
        await user.reload();
      }
      if (mounted) {
        CustomSnackBar.show(context, message: "Name updated successfully!");
      }
    } catch (_) {
      if (mounted) {
        CustomSnackBar.show(context, message: "Saved locally!");
      }
    }
  }

  Future<void> _updateEmail(String newEmail) async {
    final trimmedEmail = newEmail.trim();
    if (trimmedEmail.isEmpty) {
      CustomSnackBar.show(context, message: "Email cannot be empty");
      return;
    }

    // 1. Save to local storage immediately
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', trimmedEmail);

    setState(() {
      email = trimmedEmail;
    });

    // 2. Backup to Firebase Auth
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.verifyBeforeUpdateEmail(trimmedEmail);
      }
      if (mounted) {
        CustomSnackBar.show(
          context,
          message: "Email updated! Verification link sent.",
        );
      }
    } catch (_) {
      if (mounted) {
        CustomSnackBar.show(context, message: "Saved locally!");
      }
    }
  }

  Future<void> _updatePassword(String currentPass, String newPass) async {
    if (currentPass.isEmpty || newPass.isEmpty) {
      CustomSnackBar.show(context, message: "Fields cannot be empty");
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPass,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPass);
      }

      if (mounted) {
        CustomSnackBar.show(context, message: "Password updated successfully!");
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(context, message: "Failed to update password");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);
    final move = AppHandler(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => move.goBack(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  SizedBox(width: size.widthPerc(12)),
                  const Text(
                    "Edit Profile",
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              SizedBox(height: size.heightPerc(7)),

              // Main Container
              Center(
                child: Container(
                  width: size.widthPerc(85),
                  padding: EdgeInsets.symmetric(
                    horizontal: size.widthPerc(5),
                    vertical: size.heightPerc(2.5),
                  ),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name Section
                      _buildProfileField(
                        context: context,
                        size: size,
                        label: "NAME",
                        value: name,
                        onPressed: () {
                          EditFieldBottomSheet.show(
                            context: context,
                            title: "Edit Name",
                            initialValue: name,
                            hintText: "Enter your full name",
                            svgPath: 'assets/images/person.svg',
                            onSave: (newName) => _updateName(newName),
                          );
                        },
                      ),

                      Divider(
                        height: size.heightPerc(3.5),
                        thickness: size.widthPerc(0.3),
                      ),

                      // Email Section
                      _buildProfileField(
                        context: context,
                        size: size,
                        label: "EMAIL ADDRESS",
                        value: email,
                        onPressed: () {
                          EditFieldBottomSheet.show(
                            context: context,
                            title: "Edit Email Address",
                            initialValue: email,
                            hintText: "Enter email address",
                            svgPath: 'assets/images/email.svg',
                            onSave: (newEmail) => _updateEmail(newEmail),
                          );
                        },
                      ),

                      Divider(
                        height: size.heightPerc(3.5),
                        thickness: size.widthPerc(0.3),
                      ),

                      // Password Section
                      _buildProfileField(
                        context: context,
                        size: size,
                        label: "PASSWORD",
                        value: password,
                        onPressed: () {
                          PasswordBottomSheet.show(
                            context: context,
                            onSave: (currentPass, newPass) =>
                                _updatePassword(currentPass, newPass),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField({
    required BuildContext context,
    required Responsive size,
    required String label,
    required String value,
    required VoidCallback onPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        SizedBox(height: size.heightPerc(0.5)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        SizedBox(height: size.heightPerc(1.5)),
        CustomButton(
          buttonText: "Change",
          fontSize: 16,
          width: size.widthPerc(28),
          height: size.heightPerc(3),
          moveTo: onPressed,
        ),
      ],
    );
  }
}