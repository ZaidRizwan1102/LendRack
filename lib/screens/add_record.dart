import 'package:flutter/material.dart';
import 'package:wallet/models/record_model.dart';
import 'package:wallet/services/database_service.dart';
import 'package:wallet/utils/handler.dart';
import 'package:wallet/utils/responsive.dart';
import 'package:wallet/widgets/custom_button.dart';
import 'package:wallet/widgets/custom_snackbar.dart';
import 'package:wallet/widgets/AddRecord/record_container.dart';

class AddRecord extends StatefulWidget {
  const AddRecord({super.key});

  @override
  State<AddRecord> createState() => _AddRecordState();
}

class _AddRecordState extends State<AddRecord> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  String _selectedType = 'lending';
  DateTime _selectedDate = DateTime.now();
  DateTime? _selectedReturnDate;

  @override
  void dispose() {
    _amountController.dispose();
    _contactController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

void _submitRecord() {
  final amountText = _amountController.text.trim();
  final contactName = _contactController.text.trim();
  final reason = _reasonController.text.trim();

  if (amountText.isEmpty || double.tryParse(amountText) == null) {
    CustomSnackBar.show(context, message: "Please enter a valid amount");
    return;
  }

  if (contactName.isEmpty) {
    CustomSnackBar.show(context, message: "Please enter a contact name");
    return;
  }

  final newRecord = RecordModel(
    id: DateTime.now().millisecondsSinceEpoch.toString(), // Instant local ID
    type: _selectedType,
    amount: double.parse(amountText),
    contactName: contactName,
    reason: reason.isEmpty ? null : reason,
    date: _selectedDate,
    returnDate: _selectedReturnDate,
    status: 'pending',
  );

  // 1. Instant local save (UI streams receive this instantly)
  DatabaseService().addRecord(newRecord);

  // 2. Immediate navigation
  CustomSnackBar.show(context, message: "Record added successfully!");
  AppHandler(context).goBack();
}

  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);
    final move = AppHandler(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
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
                      "Add Record",
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.heightPerc(1)),
                RecordContainer(
                  amountController: _amountController,
                  contactController: _contactController,
                  reasonController: _reasonController,
                  onTypeChanged: (type) => _selectedType = type,
                  onDateChanged: (date) => _selectedDate = date,
                  onReturnDateChanged: (date) => _selectedReturnDate = date,
                ),
                SizedBox(height: size.heightPerc(2)),
                CustomButton(
                  buttonText: "Add Record",
                  moveTo: _submitRecord,
                  buttonIcon: Icons.account_balance_wallet_sharp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
