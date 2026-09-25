import 'package:flutter/material.dart';
import 'package:wallet/models/record_model.dart';
import 'package:wallet/screens/activity.dart';
import 'package:wallet/services/database_service.dart';
import 'package:wallet/utils/responsive.dart';
import 'package:wallet/widgets/update_dropdown.dart';

class ActivityDismissible extends StatelessWidget {
  final ActivityItem item;
  final Widget child;
  final Function(ActivityItem updatedItem)? onSave;
  final VoidCallback onDelete;

  const ActivityDismissible({
    super.key,
    required this.item,
    required this.child,
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

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.horizontal,

      // Swipe Right Background (UPDATE)
      background: Container(
        color: Theme.of(context).colorScheme.primary,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: size.widthPerc(5)),
        child: Row(
          children: [
            Icon(
              Icons.edit_rounded,
              color: Theme.of(context).colorScheme.surface,
              size: size.widthPerc(5.5),
            ),
            SizedBox(width: size.widthPerc(2)),
            Text(
              "UPDATE",
              style: TextStyle(
                color: Theme.of(context).cardColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),

      // Swipe Left Background (DELETE)
      secondaryBackground: Container(
        color: Colors.red.shade600,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: size.widthPerc(5)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text(
              "DELETE",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(width: size.widthPerc(2)),
            Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
              size: size.widthPerc(7),
            ),
          ],
        ),
      ),

      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          _openEditSheet(context);
          return false;
        }
        return true;
      },

      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete();
        }
      },

      child: child,
    );
  }
}
