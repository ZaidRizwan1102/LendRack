import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:wallet/utils/responsive.dart';
import 'package:wallet/widgets/custom_button.dart';

class CalendarBottomModel extends StatefulWidget {
  final DateTime? initialDate;

  const CalendarBottomModel({super.key, this.initialDate});

  @override
  State<CalendarBottomModel> createState() => _CalendarBottomModelState();
}

class _CalendarBottomModelState extends State<CalendarBottomModel> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);

    return Container(
      height: size.heightPerc(42),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(size.widthPerc(6)), // Restores rounded top corners
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: size.heightPerc(30),
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              backgroundColor: Colors.transparent, // Blends 100% into cardColor
              initialDateTime: selectedDate,
              minimumDate: DateTime(1950),
              maximumDate: DateTime(2100),
              onDateTimeChanged: (DateTime newDate) {
                setState(() {
                  selectedDate = newDate;
                });
              },
            ),
          ),
          CustomButton(
            moveTo: () {
              Navigator.pop(context, selectedDate);
            },
            buttonText: "Done",
            buttonIcon: null,
            buttonColor: Colors.green.shade600,
          ),
        ],
      ),
    );
  }
}