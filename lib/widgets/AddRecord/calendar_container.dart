import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/utils/responsive.dart';
import 'package:wallet/widgets/calendar_bottom_model.dart';

class CalendarContainer extends StatefulWidget {
  final ValueChanged<DateTime>? onDateSelected;

  CalendarContainer({super.key, this.onDateSelected});

  @override
  State<CalendarContainer> createState() => _CalendarContainerState();
}

class _CalendarContainerState extends State<CalendarContainer> {
  DateTime transactionDate = DateTime.now();

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
        transactionDate = pickedDate;
      });
      widget.onDateSelected?.call(pickedDate);
    }
  }

  String get formatedDate {
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
    final monthName = months[transactionDate.month - 1];
    final now = DateTime.now();
    if (transactionDate.year == now.year &&
        transactionDate.month == now.month &&
        transactionDate.day == now.day) {
      return "Today, $monthName ${transactionDate.day}";
    }
    return "$monthName ${transactionDate.day}, ${transactionDate.year}";
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
          Text(
            formatedDate,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
          const Spacer(),
          Padding(
            padding: EdgeInsets.only(right: size.widthPerc(6)),
            child: GestureDetector(
              onTap: pickDate,
              behavior: HitTestBehavior.opaque,
              child: Text(
                "CHANGE",
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
