import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/utils/responsive.dart';
import 'package:wallet/widgets/calendar_bottom_model.dart';

class ReturnDate extends StatefulWidget {
  final ValueChanged<DateTime?>? onDateSelected;

  ReturnDate({super.key, this.onDateSelected});

  @override
  State<ReturnDate> createState() => _ReturnDateState();
}

class _ReturnDateState extends State<ReturnDate> {
  DateTime? returnDate;

  void pickDate() async {
    final DateTime? pickedDate = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (BuildContext context) {
        return CalendarBottomModel();
      },
    );
    if (pickedDate != null) {
      setState(() {
        returnDate = pickedDate;
      });
      widget.onDateSelected?.call(pickedDate);
    }
  }

  String get formatedDate {
    if (returnDate == null) {
      return "";
    }
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final monthName = months[returnDate!.month - 1];
    return "$monthName ${returnDate!.day}, ${returnDate!.year}";
  }

  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);
    return Container(
      margin: EdgeInsets.only(
        left: size.widthPerc(3),
        top: size.heightPerc(1.5),
      ),
      width: size.widthPerc(71),
      height: size.heightPerc(5.8),
      decoration: BoxDecoration(
        color: const Color(0xFFECF6FF),
        borderRadius: BorderRadius.circular(size.widthPerc(4)),
        border: Border.all(color: Colors.black54, width: 1),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: size.widthPerc(5.26),
              right: size.widthPerc(4),
            ),
            child: SvgPicture.asset('assets/images/calendar.svg'),
          ),
          Text(formatedDate, style: const TextStyle(fontSize: 16, color: Colors.black),),
          const Spacer(),
          Padding(
            padding: EdgeInsets.only(right: size.widthPerc(6)),
            child: GestureDetector(
              onTap: pickDate,
              behavior: HitTestBehavior.opaque,
              child: Text(
                returnDate == null ? "SET" : "CHANGE",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.green.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
