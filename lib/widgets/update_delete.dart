import 'package:flutter/material.dart';
import 'package:wallet/models/record_model.dart';
import 'package:wallet/screens/activity.dart';
import 'package:wallet/services/database_service.dart';
import 'package:wallet/utils/responsive.dart';
import 'package:wallet/widgets/update_dropdown.dart';

class UpdateDelete extends StatelessWidget {
  final ActivityItem item;
  final VoidCallback onDelete;
  final Function(ActivityItem updatedItem)? onSave;

  const UpdateDelete({
    super.key,
    required this.item,
    required this.onDelete,
    this.onSave,
  });

  void _openEditSheet(BuildContext context) {
    // Access real data directly from rawRecord
    final record = item.rawRecord;

    UpdateDropdown.show(
      context: context,
      name: record.contactName,
      amount: record.amount,
      description: record.reason ?? '',
      initialDate: record.date,
      isToPay: record.type == 'borrowing',
      onSave: (name, amount, description, date, isToPay) async {
        final updatedRecord = RecordModel(
          id: item.id,
          type: isToPay ? 'borrowing' : 'lending',
          amount: amount,
          contactName: name,
          reason: description.isEmpty ? null : description,
          date: date,
          returnDate: record.returnDate,
          status: record.status,
          createdAt: record.createdAt,
        );

        // Save directly to Firestore
        await DatabaseService().updateRecord(item.id, updatedRecord);

        if (onSave != null) {
          onSave!(ActivityItem.fromRecord(updatedRecord));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => _openEditSheet(context),
          child: Icon(
            Icons.edit,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            size: size.widthPerc(5.8),
          ),
        ),
        SizedBox(
          width: size.widthPerc(4.5),
          child: Divider(
            height: size.heightPerc(0.6),
            thickness: 1,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            indent: 0,
            endIndent: 0,
          ),
        ),
        GestureDetector(
          onTap: onDelete,
          child: Icon(
            Icons.delete_outline_rounded,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            size: size.widthPerc(5.8),
          ),
        ),
      ],
    );
  }
}
