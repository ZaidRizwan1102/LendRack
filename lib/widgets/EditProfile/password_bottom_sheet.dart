import 'package:flutter/material.dart';
import 'package:wallet/utils/responsive.dart';
import 'package:wallet/widgets/custom_button.dart';
import 'package:wallet/widgets/custom_input_field.dart';

class PasswordBottomSheet extends StatefulWidget {
  final Function(String currentPass, String newPass) onSave;

  const PasswordBottomSheet({super.key, required this.onSave});

  static Future<T?> show<T>({
    required BuildContext context,
    required Function(String currentPass, String newPass) onSave,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => PasswordBottomSheet(onSave: onSave),
    );
  }

  @override
  State<PasswordBottomSheet> createState() => _PasswordBottomSheetState();
}

class _PasswordBottomSheetState extends State<PasswordBottomSheet> {
  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  @override
  void dispose() {
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);

    return Padding(
      padding: EdgeInsets.only(
        left: size.widthPerc(4),
        right: size.widthPerc(4),
        top: size.heightPerc(1.5),
        bottom: MediaQuery.of(context).viewInsets.bottom + size.heightPerc(3),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Drag Handle
          Container(
            width: size.widthPerc(12),
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: size.heightPerc(2)),

          const Text(
            "Change Password",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),

          CustomInputField(
            hintText: "Enter current password",
            svgPath: 'assets/images/current_password.svg',
            svgSize: size.widthPerc(6.5),
            svgPadding: size.widthPerc(2.5),
            isPassword: true,
            controller: _currentPassController,
            customWidth: size.widthPerc(85),
            margin: EdgeInsets.only(top: size.heightPerc(2)),
          ),

          CustomInputField(
            hintText: "Enter new password",
            svgPath: 'assets/images/new_password.svg',
            svgSize: size.widthPerc(6.5),
            svgPadding: size.widthPerc(2.5),
            isPassword: true,
            controller: _newPassController,
            customWidth: size.widthPerc(85),
            margin: EdgeInsets.only(top: size.heightPerc(1.5)),
          ),

          CustomInputField(
            hintText: "Confirm new password",
            svgPath: 'assets/images/confirm_password.svg',
            svgSize: size.widthPerc(6.5),
            svgPadding: size.widthPerc(2.5),
            isPassword: true,
            controller: _confirmPassController,
            customWidth: size.widthPerc(85),
            margin: EdgeInsets.only(top: size.heightPerc(1.5)),
          ),

          SizedBox(height: size.heightPerc(3)),

          CustomButton(
            moveTo: () {
              if (_newPassController.text == _confirmPassController.text) {
                widget.onSave(
                  _currentPassController.text,
                  _newPassController.text,
                );
                Navigator.pop(context);
              }
            },
            buttonText: "Save Changes",
            buttonIcon: null,
            buttonColor: Colors.green.shade600,
          ),
        ],
      ),
    );
  }
}
