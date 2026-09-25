import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/utils/responsive.dart';
import 'package:wallet/widgets/AddRecord/calendar_container.dart';
import 'package:wallet/widgets/AddRecord/input_heading.dart';
import 'package:wallet/widgets/AddRecord/return_date.dart';
import 'package:wallet/widgets/AddRecord/slider.dart';
import 'package:wallet/widgets/custom_input_field.dart';
import 'package:wallet/widgets/custom_snackbar.dart';

class RecordContainer extends StatefulWidget {
  final TextEditingController amountController;
  final TextEditingController contactController;
  final TextEditingController reasonController;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<DateTime?> onReturnDateChanged;

  const RecordContainer({
    super.key,
    required this.amountController,
    required this.contactController,
    required this.reasonController,
    required this.onTypeChanged,
    required this.onDateChanged,
    required this.onReturnDateChanged,
  });

  @override
  State<RecordContainer> createState() => _RecordContainerState();
}

class _RecordContainerState extends State<RecordContainer> {
  DateTime _selectedDate = DateTime.now();
  int _returnDateKeyCounter = 0; // Increments to force widget rebuild when invalid

  bool _isSameOrBefore(DateTime date1, DateTime date2) {
    final d1 = DateTime(date1.year, date1.month, date1.day);
    final d2 = DateTime(date2.year, date2.month, date2.day);
    return d1.isBefore(d2) || d1.isAtSameMomentAs(d2);
  }

  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);

    return Container(
      width: size.widthPerc(85),
      height: size.heightPerc(77),
      padding: EdgeInsets.all(size.widthPerc(3.5)),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(size.widthPerc(5)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: size.widthPerc(0.2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SlideWidget(onTypeChanged: widget.onTypeChanged),
            SizedBox(height: size.heightPerc(1)),
            Text(
              "AMOUNT",
              style: TextStyle(
                letterSpacing: size.widthPerc(0.3),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextField(
              controller: widget.amountController,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 45,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
              decoration: InputDecoration(
                filled: false,
                border: InputBorder.none,
                hintText: "00",
                hintStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.heightPerc(0.2)),
                  InputHeading(heading: "CONTACT NAME"),
                  Center(
                    child: CustomInputField(
                      controller: widget.contactController,
                      hintText: "Who is this with?",
                      svgPath: 'assets/images/person.svg',
                    ),
                  ),
                  SizedBox(height: size.heightPerc(3)),
                  InputHeading(heading: "REASON (OPTIONAL)"),
                  Center(
                    child: CustomInputField(
                      controller: widget.reasonController,
                      hintText: "What was this for?",
                      svgPath: 'assets/images/reason.svg',
                    ),
                  ),
                  SizedBox(height: size.heightPerc(3)),
                  InputHeading(heading: "DATE"),
                  CalendarContainer(
                    onDateSelected: (newDate) {
                      setState(() {
                        _selectedDate = newDate;
                      });
                      widget.onDateChanged(newDate);
                    },
                  ),
                  SizedBox(height: size.heightPerc(3)),
                  InputHeading(heading: "RETURN DATE (OPTIONAL)"),
                  ReturnDate(
                    key: ValueKey(_returnDateKeyCounter), // Forces total reset on key change
                    onDateSelected: (newReturnDate) {
                      if (newReturnDate != null &&
                          _isSameOrBefore(newReturnDate, _selectedDate)) {
                        CustomSnackBar.show(
                          context,
                          message:
                              "Return date must be after the selected date.",
                        );
                        setState(() {
                          _returnDateKeyCounter++; // Incrementing changes key, resetting UI
                        });
                        widget.onReturnDateChanged(null);
                      } else {
                        widget.onReturnDateChanged(newReturnDate);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}