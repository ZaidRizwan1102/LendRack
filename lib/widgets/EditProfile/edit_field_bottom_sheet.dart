import 'package:flutter/material.dart';
import 'package:wallet/utils/responsive.dart';
import 'package:wallet/widgets/custom_button.dart';
import 'package:wallet/widgets/custom_input_field.dart';

class EditFieldBottomSheet extends StatefulWidget {
  final String title;
  final String initialValue;
  final String hintText;
  final String svgPath;
  final Function(String) onSave;

  const EditFieldBottomSheet({
    super.key,
    required this.title,
    required this.initialValue,
    required this.hintText,
    required this.svgPath,
    required this.onSave,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String initialValue,
    required String hintText,
    required String svgPath,
    required Function(String) onSave,
  }) {
    return showModalBottomSheet<T>(
      context: context, 
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => EditFieldBottomSheet(
        title: title,
        initialValue: initialValue,
        hintText: hintText,
        svgPath: svgPath,
        onSave: onSave,
      ),
    );
  }

  @override
  State<EditFieldBottomSheet> createState() => _EditFieldBottomSheetState();
}

class _EditFieldBottomSheetState extends State<EditFieldBottomSheet> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
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

          Text(
            widget.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),

          CustomInputField(
            hintText: widget.hintText,
            svgPath: widget.svgPath,
            controller: _controller,
            customWidth: size.widthPerc(85),
            margin: EdgeInsets.only(top: size.heightPerc(2)),
          ),

          SizedBox(height: size.heightPerc(3)),

          Row(
            children:[ 
              CustomButton(
              moveTo: () {
                widget.onSave(_controller.text.trim());
                Navigator.pop(context);
              },
              buttonText: "Save Changes",
              buttonIcon: null,
              buttonColor: Colors.green.shade600,
              width: size.widthPerc(45),
            ),
            Spacer(),
            CustomButton(
              moveTo: () {
                widget.onSave(_controller.text.trim());
                Navigator.pop(context);
              },
              buttonText: "Cancel",
              buttonIcon: null,
              width: size.widthPerc(45),
            ),
            ]
          ),
        ],
      ),
    );
  }
}
