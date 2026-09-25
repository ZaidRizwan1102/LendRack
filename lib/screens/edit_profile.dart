import 'package:flutter/material.dart';
import 'package:wallet/utils/handler.dart';
import 'package:wallet/utils/responsive.dart';
import 'package:wallet/widgets/EditProfile/edit_field_bottom_sheet.dart';
import 'package:wallet/widgets/EditProfile/password_bottom_sheet.dart';
import 'package:wallet/widgets/custom_button.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String name = "Alex Johnson";
  String email = "alex.j@example.com";
  String password = "••••••••";

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
                            onSave: (newName) {
                              if (newName.isNotEmpty) {
                                setState(() => name = newName);
                              }
                            },
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
                            onSave: (newEmail) {
                              if (newEmail.isNotEmpty) {
                                setState(() => email = newEmail);
                              }
                            },
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
                            onSave: (currentPass, newPass) {
                              // Handle password save
                            },
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
