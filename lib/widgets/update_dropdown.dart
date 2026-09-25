import 'package:flutter/material.dart';
import 'package:wallet/utils/responsive.dart';
import 'package:wallet/widgets/calendar_bottom_model.dart';
import 'package:wallet/widgets/custom_button.dart';
import 'package:wallet/widgets/custom_input_field.dart';

class UpdateDropdown extends StatefulWidget {
  final String name;
  final double amount;
  final String description;
  final DateTime initialDate;
  final bool isToPay;
  final void Function(
    String name,
    double amount,
    String description,
    DateTime date,
    bool isToPay,
  )
  onSave;

  const UpdateDropdown({
    super.key,
    required this.name,
    required this.amount,
    required this.description,
    required this.initialDate,
    required this.onSave,
    this.isToPay = true,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String name,
    required double amount,
    required String description,
    required DateTime initialDate,
    required void Function(
      String name,
      double amount,
      String description,
      DateTime date,
      bool isToPay,
    )
    onSave,
    bool isToPay = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => UpdateDropdown(
        name: name,
        amount: amount,
        description: description,
        initialDate: initialDate,
        onSave: onSave,
        isToPay: isToPay,
      ),
    );
  }

  @override
  State<UpdateDropdown> createState() => _UpdateDropdownState();
}

class _UpdateDropdownState extends State<UpdateDropdown> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late DateTime _selectedDate;
  late bool _isToPay;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _amountController = TextEditingController(
      text: widget.amount.toStringAsFixed(2),
    );
    _noteController = TextEditingController(text: widget.description);
    _selectedDate = widget.initialDate;
    _isToPay = widget.isToPay;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
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
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => CalendarBottomModel(initialDate: _selectedDate),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.only(
          left: size.widthPerc(5),
          right: size.widthPerc(5),
          top: size.heightPerc(1.5),
          bottom: MediaQuery.of(context).viewInsets.bottom + size.heightPerc(3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: size.widthPerc(12),
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: size.heightPerc(2)),

            // Header
            Row(
              children: [
                Container(
                  width: size.widthPerc(10),
                  height: size.widthPerc(10),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: size.widthPerc(5),
                  ),
                ),
                SizedBox(width: size.widthPerc(3)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Update Record",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    Text(
                      "TRANSACTION DETAILS",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Toggleable Badge Tag (Tap to switch between TO PAY & TO COLLECT)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isToPay = !_isToPay;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: EdgeInsets.symmetric(
                      horizontal: size.widthPerc(2.5),
                      vertical: size.heightPerc(0.6),
                    ),
                    decoration: BoxDecoration(
                      color: _isToPay
                          ? Colors.red.shade100
                          : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(size.widthPerc(3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isToPay ? "TO PAY" : "TO COLLECT",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _isToPay
                                ? Colors.red.shade800
                                : Colors.green.shade900,
                          ),
                        ),
                        SizedBox(width: size.widthPerc(1)),
                        Icon(
                          Icons.swap_horiz_rounded,
                          size: size.widthPerc(3.8),
                          color: _isToPay
                              ? Colors.red.shade800
                              : Colors.green.shade900,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: size.widthPerc(2)),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    color: Colors.grey.shade600,
                    size: size.widthPerc(6),
                  ),
                ),
              ],
            ),

            SizedBox(height: size.heightPerc(2.5)),

            // Person Name
            _buildLabel("PERSON NAME"),
            CustomInputField(
              hintText: "Person Name",
              controller: _nameController,
              customWidth: double.infinity,
              margin: EdgeInsets.only(top: size.heightPerc(0.8)),
            ),

            SizedBox(height: size.heightPerc(2)),

            // Amount & Due Date
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("AMOUNT (\$)"),
                      CustomInputField(
                        hintText: "\$ 0.00",
                        controller: _amountController,
                        customWidth: double.infinity,
                        margin: EdgeInsets.only(top: size.heightPerc(0.8)),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: size.widthPerc(3)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("DUE DATE"),
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          margin: EdgeInsets.only(top: size.heightPerc(0.8)),
                          height: size.heightPerc(5.8),
                          padding: EdgeInsets.symmetric(
                            horizontal: size.widthPerc(3),
                          ),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(
                                  context,
                                ).inputDecorationTheme.fillColor ??
                                const Color(0xFFECF6FF),
                            borderRadius: BorderRadius.circular(
                              size.widthPerc(4),
                            ),
                            border: Border.all(
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color
                                      ?.withValues(alpha: 0.3) ??
                                  Colors.black54,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDate(_selectedDate),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                ),
                              ),
                              Icon(
                                Icons.calendar_today_outlined,
                                size: size.widthPerc(4.5),
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: size.heightPerc(2)),

            // Category / Note
            _buildLabel("CATEGORY / NOTE"),
            CustomInputField(
              hintText: "Category or note",
              controller: _noteController,
              customWidth: double.infinity,
              margin: EdgeInsets.only(top: size.heightPerc(0.8)),
            ),

            SizedBox(height: size.heightPerc(3)),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    buttonText: "Save",
                    moveTo: () {
                      final parsedAmount =
                          double.tryParse(_amountController.text.trim()) ??
                          widget.amount;
                      widget.onSave(
                        _nameController.text.trim(),
                        parsedAmount,
                        _noteController.text.trim(),
                        _selectedDate,
                        _isToPay,
                      );
                      Navigator.pop(context);
                    },
                    buttonColor: Colors.green.shade600,
                    width: double.infinity,
                  ),
                ),
                SizedBox(width: size.widthPerc(3)),
                Expanded(
                  child: CustomButton(
                    buttonText: "Cancel",
                    moveTo: () => Navigator.pop(context),
                    width: double.infinity,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.bodyMedium?.color,
        letterSpacing: 0.5,
      ),
    );
  }
}
